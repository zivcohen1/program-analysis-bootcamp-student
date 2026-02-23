(** Tests for taint propagation (Exercise 3). *)

open OUnit2
open Taint_prop_ex

let taint_printer = Taint_domain.to_string
let assert_taint msg expected actual =
  assert_equal ~printer:taint_printer ~msg expected actual

(* ------------------------------------------------------------------ *)
(* Expression evaluation tests                                        *)
(* ------------------------------------------------------------------ *)

let test_eval_literal _ctx =
  let env = Taint_propagator.Env.bottom in
  assert_taint "int literal is untainted"
    Taint_domain.Untainted
    (Taint_propagator.eval_expr env (Shared_ast.Ast_types.IntLit 42))

let test_eval_bool_literal _ctx =
  let env = Taint_propagator.Env.bottom in
  assert_taint "bool literal is untainted"
    Taint_domain.Untainted
    (Taint_propagator.eval_expr env (Shared_ast.Ast_types.BoolLit true))

let test_eval_var_untainted _ctx =
  let env = Taint_propagator.Env.update "x" Taint_domain.Untainted
    Taint_propagator.Env.bottom in
  assert_taint "var lookup untainted"
    Taint_domain.Untainted
    (Taint_propagator.eval_expr env (Shared_ast.Ast_types.Var "x"))

let test_eval_var_tainted _ctx =
  let env = Taint_propagator.Env.update "x" Taint_domain.Tainted
    Taint_propagator.Env.bottom in
  assert_taint "var lookup tainted"
    Taint_domain.Tainted
    (Taint_propagator.eval_expr env (Shared_ast.Ast_types.Var "x"))

let test_eval_source _ctx =
  let env = Taint_propagator.Env.bottom in
  assert_taint "source call is tainted"
    Taint_domain.Tainted
    (Taint_propagator.eval_expr env
      (Shared_ast.Ast_types.Call ("get_param", [IntLit 0])))

let test_eval_sanitizer _ctx =
  let env = Taint_propagator.Env.bottom in
  assert_taint "sanitizer call is untainted"
    Taint_domain.Untainted
    (Taint_propagator.eval_expr env
      (Shared_ast.Ast_types.Call ("escape_sql", [Var "x"])))

let test_eval_unknown_call _ctx =
  let env = Taint_propagator.Env.bottom in
  assert_taint "unknown call is top"
    Taint_domain.Top
    (Taint_propagator.eval_expr env
      (Shared_ast.Ast_types.Call ("unknown_func", [IntLit 0])))

let test_eval_binop_propagation _ctx =
  let env = Taint_propagator.Env.update "x" Taint_domain.Tainted
    (Taint_propagator.Env.update "y" Taint_domain.Untainted
      Taint_propagator.Env.bottom) in
  let open Shared_ast.Ast_types in
  assert_taint "binop propagates taint"
    Taint_domain.Tainted
    (Taint_propagator.eval_expr env (BinOp (Add, Var "x", Var "y")))

(* ------------------------------------------------------------------ *)
(* Transfer function tests                                            *)
(* ------------------------------------------------------------------ *)

