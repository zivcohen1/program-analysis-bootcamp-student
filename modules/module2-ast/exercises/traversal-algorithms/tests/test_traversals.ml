(* test_traversals.ml - OUnit2 tests for the traversal-algorithms exercise. *)

open OUnit2
open Shared_ast.Ast_types
open Traversal_exercises

(* ------------------------------------------------------------------ *)
(* Helpers                                                             *)
(* ------------------------------------------------------------------ *)

(** Pretty-print a string list for readable assertion failures. *)
let pp_list lst =
  "[" ^ String.concat "; " (List.map (fun s -> "\"" ^ s ^ "\"") lst) ^ "]"

let assert_list_eq ~msg expected actual =
  assert_equal ~msg ~printer:pp_list expected actual

(** Pretty-print an int option for readable assertion failures. *)
let pp_int_option = function
  | Some n -> "Some " ^ string_of_int n
  | None -> "None"

(** Look up a key in an association list, defaulting to 0. *)
let assoc_or_zero key lst =
  match List.assoc_opt key lst with
  | Some n -> n
  | None -> 0

(* ------------------------------------------------------------------ *)
(* Sample ASTs used across tests                                       *)
(* ------------------------------------------------------------------ *)

(* x = 1 + 2
   A small tree:
       Assign
         |
       BinOp(+)
       /     \
   IntLit(1) IntLit(2)
*)
let simple_assign : stmt list =
  [ Assign ("x", BinOp (Add, IntLit 1, IntLit 2)) ]

(* result = (2 + 3) x 4
   Deeper nesting to distinguish BFS from pre-order:
       Assign
         |
       BinOp[*]
       /       \
   BinOp[+]   IntLit(4)
   /     \
 IntLit(2) IntLit(3)
*)
let nested_assign : stmt list =
  [ Assign ("result",
      BinOp (Mul,
        BinOp (Add, IntLit 2, IntLit 3),
        IntLit 4)) ]

(* if (x > 0) { y = 1 } else { y = 2 } *)
let if_stmt : stmt list =
  [ If (BinOp (Gt, Var "x", IntLit 0),
      [ Assign ("y", IntLit 1) ],
      [ Assign ("y", IntLit 2) ]) ]

(* while (i < n) { i = i + 1 } *)
let while_stmt : stmt list =
  [ While (BinOp (Lt, Var "i", Var "n"),
      [ Assign ("i", BinOp (Add, Var "i", IntLit 1)) ]) ]

(* ------------------------------------------------------------------ *)
(* Pre-order tests                                                     *)
(* ------------------------------------------------------------------ *)

let test_pre_order_simple _ =
  let result = Traversals.pre_order simple_assign in
  assert_list_eq ~msg:"pre_order simple assign"
    ["Assign"; "BinOp(+)"; "IntLit(1)"; "IntLit(2)"]
    result

let test_pre_order_nested _ =
  let result = Traversals.pre_order nested_assign in
  (* Pre-order: visit node, then left subtree, then right subtree *)
  assert_list_eq ~msg:"pre_order nested"
    ["Assign"; "BinOp(*)"; "BinOp(+)"; "IntLit(2)"; "IntLit(3)"; "IntLit(4)"]
    result

let test_pre_order_if _ =
  let result = Traversals.pre_order if_stmt in
  assert_list_eq ~msg:"pre_order if"
    ["If"; "BinOp(>)"; "Var(x)"; "IntLit(0)";
     "Assign"; "IntLit(1)";
     "Assign"; "IntLit(2)"]
    result

let test_pre_order_while _ =
  let result = Traversals.pre_order while_stmt in
  assert_list_eq ~msg:"pre_order while"
    ["While"; "BinOp(<)"; "Var(i)"; "Var(n)";
     "Assign"; "BinOp(+)"; "Var(i)"; "IntLit(1)"]
    result

(* ------------------------------------------------------------------ *)
(* Post-order tests                                                    *)
(* ------------------------------------------------------------------ *)

let test_post_order_simple _ =
  let result = Traversals.post_order simple_assign in
  assert_list_eq ~msg:"post_order simple assign"
    ["IntLit(1)"; "IntLit(2)"; "BinOp(+)"; "Assign"]
    result

