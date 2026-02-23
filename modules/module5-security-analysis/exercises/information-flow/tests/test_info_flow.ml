(** Tests for information flow analysis (Exercise 4). *)

open OUnit2
open Info_flow_ex

let taint_printer = Taint_domain.to_string
let assert_taint msg expected actual =
  assert_equal ~printer:taint_printer ~msg expected actual

let _flow_kind_printer = function
  | Flow_analyzer.Explicit -> "Explicit"
  | Flow_analyzer.Implicit -> "Implicit"

(* ------------------------------------------------------------------ *)
(* pc_taint transfer tests                                            *)
(* ------------------------------------------------------------------ *)

let test_assign_with_clean_pc _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.bottom in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Untainted env
    (Assign ("x", IntLit 42)) in
  assert_taint "clean pc + literal = untainted"
    Taint_domain.Untainted
    (Flow_analyzer.Env.lookup "x" env')

let test_assign_with_tainted_pc _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.bottom in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Tainted env
    (Assign ("x", IntLit 42)) in
  assert_taint "tainted pc + literal = tainted (implicit flow)"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "x" env')

let test_assign_tainted_data_clean_pc _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.bottom in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Untainted env
    (Assign ("x", Call ("get_param", [IntLit 0]))) in
  assert_taint "clean pc + source = tainted (explicit flow)"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "x" env')

let test_assign_tainted_data_tainted_pc _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.bottom in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Tainted env
    (Assign ("x", Call ("get_param", [IntLit 0]))) in
  assert_taint "tainted pc + source = tainted"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "x" env')

let test_sequence_with_pc _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.bottom in
  let stmts = [
    Assign ("a", IntLit 1);
    Assign ("b", IntLit 2);
  ] in
  let env' = Flow_analyzer.transfer_stmts
    ~pc_taint:Taint_domain.Tainted env stmts in
  assert_taint "a tainted by pc"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "a" env');
  assert_taint "b tainted by pc"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "b" env')

(* ------------------------------------------------------------------ *)
(* If with tainted condition tests                                    *)
(* ------------------------------------------------------------------ *)

let test_if_tainted_condition _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.update "secret" Taint_domain.Tainted
    Flow_analyzer.Env.bottom in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Untainted env
    (If (Var "secret",
      [Assign ("x", IntLit 1)],
      [Assign ("x", IntLit 0)])) in
  assert_taint "x tainted by implicit flow"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "x" env')

let test_if_clean_condition _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.update "flag" Taint_domain.Untainted
    Flow_analyzer.Env.bottom in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Untainted env
    (If (Var "flag",
      [Assign ("x", IntLit 1)],
      [Assign ("x", IntLit 0)])) in
  assert_taint "x untainted when condition is clean"
    Taint_domain.Untainted
    (Flow_analyzer.Env.lookup "x" env')

let test_nested_if_tainted _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.update "secret" Taint_domain.Tainted
    Flow_analyzer.Env.bottom in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Untainted env
    (If (Var "secret",
      [If (BoolLit true,
        [Assign ("x", IntLit 1)],
        [Assign ("x", IntLit 2)])],
      [Assign ("x", IntLit 0)])) in
  assert_taint "nested: x tainted by outer implicit flow"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "x" env')

let test_if_only_one_branch_assigns _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.update "secret" Taint_domain.Tainted
    Flow_analyzer.Env.bottom in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Untainted env
    (If (Var "secret",
      [Assign ("x", IntLit 1)],
      [])) in
  let x = Flow_analyzer.Env.lookup "x" env' in
  assert_bool "x potentially tainted from one-branch if"
    (Taint_domain.is_potentially_tainted x)

(* ------------------------------------------------------------------ *)
(* While with tainted condition tests                                 *)
(* ------------------------------------------------------------------ *)

let test_while_tainted_condition _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.update "secret" Taint_domain.Tainted
    (Flow_analyzer.Env.update "x" Taint_domain.Untainted
      Flow_analyzer.Env.bottom) in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Untainted env
    (While (Var "secret",
      [Assign ("x", BinOp (Add, Var "x", IntLit 1))])) in
  let x = Flow_analyzer.Env.lookup "x" env' in
  assert_bool "x tainted by while with tainted condition"
    (Taint_domain.is_potentially_tainted x)

let test_while_clean_condition _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.update "flag" Taint_domain.Untainted
    (Flow_analyzer.Env.update "x" Taint_domain.Untainted
      Flow_analyzer.Env.bottom) in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Untainted env
    (While (Var "flag",
      [Assign ("x", BinOp (Add, Var "x", IntLit 1))])) in
  assert_taint "x untainted when while condition is clean"
    Taint_domain.Untainted
    (Flow_analyzer.Env.lookup "x" env')

let test_while_terminates _ctx =
  let open Shared_ast.Ast_types in
  let env = Flow_analyzer.Env.update "secret" Taint_domain.Tainted
    Flow_analyzer.Env.bottom in
  let env' = Flow_analyzer.transfer_stmt
    ~pc_taint:Taint_domain.Untainted env
    (While (Var "secret",
      [Assign ("i", BinOp (Add, Var "i", IntLit 1))])) in
  let _ = env' in
  assert_bool "while terminates" true

(* ------------------------------------------------------------------ *)
(* Flow detection tests                                               *)
(* ------------------------------------------------------------------ *)

let test_detect_explicit_flow _ctx =
  let func = List.hd Sample_programs.explicit_flow in
  let (_, flows) = Flow_analyzer.analyze_function func in
  assert_bool "should detect flows"
    (List.length flows > 0);
  assert_bool "should have explicit flow"
    (List.exists (fun f -> f.Flow_analyzer.kind = Flow_analyzer.Explicit) flows)

let test_detect_implicit_flow _ctx =
  let func = List.hd Sample_programs.implicit_flow in
  let (_, flows) = Flow_analyzer.analyze_function func in
  assert_bool "should detect implicit flow"
    (List.exists (fun f -> f.Flow_analyzer.kind = Flow_analyzer.Implicit) flows)

let test_detect_nested_implicit _ctx =
  let func = List.hd Sample_programs.nested_implicit in
  let (_, flows) = Flow_analyzer.analyze_function func in
  assert_bool "should detect implicit flow in nested"
    (List.exists (fun f -> f.Flow_analyzer.kind = Flow_analyzer.Implicit) flows)

let test_detect_loop_implicit _ctx =
  let func = List.hd Sample_programs.loop_implicit in
  let (_, flows) = Flow_analyzer.analyze_function func in
  assert_bool "should detect implicit flow in loop"
    (List.exists (fun f -> f.Flow_analyzer.kind = Flow_analyzer.Implicit) flows)

(* ------------------------------------------------------------------ *)
(* Full analysis tests                                                *)
(* ------------------------------------------------------------------ *)

let test_analyze_explicit _ctx =
  let func = List.hd Sample_programs.explicit_flow in
  let (env, _) = Flow_analyzer.analyze_function func in
  assert_taint "secret is tainted"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "secret" env);
  assert_taint "x is tainted (explicit)"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "x" env)

let test_analyze_implicit _ctx =
  let func = List.hd Sample_programs.implicit_flow in
  let (env, _) = Flow_analyzer.analyze_function func in
  assert_taint "secret is tainted"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "secret" env);
  assert_taint "x is tainted (implicit)"
    Taint_domain.Tainted
    (Flow_analyzer.Env.lookup "x" env)

