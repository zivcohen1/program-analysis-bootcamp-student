(** Tests for the constant propagation domain. *)

open OUnit2
open Constant_prop_ex

module StringMap = Map.Make (String)

(* ------------------------------------------------------------------ *)
(* Helpers                                                            *)
(* ------------------------------------------------------------------ *)

let cv_printer = Constant_domain.to_string

let assert_cv msg expected actual =
  assert_equal ~printer:cv_printer ~msg expected actual

let env_of_list bindings =
  List.fold_left
    (fun acc (k, v) -> StringMap.add k v acc)
    StringMap.empty bindings

(* ------------------------------------------------------------------ *)
(* 1. Flat lattice tests                                              *)
(* ------------------------------------------------------------------ *)

let test_bottom _ctx =
  assert_cv "bottom" Constant_domain.Bot Constant_domain.bottom

let test_top _ctx =
  assert_cv "top" Constant_domain.Top Constant_domain.top

let test_join_same_const _ctx =
  assert_cv "join(Const 3, Const 3) = Const 3"
    (Constant_domain.Const 3)
    (Constant_domain.join (Const 3) (Const 3))

let test_join_diff_const _ctx =
  assert_cv "join(Const 3, Const 5) = Top"
    Constant_domain.Top
    (Constant_domain.join (Const 3) (Const 5))

let test_join_bot _ctx =
  assert_cv "join(Bot, Const 7) = Const 7"
    (Constant_domain.Const 7)
    (Constant_domain.join Bot (Const 7))

let test_meet_same_const _ctx =
  assert_cv "meet(Const 3, Const 3) = Const 3"
    (Constant_domain.Const 3)
    (Constant_domain.meet (Const 3) (Const 3))

let test_meet_diff_const _ctx =
  assert_cv "meet(Const 3, Const 5) = Bot"
    Constant_domain.Bot
    (Constant_domain.meet (Const 3) (Const 5))

let test_meet_top _ctx =
  assert_cv "meet(Top, Const 4) = Const 4"
    (Constant_domain.Const 4)
    (Constant_domain.meet Top (Const 4))

let test_leq _ctx =
  assert_bool "Bot leq Const 5" (Constant_domain.leq Bot (Const 5));
  assert_bool "Const 5 leq Top" (Constant_domain.leq (Const 5) Top);
  assert_bool "Const 5 leq Const 5" (Constant_domain.leq (Const 5) (Const 5));
  assert_bool "not (Const 3 leq Const 5)"
    (not (Constant_domain.leq (Const 3) (Const 5)));
  assert_bool "not (Top leq Const 5)"
    (not (Constant_domain.leq Top (Const 5)))

let test_to_string _ctx =
  assert_equal ~printer:(fun x -> x) "Bot" (Constant_domain.to_string Bot);
  assert_equal ~printer:(fun x -> x) "Const(42)" (Constant_domain.to_string (Const 42));
  assert_equal ~printer:(fun x -> x) "Top" (Constant_domain.to_string Top)

let lattice_suite =
  "Flat Lattice" >::: [
    "bottom"           >:: test_bottom;
    "top"              >:: test_top;
    "join same const"  >:: test_join_same_const;
    "join diff const"  >:: test_join_diff_const;
    "join bot"         >:: test_join_bot;
    "meet same const"  >:: test_meet_same_const;
    "meet diff const"  >:: test_meet_diff_const;
    "meet top"         >:: test_meet_top;
    "leq"              >:: test_leq;
    "to_string"        >:: test_to_string;
  ]

(* ------------------------------------------------------------------ *)
(* 2. Abstract arithmetic tests                                       *)
(* ------------------------------------------------------------------ *)

let test_binop_add _ctx =
  assert_cv "Const(3) + Const(4) = Const(7)"
    (Constant_domain.Const 7)
    (Constant_domain.abstract_binop Shared_ast.Ast_types.Add (Const 3) (Const 4))

let test_binop_mul _ctx =
  assert_cv "Const(3) * Const(4) = Const(12)"
    (Constant_domain.Const 12)
    (Constant_domain.abstract_binop Shared_ast.Ast_types.Mul (Const 3) (Const 4))

