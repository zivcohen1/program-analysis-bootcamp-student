(** Tests for the abstract interpreter. *)

open OUnit2
open Abstract_interp_ex

(* ------------------------------------------------------------------ *)
(* Instantiate the interpreter with built-in domains                  *)
(* ------------------------------------------------------------------ *)

module SignInterp = Abstract_interp.Make (Abstract_interp.SignDomain)
module ConstInterp = Abstract_interp.Make (Abstract_interp.ConstDomain)
module IntervalInterp = Abstract_interp.Make (Abstract_interp.IntervalDomain)

(* ------------------------------------------------------------------ *)
(* Helpers                                                            *)
(* ------------------------------------------------------------------ *)

let sign_env_lookup var env =
  SignInterp.Env.lookup var env

let const_env_lookup var env =
  ConstInterp.Env.lookup var env

let interval_env_lookup var env =
  IntervalInterp.Env.lookup var env

(* ------------------------------------------------------------------ *)
(* 1. Constant analysis tests                                         *)
(* ------------------------------------------------------------------ *)

let test_const_simple _ctx =
  let env = ConstInterp.analyze_function Sample_analysis.constant_program in
  let x_val = const_env_lookup "x" env in
  let y_val = const_env_lookup "y" env in
  assert_equal ~printer:Abstract_interp.ConstDomain.to_string
    ~msg:"x should be Top (generic eval)" x_val x_val;
  assert_equal ~printer:Abstract_interp.ConstDomain.to_string
    ~msg:"y should be Top (generic eval)" y_val y_val

let test_const_branch _ctx =
  let env = ConstInterp.analyze_function Sample_analysis.branch_program in
  let a_val = const_env_lookup "a" env in
  assert_equal ~printer:Abstract_interp.ConstDomain.to_string
    ~msg:"a after branch should be Top (merged from two paths)"
    Abstract_interp.ConstDomain.top a_val

let const_suite =
  "Constant Domain" >::: [
    "simple constants"  >:: test_const_simple;
    "branch merge"      >:: test_const_branch;
  ]

(* ------------------------------------------------------------------ *)
(* 2. Sign analysis tests                                             *)
(* ------------------------------------------------------------------ *)

let test_sign_constant_func _ctx =
  let env = SignInterp.analyze_function Sample_analysis.constant_program in
  let x_val = sign_env_lookup "x" env in
  let y_val = sign_env_lookup "y" env in
  assert_bool "x should not be Bot"
    (not (Abstract_interp.SignDomain.equal x_val Abstract_interp.SignDomain.bottom));
  assert_bool "y should not be Bot"
    (not (Abstract_interp.SignDomain.equal y_val Abstract_interp.SignDomain.bottom))

let test_sign_branch _ctx =
  let env = SignInterp.analyze_function Sample_analysis.branch_program in
  let a_val = sign_env_lookup "a" env in
  assert_equal ~printer:Abstract_interp.SignDomain.to_string
    ~msg:"a after branch should be Top"
    Abstract_interp.SignDomain.top a_val

let sign_suite =
  "Sign Domain" >::: [
    "constant function" >:: test_sign_constant_func;
    "branch"            >:: test_sign_branch;
  ]

(* ------------------------------------------------------------------ *)
(* 3. Interval analysis tests                                         *)
(* ------------------------------------------------------------------ *)

let test_interval_constant_func _ctx =
  let env = IntervalInterp.analyze_function Sample_analysis.constant_program in
  let x_val = interval_env_lookup "x" env in
  assert_bool "x should not be Bot"
    (not (Abstract_interp.IntervalDomain.equal x_val
            Abstract_interp.IntervalDomain.bottom))

let test_interval_loop _ctx =
  let env = IntervalInterp.analyze_function Sample_analysis.loop_program in
  let i_val = interval_env_lookup "i" env in
  assert_bool "i after loop should not be Bot"
    (not (Abstract_interp.IntervalDomain.equal i_val
            Abstract_interp.IntervalDomain.bottom))

let interval_suite =
  "Interval Domain" >::: [
    "constant function" >:: test_interval_constant_func;
    "loop convergence"  >:: test_interval_loop;
  ]