let test_analyze_no_flow _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "clean"; params = [];
    body = [
      Assign ("x", IntLit 1);
      Assign ("y", IntLit 2);
    ] } in
  let (_, flows) = Flow_analyzer.analyze_function func in
  assert_equal ~printer:string_of_int ~msg:"no flows in clean program"
    0 (List.length flows)

let test_flow_variable_names _ctx =
  let func = List.hd Sample_programs.explicit_flow in
  let (_, flows) = Flow_analyzer.analyze_function func in
  let vars = List.map (fun f -> f.Flow_analyzer.variable) flows in
  assert_bool "should track variable name"
    (List.exists (fun v -> v = "x" || v = "secret") vars)

let () =
  run_test_tt_main
    ("Information Flow" >::: [
       (* pc_taint transfer: 5 tests *)
       "assign clean pc"       >:: test_assign_with_clean_pc;
       "assign tainted pc"     >:: test_assign_with_tainted_pc;
       "assign tainted data clean pc" >:: test_assign_tainted_data_clean_pc;
       "assign tainted data tainted pc" >:: test_assign_tainted_data_tainted_pc;
       "sequence with pc"      >:: test_sequence_with_pc;
       (* If with tainted condition: 4 tests *)
       "if tainted condition"  >:: test_if_tainted_condition;
       "if clean condition"    >:: test_if_clean_condition;
       "nested if tainted"     >:: test_nested_if_tainted;
       "if one branch assigns" >:: test_if_only_one_branch_assigns;
       (* While with tainted condition: 3 tests *)
       "while tainted cond"    >:: test_while_tainted_condition;
       "while clean cond"      >:: test_while_clean_condition;
       "while terminates"      >:: test_while_terminates;
       (* Flow detection: 4 tests *)
       "detect explicit"       >:: test_detect_explicit_flow;
       "detect implicit"       >:: test_detect_implicit_flow;
       "detect nested implicit" >:: test_detect_nested_implicit;
       "detect loop implicit"  >:: test_detect_loop_implicit;
       (* Full analysis: 4 tests *)
       "analyze explicit"      >:: test_analyze_explicit;
       "analyze implicit"      >:: test_analyze_implicit;
       "analyze no flow"       >:: test_analyze_no_flow;
       "flow variable names"   >:: test_flow_variable_names;
     ])