let test_post_order_nested _ =
  let result = Traversals.post_order nested_assign in
  assert_list_eq ~msg:"post_order nested"
    ["IntLit(2)"; "IntLit(3)"; "BinOp(+)"; "IntLit(4)"; "BinOp(*)"; "Assign"]
    result

let test_post_order_if _ =
  let result = Traversals.post_order if_stmt in
  assert_list_eq ~msg:"post_order if"
    ["Var(x)"; "IntLit(0)"; "BinOp(>)";
     "IntLit(1)"; "Assign";
     "IntLit(2)"; "Assign";
     "If"]
    result

(* ------------------------------------------------------------------ *)
(* BFS tests                                                           *)
(* ------------------------------------------------------------------ *)

let test_bfs_simple _ =
  let result = Traversals.bfs simple_assign in
  assert_list_eq ~msg:"bfs simple assign"
    ["Assign"; "BinOp(+)"; "IntLit(1)"; "IntLit(2)"]
    result

let test_bfs_nested _ =
  let result = Traversals.bfs nested_assign in
  (* BFS visits level-by-level:
     Level 0: Assign
     Level 1: BinOp[*]
     Level 2: BinOp[+], IntLit(4)
     Level 3: IntLit(2), IntLit(3)
     This differs from pre-order which would put IntLit(4) after IntLit(3). *)
  assert_list_eq ~msg:"bfs nested"
    ["Assign"; "BinOp(*)"; "BinOp(+)"; "IntLit(4)"; "IntLit(2)"; "IntLit(3)"]
    result

let test_bfs_if _ =
  let result = Traversals.bfs if_stmt in
  (* BFS level-by-level:
     Level 0: If
     Level 1: BinOp(>), Assign (then), Assign (else)
     Level 2: Var(x), IntLit(0), IntLit(1), IntLit(2) *)
  assert_list_eq ~msg:"bfs if"
    ["If"; "BinOp(>)"; "Assign"; "Assign";
     "Var(x)"; "IntLit(0)"; "IntLit(1)"; "IntLit(2)"]
    result

(* ------------------------------------------------------------------ *)
(* count_nodes tests                                                   *)
(* ------------------------------------------------------------------ *)

let test_count_nodes_simple _ =
  let counts = Visitor.count_nodes simple_assign in
  assert_equal ~msg:"Assign count" ~printer:string_of_int
    1 (assoc_or_zero "Assign" counts);
  assert_equal ~msg:"BinOp count" ~printer:string_of_int
    1 (assoc_or_zero "BinOp" counts);
  assert_equal ~msg:"IntLit count" ~printer:string_of_int
    2 (assoc_or_zero "IntLit" counts)

let test_count_nodes_if _ =
  let counts = Visitor.count_nodes if_stmt in
  assert_equal ~msg:"If count" ~printer:string_of_int
    1 (assoc_or_zero "If" counts);
  assert_equal ~msg:"Assign count" ~printer:string_of_int
    2 (assoc_or_zero "Assign" counts);
  assert_equal ~msg:"BinOp count" ~printer:string_of_int
    1 (assoc_or_zero "BinOp" counts);
  assert_equal ~msg:"Var count" ~printer:string_of_int
    1 (assoc_or_zero "Var" counts);
  assert_equal ~msg:"IntLit count" ~printer:string_of_int
    3 (assoc_or_zero "IntLit" counts)

let test_count_nodes_nested _ =
  let counts = Visitor.count_nodes nested_assign in
  assert_equal ~msg:"Assign count" ~printer:string_of_int
    1 (assoc_or_zero "Assign" counts);
  assert_equal ~msg:"BinOp count" ~printer:string_of_int
    2 (assoc_or_zero "BinOp" counts);
  assert_equal ~msg:"IntLit count" ~printer:string_of_int
    3 (assoc_or_zero "IntLit" counts)

(* ------------------------------------------------------------------ *)
(* evaluate tests                                                      *)
(* ------------------------------------------------------------------ *)

let test_evaluate_int_lit _ =
  assert_equal ~msg:"IntLit 42" ~printer:pp_int_option
    (Some 42) (Visitor.evaluate (IntLit 42))