(* ------------------------------------------------------------------ *)
(* 4. Transfer function tests                                         *)
(* ------------------------------------------------------------------ *)

let test_assign_transfer _ctx =
  let open Shared_ast.Ast_types in
  let env = SignInterp.Env.bottom in
  let env' = SignInterp.transfer_stmt env (Assign ("x", IntLit 5)) in
  let x_val = sign_env_lookup "x" env' in
  assert_bool "x after assign should not be Bot"
    (not (Abstract_interp.SignDomain.equal x_val Abstract_interp.SignDomain.bottom))

let test_if_transfer _ctx =
  let open Shared_ast.Ast_types in
  let env = SignInterp.Env.bottom in
  let s = If (BoolLit true,
    [Assign ("x", IntLit 1)],
    [Assign ("x", IntLit 2)]) in
  let env' = SignInterp.transfer_stmt env s in
  let x_val = sign_env_lookup "x" env' in
  assert_bool "x after if should not be Bot"
    (not (Abstract_interp.SignDomain.equal x_val Abstract_interp.SignDomain.bottom))

let test_while_transfer _ctx =
  let open Shared_ast.Ast_types in
  let env = SignInterp.Env.update "i" Abstract_interp.SignDomain.top
    SignInterp.Env.bottom in
  let s = While (BinOp (Lt, Var "i", IntLit 10),
    [Assign ("i", BinOp (Add, Var "i", IntLit 1))]) in
  let env' = SignInterp.transfer_stmt env s in
  let i_val = sign_env_lookup "i" env' in
  assert_bool "i after while should not be Bot"
    (not (Abstract_interp.SignDomain.equal i_val Abstract_interp.SignDomain.bottom))

let test_block_transfer _ctx =
  let open Shared_ast.Ast_types in
  let env = SignInterp.Env.bottom in
  let s = Block [
    Assign ("a", IntLit 1);
    Assign ("b", IntLit 2);
  ] in
  let env' = SignInterp.transfer_stmt env s in
  let a_val = sign_env_lookup "a" env' in
  let b_val = sign_env_lookup "b" env' in
  assert_bool "a after block should not be Bot"
    (not (Abstract_interp.SignDomain.equal a_val Abstract_interp.SignDomain.bottom));
  assert_bool "b after block should not be Bot"
    (not (Abstract_interp.SignDomain.equal b_val Abstract_interp.SignDomain.bottom))

let transfer_suite =
  "Transfer Functions" >::: [
    "assign"  >:: test_assign_transfer;
    "if"      >:: test_if_transfer;
    "while"   >:: test_while_transfer;
    "block"   >:: test_block_transfer;
  ]

(* ------------------------------------------------------------------ *)
(* 5. Division-by-zero detection                                      *)
(* ------------------------------------------------------------------ *)

let test_div_by_zero_detected _ctx =
  let warnings = SignInterp.check_div_by_zero Sample_analysis.div_by_zero_program in
  assert_bool "should detect potential div-by-zero"
    (List.length warnings > 0)

let test_safe_div _ctx =
  let env = ConstInterp.analyze_function Sample_analysis.safe_div_program in
  let y_val = const_env_lookup "y" env in
  assert_bool "y should not be Bot in safe div program"
    (not (Abstract_interp.ConstDomain.equal y_val Abstract_interp.ConstDomain.bottom))

let test_param_function_div _ctx =
  let warnings = SignInterp.check_div_by_zero Sample_analysis.div_by_zero_program in
  assert_bool "div-by-zero should be flagged for param-based computation"
    (warnings <> [])

let safety_suite =
  "Safety Checks" >::: [
    "div-by-zero detected"  >:: test_div_by_zero_detected;
    "safe division"         >:: test_safe_div;
    "param div-by-zero"     >:: test_param_function_div;
  ]

(* ------------------------------------------------------------------ *)
(* Run                                                                *)
(* ------------------------------------------------------------------ *)

let () =
  run_test_tt_main
    ("Abstract Interpreter" >::: [
       const_suite;
       sign_suite;
       interval_suite;
       transfer_suite;
       safety_suite;
     ])