let test_transfer_assign _ctx =
  let open Shared_ast.Ast_types in
  let env = Taint_propagator.Env.bottom in
  let env' = Taint_propagator.transfer_stmt env
    (Assign ("x", Call ("get_param", [IntLit 0]))) in
  assert_taint "assign from source"
    Taint_domain.Tainted
    (Taint_propagator.Env.lookup "x" env')

let test_transfer_assign_literal _ctx =
  let open Shared_ast.Ast_types in
  let env = Taint_propagator.Env.bottom in
  let env' = Taint_propagator.transfer_stmt env
    (Assign ("x", IntLit 42)) in
  assert_taint "assign from literal"
    Taint_domain.Untainted
    (Taint_propagator.Env.lookup "x" env')

let test_transfer_if_both_branches _ctx =
  let open Shared_ast.Ast_types in
  let env = Taint_propagator.Env.bottom in
  let env' = Taint_propagator.transfer_stmt env
    (If (BoolLit true,
      [Assign ("x", Call ("get_param", [IntLit 0]))],
      [Assign ("x", IntLit 0)])) in
  let x = Taint_propagator.Env.lookup "x" env' in
  assert_bool "x after branch should be potentially tainted"
    (Taint_domain.is_potentially_tainted x)

let test_transfer_sequence _ctx =
  let open Shared_ast.Ast_types in
  let env = Taint_propagator.Env.bottom in
  let stmts = [
    Assign ("input", Call ("get_param", [IntLit 0]));
    Assign ("safe", Call ("escape_sql", [Var "input"]));
  ] in
  let env' = Taint_propagator.transfer_stmts env stmts in
  assert_taint "input is tainted"
    Taint_domain.Tainted
    (Taint_propagator.Env.lookup "input" env');
  assert_taint "safe is untainted"
    Taint_domain.Untainted
    (Taint_propagator.Env.lookup "safe" env')

let test_transfer_while _ctx =
  let open Shared_ast.Ast_types in
  let env = Taint_propagator.Env.update "x" Taint_domain.Untainted
    Taint_propagator.Env.bottom in
  let env' = Taint_propagator.transfer_stmt env
    (While (BoolLit true,
      [Assign ("x", BinOp (Add, Var "x", IntLit 1))])) in
  let x = Taint_propagator.Env.lookup "x" env' in
  assert_bool "x after while loop should not be Bot"
    (not (Taint_domain.equal x Taint_domain.Bot))

let test_transfer_return _ctx =
  let open Shared_ast.Ast_types in
  let env = Taint_propagator.Env.update "x" Taint_domain.Tainted
    Taint_propagator.Env.bottom in
  let env' = Taint_propagator.transfer_stmt env (Return (Some (Var "x"))) in
  assert_taint "return preserves env"
    Taint_domain.Tainted
    (Taint_propagator.Env.lookup "x" env')

(* ------------------------------------------------------------------ *)
(* Full analysis tests                                                *)
(* ------------------------------------------------------------------ *)

let test_analyze_sql_injection _ctx =
  let func = List.hd Sample_programs.sql_injection in
  let env = Taint_propagator.analyze_function func in
  assert_taint "input is tainted"
    Taint_domain.Tainted
    (Taint_propagator.Env.lookup "input" env);
  assert_bool "query is potentially tainted"
    (Taint_domain.is_potentially_tainted
      (Taint_propagator.Env.lookup "query" env))

let test_analyze_sanitized _ctx =
  let func = List.hd Sample_programs.sanitized in
  let env = Taint_propagator.analyze_function func in
  assert_taint "input is tainted"
    Taint_domain.Tainted
    (Taint_propagator.Env.lookup "input" env);
  assert_taint "safe is untainted"
    Taint_domain.Untainted
    (Taint_propagator.Env.lookup "safe" env)

let test_analyze_clean _ctx =
  let func = List.hd Sample_programs.clean in
  let env = Taint_propagator.analyze_function func in
  assert_taint "x is untainted"
    Taint_domain.Untainted
    (Taint_propagator.Env.lookup "x" env);
  assert_taint "y is untainted"
    Taint_domain.Untainted
    (Taint_propagator.Env.lookup "y" env)

let test_analyze_branch_taint _ctx =
  let func = List.hd Sample_programs.branch_taint in
  let env = Taint_propagator.analyze_function func in
  assert_taint "input is tainted"
    Taint_domain.Tainted
    (Taint_propagator.Env.lookup "input" env);
  let x = Taint_propagator.Env.lookup "x" env in
  assert_bool "x after branch is potentially tainted"
    (Taint_domain.is_potentially_tainted x)

(* ------------------------------------------------------------------ *)
(* Taint flow tests                                                   *)
(* ------------------------------------------------------------------ *)

let test_taint_through_binop _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [
      Assign ("a", Call ("get_param", [IntLit 0]));
      Assign ("b", IntLit 5);
      Assign ("c", BinOp (Add, Var "a", Var "b"));
    ] } in
  let env = Taint_propagator.analyze_function func in
  assert_taint "c is tainted through binop"
    Taint_domain.Tainted
    (Taint_propagator.Env.lookup "c" env)

let test_taint_overwrite _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [
      Assign ("x", Call ("get_param", [IntLit 0]));
      Assign ("x", IntLit 42);
    ] } in
  let env = Taint_propagator.analyze_function func in
  assert_taint "x overwritten to untainted"
    Taint_domain.Untainted
    (Taint_propagator.Env.lookup "x" env)

let test_params_are_top _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = ["p"];
    body = [] } in
  let env = Taint_propagator.analyze_function func in
  assert_taint "params initialized to top"
    Taint_domain.Top
    (Taint_propagator.Env.lookup "p" env)

let test_unary_propagation _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [
      Assign ("x", Call ("get_param", [IntLit 0]));
      Assign ("y", UnaryOp (Neg, Var "x"));
    ] } in
  let env = Taint_propagator.analyze_function func in
  assert_taint "unary preserves taint"
    Taint_domain.Tainted
    (Taint_propagator.Env.lookup "y" env)

let () =
  run_test_tt_main
    ("Taint Propagation" >::: [
       (* Expression eval: 8 tests *)
       "eval literal"         >:: test_eval_literal;
       "eval bool literal"    >:: test_eval_bool_literal;
       "eval var untainted"   >:: test_eval_var_untainted;
       "eval var tainted"     >:: test_eval_var_tainted;
       "eval source"          >:: test_eval_source;
       "eval sanitizer"       >:: test_eval_sanitizer;
       "eval unknown call"    >:: test_eval_unknown_call;
       "eval binop propagation" >:: test_eval_binop_propagation;
       (* Transfer functions: 6 tests *)
       "transfer assign"      >:: test_transfer_assign;
       "transfer assign literal" >:: test_transfer_assign_literal;
       "transfer if branches" >:: test_transfer_if_both_branches;
       "transfer sequence"    >:: test_transfer_sequence;
       "transfer while"       >:: test_transfer_while;
       "transfer return"      >:: test_transfer_return;
       (* Full analysis: 4 tests *)
       "analyze sql injection" >:: test_analyze_sql_injection;
       "analyze sanitized"    >:: test_analyze_sanitized;
       "analyze clean"        >:: test_analyze_clean;
       "analyze branch taint" >:: test_analyze_branch_taint;
       (* Taint flow: 4 tests *)
       "taint through binop"  >:: test_taint_through_binop;
       "taint overwrite"      >:: test_taint_overwrite;
       "params are top"       >:: test_params_are_top;
       "unary propagation"    >:: test_unary_propagation;
     ])
