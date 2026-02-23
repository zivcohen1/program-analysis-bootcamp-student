(** Tests for the interprocedural call graph analysis. *)

open OUnit2
open Shared_ast.Ast_types
open Interprocedural

(* ------------------------------------------------------------------ *)
(*  Helper utilities                                                   *)
(* ------------------------------------------------------------------ *)

let assert_string_set_equal ~msg expected actual =
  let expected_sorted = List.sort String.compare expected in
  let actual_sorted = Call_graph.StringSet.elements actual in
  assert_equal ~msg ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    expected_sorted actual_sorted

(* ------------------------------------------------------------------ *)
(*  The multi-function example program                                 *)
(*  main -> process_data -> helper                                     *)
(* ------------------------------------------------------------------ *)

let multi_func_cg =
  Call_graph.build_call_graph Example_program.program

(* ------------------------------------------------------------------ *)
(*  Test: calls_in_expr                                                *)
(* ------------------------------------------------------------------ *)

let test_calls_in_expr_simple _ =
  (* Call("helper", [Var "temp"]) should find "helper" *)
  let expr = Call ("helper", [Var "temp"]) in
  let calls = Call_graph.calls_in_expr expr in
  assert_equal ~msg:"calls_in_expr should find 'helper'"
    ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    ["helper"]
    (List.sort String.compare calls)

let test_calls_in_expr_nested _ =
  (* Call("f", [Call("g", [IntLit 1])]) should find both *)
  let expr = Call ("f", [Call ("g", [IntLit 1])]) in
  let calls = Call_graph.calls_in_expr expr in
  assert_equal ~msg:"calls_in_expr should find nested calls"
    ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    ["f"; "g"]
    (List.sort String.compare calls)

let test_calls_in_expr_binop _ =
  (* BinOp(Add, Call("a", []), Call("b", [])) should find both *)
  let expr = BinOp (Add, Call ("a", []), Call ("b", [])) in
  let calls = Call_graph.calls_in_expr expr in
  assert_equal ~msg:"calls_in_expr should find calls in both sides of binop"
    ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    ["a"; "b"]
    (List.sort String.compare calls)

let test_calls_in_expr_no_calls _ =
  let expr = BinOp (Add, Var "x", IntLit 1) in
  let calls = Call_graph.calls_in_expr expr in
  assert_equal ~msg:"calls_in_expr should return [] for expression without calls"
    ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    [] calls

(* ------------------------------------------------------------------ *)
(*  Test: calls_in_stmts                                               *)
(* ------------------------------------------------------------------ *)

let test_calls_in_stmts_process_data _ =
  (* process_data body calls "helper" twice *)
  let process_data_body =
    [ Assign ("temp", BinOp (Mul, Var "x", IntLit 2));
      Assign ("result1", Call ("helper", [Var "temp"]));
      Assign ("result2", Call ("helper", [Var "y"]));
      Return (Some (BinOp (Add, Var "result1", Var "result2"))) ]
  in
  let calls = Call_graph.calls_in_stmts process_data_body in
  let unique = List.sort_uniq String.compare calls in
  assert_equal ~msg:"process_data body should call 'helper'"
    ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    ["helper"] unique

let test_calls_in_stmts_if_branches _ =
  (* Calls inside if branches should be collected *)
  let stmts =
    [ If (BoolLit true,
        [Assign ("x", Call ("foo", []))],
        [Assign ("y", Call ("bar", []))]) ]
  in
  let calls = Call_graph.calls_in_stmts stmts in
  let unique = List.sort_uniq String.compare calls in
  assert_equal ~msg:"should find calls in both if branches"
    ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    ["bar"; "foo"] unique

(* ------------------------------------------------------------------ *)
(*  Test: build_call_graph                                             *)
(* ------------------------------------------------------------------ *)

let test_build_nodes _ =
  let nodes = multi_func_cg.nodes in
  assert_string_set_equal ~msg:"graph should have all 3 function nodes"
    ["helper"; "main"; "process_data"] nodes

let test_build_edges_main _ =
  let main_callees =
    Call_graph.StringMap.find "main" multi_func_cg.edges
  in
  assert_string_set_equal ~msg:"main should call process_data"
    ["process_data"] main_callees

let test_build_edges_process_data _ =
  let pd_callees =
    Call_graph.StringMap.find "process_data" multi_func_cg.edges
  in
  assert_string_set_equal ~msg:"process_data should call helper"
    ["helper"] pd_callees

let test_build_edges_helper _ =
  let helper_callees =
    Call_graph.StringMap.find "helper" multi_func_cg.edges
  in
  assert_string_set_equal ~msg:"helper should call nothing"
    [] helper_callees

(* ------------------------------------------------------------------ *)
(*  Test: reachable_from                                               *)
(* ------------------------------------------------------------------ *)

let test_reachable_from_main _ =
  let reachable = Call_graph.reachable_from multi_func_cg "main" in
  assert_string_set_equal ~msg:"main should reach process_data and helper"
    ["helper"; "process_data"] reachable