let test_evaluate_add _ =
  assert_equal ~msg:"1 + 2" ~printer:pp_int_option
    (Some 3) (Visitor.evaluate (BinOp (Add, IntLit 1, IntLit 2)))

let test_evaluate_nested _ =
  (* (2 + 3) * 4 = 20 *)
  assert_equal ~msg:"(2+3)*4" ~printer:pp_int_option
    (Some 20)
    (Visitor.evaluate
       (BinOp (Mul, BinOp (Add, IntLit 2, IntLit 3), IntLit 4)))

let test_evaluate_sub _ =
  assert_equal ~msg:"10 - 3" ~printer:pp_int_option
    (Some 7) (Visitor.evaluate (BinOp (Sub, IntLit 10, IntLit 3)))

let test_evaluate_div _ =
  assert_equal ~msg:"10 / 3" ~printer:pp_int_option
    (Some 3) (Visitor.evaluate (BinOp (Div, IntLit 10, IntLit 3)))

let test_evaluate_div_by_zero _ =
  assert_equal ~msg:"1 / 0" ~printer:pp_int_option
    None (Visitor.evaluate (BinOp (Div, IntLit 1, IntLit 0)))

let test_evaluate_negation _ =
  assert_equal ~msg:"-(5)" ~printer:pp_int_option
    (Some (-5)) (Visitor.evaluate (UnaryOp (Neg, IntLit 5)))

let test_evaluate_var _ =
  assert_equal ~msg:"Var should be None" ~printer:pp_int_option
    None (Visitor.evaluate (Var "x"))

let test_evaluate_var_in_expr _ =
  assert_equal ~msg:"1 + x should be None" ~printer:pp_int_option
    None (Visitor.evaluate (BinOp (Add, IntLit 1, Var "x")))

let test_evaluate_bool _ =
  assert_equal ~msg:"BoolLit should be None" ~printer:pp_int_option
    None (Visitor.evaluate (BoolLit true))

let test_evaluate_comparison _ =
  assert_equal ~msg:"comparison should be None" ~printer:pp_int_option
    None (Visitor.evaluate (BinOp (Eq, IntLit 1, IntLit 1)))

let test_evaluate_call _ =
  assert_equal ~msg:"Call should be None" ~printer:pp_int_option
    None (Visitor.evaluate (Call ("f", [IntLit 1])))

(* ------------------------------------------------------------------ *)
(* Test suite                                                          *)
(* ------------------------------------------------------------------ *)

let suite =
  "traversal-algorithms" >::: [
    (* pre-order *)
    "pre_order_simple"  >:: test_pre_order_simple;
    "pre_order_nested"  >:: test_pre_order_nested;
    "pre_order_if"      >:: test_pre_order_if;
    "pre_order_while"   >:: test_pre_order_while;

    (* post-order *)
    "post_order_simple" >:: test_post_order_simple;
    "post_order_nested" >:: test_post_order_nested;
    "post_order_if"     >:: test_post_order_if;

    (* bfs *)
    "bfs_simple"        >:: test_bfs_simple;
    "bfs_nested"        >:: test_bfs_nested;
    "bfs_if"            >:: test_bfs_if;

    (* count_nodes *)
    "count_nodes_simple" >:: test_count_nodes_simple;
    "count_nodes_if"     >:: test_count_nodes_if;
    "count_nodes_nested" >:: test_count_nodes_nested;

    (* evaluate *)
    "evaluate_int_lit"    >:: test_evaluate_int_lit;
    "evaluate_add"        >:: test_evaluate_add;
    "evaluate_nested"     >:: test_evaluate_nested;
    "evaluate_sub"        >:: test_evaluate_sub;
    "evaluate_div"        >:: test_evaluate_div;
    "evaluate_div_zero"   >:: test_evaluate_div_by_zero;
    "evaluate_negation"   >:: test_evaluate_negation;
    "evaluate_var"        >:: test_evaluate_var;
    "evaluate_var_in_expr" >:: test_evaluate_var_in_expr;
    "evaluate_bool"       >:: test_evaluate_bool;
    "evaluate_comparison" >:: test_evaluate_comparison;
    "evaluate_call"       >:: test_evaluate_call;
  ]

let () = run_test_tt_main suite