let test_binop_div_zero _ctx =
  assert_cv "Const(5) / Const(0) = Bot"
    Constant_domain.Bot
    (Constant_domain.abstract_binop Shared_ast.Ast_types.Div (Const 5) (Const 0))

let test_binop_top _ctx =
  assert_cv "Top + Const(3) = Top"
    Constant_domain.Top
    (Constant_domain.abstract_binop Shared_ast.Ast_types.Add Top (Const 3))

let test_binop_bot _ctx =
  assert_cv "Bot + Const(3) = Bot"
    Constant_domain.Bot
    (Constant_domain.abstract_binop Shared_ast.Ast_types.Add Bot (Const 3))

let test_unaryop_neg _ctx =
  assert_cv "Neg(Const 5) = Const(-5)"
    (Constant_domain.Const (-5))
    (Constant_domain.abstract_unaryop Shared_ast.Ast_types.Neg (Const 5))

let test_binop_eq _ctx =
  assert_cv "Const(3) == Const(3) = Const(1)"
    (Constant_domain.Const 1)
    (Constant_domain.abstract_binop Shared_ast.Ast_types.Eq (Const 3) (Const 3));
  assert_cv "Const(3) == Const(4) = Const(0)"
    (Constant_domain.Const 0)
    (Constant_domain.abstract_binop Shared_ast.Ast_types.Eq (Const 3) (Const 4))

let arith_suite =
  "Arithmetic" >::: [
    "add constants"    >:: test_binop_add;
    "mul constants"    >:: test_binop_mul;
    "div by zero"      >:: test_binop_div_zero;
    "top propagation"  >:: test_binop_top;
    "bot propagation"  >:: test_binop_bot;
    "unary neg"        >:: test_unaryop_neg;
    "equality"         >:: test_binop_eq;
  ]

(* ------------------------------------------------------------------ *)
(* 3. Expression evaluator tests                                      *)
(* ------------------------------------------------------------------ *)

let test_eval_intlit _ctx =
  let env = StringMap.empty in
  assert_cv "eval IntLit 42"
    (Constant_domain.Const 42)
    (Constant_eval.eval_expr env (Shared_ast.Ast_types.IntLit 42))

let test_eval_var_known _ctx =
  let env = env_of_list [("x", Constant_domain.Const 10)] in
  assert_cv "eval Var x (known)"
    (Constant_domain.Const 10)
    (Constant_eval.eval_expr env (Shared_ast.Ast_types.Var "x"))

let test_eval_var_unknown _ctx =
  let env = StringMap.empty in
  assert_cv "eval Var y (unknown)"
    Constant_domain.Top
    (Constant_eval.eval_expr env (Shared_ast.Ast_types.Var "y"))

let test_eval_binop_expr _ctx =
  let open Shared_ast.Ast_types in
  let env = env_of_list [
    ("x", Constant_domain.Const 5);
    ("y", Constant_domain.Const 3);
  ] in
  assert_cv "eval x + y"
    (Constant_domain.Const 8)
    (Constant_eval.eval_expr env (BinOp (Add, Var "x", Var "y")))

let test_eval_nested_expr _ctx =
  let open Shared_ast.Ast_types in
  let env = env_of_list [("a", Constant_domain.Const 2)] in
  assert_cv "eval (a * a) + a"
    (Constant_domain.Const 6)
    (Constant_eval.eval_expr env
       (BinOp (Add, BinOp (Mul, Var "a", Var "a"), Var "a")))

let test_eval_call _ctx =
  let env = StringMap.empty in
  assert_cv "eval Call -> Top"
    Constant_domain.Top
    (Constant_eval.eval_expr env
       (Shared_ast.Ast_types.Call ("f", [IntLit 1])))

let eval_suite =
  "Expression Evaluator" >::: [
    "int literal"       >:: test_eval_intlit;
    "known variable"    >:: test_eval_var_known;
    "unknown variable"  >:: test_eval_var_unknown;
    "binary operation"  >:: test_eval_binop_expr;
    "nested expression" >:: test_eval_nested_expr;
    "function call"     >:: test_eval_call;
  ]

(* ------------------------------------------------------------------ *)
(* Run                                                                *)
(* ------------------------------------------------------------------ *)

let () =
  run_test_tt_main
    ("Constant Propagation" >::: [
       lattice_suite;
       arith_suite;
       eval_suite;
     ])