let test_reachable_from_process_data _ =
  let reachable = Call_graph.reachable_from multi_func_cg "process_data" in
  assert_string_set_equal ~msg:"process_data should reach helper"
    ["helper"] reachable

let test_reachable_from_helper _ =
  let reachable = Call_graph.reachable_from multi_func_cg "helper" in
  assert_string_set_equal ~msg:"helper should reach nothing"
    [] reachable

(* ------------------------------------------------------------------ *)
(*  Test: find_recursive (non-recursive program)                       *)
(* ------------------------------------------------------------------ *)

let test_no_recursion _ =
  let recursive = Call_graph.find_recursive multi_func_cg in
  assert_equal ~msg:"multi_function program has no recursion"
    ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    [] recursive

(* ------------------------------------------------------------------ *)
(*  Test: mutual recursion                                             *)
(*  f calls g, g calls f  -->  both should be detected as recursive    *)
(* ------------------------------------------------------------------ *)

let mutual_recursion_program : program =
  [{ name = "f"; params = ["n"];
     body = [
       If (BinOp (Le, Var "n", IntLit 0),
         [Return (Some (IntLit 1))],
         [Return (Some (Call ("g", [BinOp (Sub, Var "n", IntLit 1)])))])
     ] };
   { name = "g"; params = ["n"];
     body = [
       If (BinOp (Le, Var "n", IntLit 0),
         [Return (Some (IntLit 0))],
         [Return (Some (Call ("f", [BinOp (Sub, Var "n", IntLit 1)])))])
     ] }]

let mutual_cg = Call_graph.build_call_graph mutual_recursion_program

let test_mutual_recursion_edges _ =
  let f_callees = Call_graph.StringMap.find "f" mutual_cg.edges in
  let g_callees = Call_graph.StringMap.find "g" mutual_cg.edges in
  assert_string_set_equal ~msg:"f should call g" ["g"] f_callees;
  assert_string_set_equal ~msg:"g should call f" ["f"] g_callees

let test_mutual_recursion_detected _ =
  let recursive = Call_graph.find_recursive mutual_cg in
  assert_equal ~msg:"f and g should both be recursive"
    ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    ["f"; "g"] recursive

let test_mutual_reachable _ =
  let from_f = Call_graph.reachable_from mutual_cg "f" in
  let from_g = Call_graph.reachable_from mutual_cg "g" in
  assert_string_set_equal ~msg:"from f should reach f and g"
    ["f"; "g"] from_f;
  assert_string_set_equal ~msg:"from g should reach f and g"
    ["f"; "g"] from_g

(* ------------------------------------------------------------------ *)
(*  Test: direct recursion                                             *)
(*  factorial calls itself                                             *)
(* ------------------------------------------------------------------ *)

let direct_recursion_program : program =
  [{ name = "factorial"; params = ["n"];
     body = [
       If (BinOp (Le, Var "n", IntLit 1),
         [Return (Some (IntLit 1))],
         [Return (Some (BinOp (Mul, Var "n",
           Call ("factorial", [BinOp (Sub, Var "n", IntLit 1)]))))])
     ] }]

let direct_cg = Call_graph.build_call_graph direct_recursion_program

let test_direct_recursion_detected _ =
  let recursive = Call_graph.find_recursive direct_cg in
  assert_equal ~msg:"factorial should be detected as recursive"
    ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    ["factorial"] recursive

(* ------------------------------------------------------------------ *)
(*  Test suite                                                         *)
(* ------------------------------------------------------------------ *)

let suite =
  "Call Graph Tests" >::: [
    (* calls_in_expr *)
    "calls_in_expr: simple call" >:: test_calls_in_expr_simple;
    "calls_in_expr: nested calls" >:: test_calls_in_expr_nested;
    "calls_in_expr: calls in binop" >:: test_calls_in_expr_binop;
    "calls_in_expr: no calls" >:: test_calls_in_expr_no_calls;

    (* calls_in_stmts *)
    "calls_in_stmts: process_data" >:: test_calls_in_stmts_process_data;
    "calls_in_stmts: if branches" >:: test_calls_in_stmts_if_branches;

    (* build_call_graph *)
    "build_call_graph: nodes" >:: test_build_nodes;
    "build_call_graph: main edges" >:: test_build_edges_main;
    "build_call_graph: process_data edges" >:: test_build_edges_process_data;
    "build_call_graph: helper edges" >:: test_build_edges_helper;

    (* reachable_from *)
    "reachable_from: main" >:: test_reachable_from_main;
    "reachable_from: process_data" >:: test_reachable_from_process_data;
    "reachable_from: helper" >:: test_reachable_from_helper;

    (* recursion detection *)
    "find_recursive: no recursion" >:: test_no_recursion;
    "mutual recursion: edges" >:: test_mutual_recursion_edges;
    "mutual recursion: detected" >:: test_mutual_recursion_detected;
    "mutual recursion: reachable" >:: test_mutual_reachable;
    "direct recursion: detected" >:: test_direct_recursion_detected;
  ]

let () = run_test_tt_main suite
