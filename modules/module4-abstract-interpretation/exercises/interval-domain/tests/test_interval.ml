(** Tests for the interval abstract domain. *)

open OUnit2
open Interval_domain_ex

module StringMap = Map.Make (String)

(* ------------------------------------------------------------------ *)
(* Helpers                                                            *)
(* ------------------------------------------------------------------ *)

let iv_printer = Interval_domain.to_string

let assert_iv msg expected actual =
  assert_equal ~printer:iv_printer ~msg expected actual

let mk (lo : int) (hi : int) : Interval_domain.interval =
  Interval_domain.Interval (Finite lo, Finite hi)

let env_of_list bindings =
  List.fold_left
    (fun acc (k, v) -> StringMap.add k v acc)
    StringMap.empty bindings

(* ------------------------------------------------------------------ *)
(* 1. Bound arithmetic                                                *)
(* ------------------------------------------------------------------ *)

let test_add_bound_finite _ctx =
  assert_equal (Interval_domain.Finite 7)
    (Interval_domain.add_bound (Finite 3) (Finite 4))

let test_add_bound_inf _ctx =
  assert_equal Interval_domain.NegInf
    (Interval_domain.add_bound NegInf (Finite 5))

let test_neg_bound _ctx =
  assert_equal (Interval_domain.Finite (-3))
    (Interval_domain.neg_bound (Finite 3));
  assert_equal Interval_domain.NegInf
    (Interval_domain.neg_bound PosInf)

let test_min_max_bound _ctx =
  assert_equal (Interval_domain.Finite 2)
    (Interval_domain.min_bound (Finite 2) (Finite 5));
  assert_equal (Interval_domain.Finite 5)
    (Interval_domain.max_bound (Finite 2) (Finite 5));
  assert_equal Interval_domain.NegInf
    (Interval_domain.min_bound NegInf (Finite 0))

let bound_suite =
  "Bounds" >::: [
    "add finite"  >:: test_add_bound_finite;
    "add inf"     >:: test_add_bound_inf;
    "neg"         >:: test_neg_bound;
    "min/max"     >:: test_min_max_bound;
  ]

(* ------------------------------------------------------------------ *)
(* 2. Lattice operations                                              *)
(* ------------------------------------------------------------------ *)

let test_bottom _ctx =
  assert_iv "bottom" Interval_domain.Bot Interval_domain.bottom

let test_top _ctx =
  assert_iv "top" (Interval (NegInf, PosInf)) Interval_domain.top

let test_join_bot _ctx =
  assert_iv "join(Bot, [1,5]) = [1,5]"
    (mk 1 5) (Interval_domain.join Bot (mk 1 5))

let test_join_intervals _ctx =
  assert_iv "join([1,5], [3,8]) = [1,8]"
    (mk 1 8) (Interval_domain.join (mk 1 5) (mk 3 8))

let test_join_disjoint _ctx =
  assert_iv "join([1,3], [7,9]) = [1,9]"
    (mk 1 9) (Interval_domain.join (mk 1 3) (mk 7 9))

let test_meet_overlap _ctx =
  assert_iv "meet([1,5], [3,8]) = [3,5]"
    (mk 3 5) (Interval_domain.meet (mk 1 5) (mk 3 8))

let test_meet_disjoint _ctx =
  assert_iv "meet([1,3], [5,7]) = Bot"
    Bot (Interval_domain.meet (mk 1 3) (mk 5 7))

let test_leq _ctx =
  assert_bool "[2,4] leq [1,5]"
    (Interval_domain.leq (mk 2 4) (mk 1 5));
  assert_bool "Bot leq [1,5]"
    (Interval_domain.leq Bot (mk 1 5));
  assert_bool "not ([1,5] leq [2,4])"
    (not (Interval_domain.leq (mk 1 5) (mk 2 4)))

let test_leq_inf _ctx =
  let open Interval_domain in
  assert_bool "[1,5] leq [-inf,+inf]"
    (leq (mk 1 5) (Interval (NegInf, PosInf)));
  assert_bool "[-inf,+inf] leq [-inf,+inf]"
    (leq (Interval (NegInf, PosInf)) (Interval (NegInf, PosInf)))

let test_equal _ctx =
  assert_bool "[1,5] = [1,5]"
    (Interval_domain.equal (mk 1 5) (mk 1 5));
  assert_bool "[1,5] <> [1,6]"
    (not (Interval_domain.equal (mk 1 5) (mk 1 6)))

let test_to_string _ctx =
  assert_equal ~printer:(fun x -> x) "Bot" (Interval_domain.to_string Bot);
  assert_equal ~printer:(fun x -> x) "[1, 5]" (Interval_domain.to_string (mk 1 5));
  assert_equal ~printer:(fun x -> x) "[-inf, +inf]"
    (Interval_domain.to_string (Interval (NegInf, PosInf)))

let lattice_suite =
  "Lattice" >::: [
    "bottom"         >:: test_bottom;
    "top"            >:: test_top;
    "join bot"       >:: test_join_bot;
    "join overlap"   >:: test_join_intervals;
    "join disjoint"  >:: test_join_disjoint;
    "meet overlap"   >:: test_meet_overlap;
    "meet disjoint"  >:: test_meet_disjoint;
    "leq"            >:: test_leq;
    "leq inf"        >:: test_leq_inf;
    "equal"          >:: test_equal;
    "to_string"      >:: test_to_string;
  ]

(* ------------------------------------------------------------------ *)
(* 3. Widening                                                        *)
(* ------------------------------------------------------------------ *)

let test_widen_grows_upper _ctx =
  assert_iv "widen([0,5], [0,10]) = [0,+inf]"
    (Interval_domain.Interval (Finite 0, PosInf))
    (Interval_domain.widen (mk 0 5) (mk 0 10))

let test_widen_grows_lower _ctx =
  assert_iv "widen([0,5], [-1,5]) = [-inf,5]"
    (Interval_domain.Interval (NegInf, Finite 5))
    (Interval_domain.widen (mk 0 5) (mk (-1) 5))

let test_widen_stable _ctx =
  assert_iv "widen([0,5], [1,3]) = [0,5]"
    (mk 0 5) (Interval_domain.widen (mk 0 5) (mk 1 3))

let test_widen_both_grow _ctx =
  assert_iv "widen([0,5], [-1,10]) = [-inf,+inf]"
    (Interval_domain.Interval (NegInf, PosInf))
    (Interval_domain.widen (mk 0 5) (mk (-1) 10))

let widen_suite =
  "Widening" >::: [
    "upper grows"  >:: test_widen_grows_upper;
    "lower grows"  >:: test_widen_grows_lower;
    "stable"       >:: test_widen_stable;
    "both grow"    >:: test_widen_both_grow;
  ]

(* ------------------------------------------------------------------ *)
(* 4. Queries                                                         *)
(* ------------------------------------------------------------------ *)

let test_contains_zero _ctx =
  assert_bool "[−5,5] contains zero"
    (Interval_domain.contains_zero (mk (-5) 5));
  assert_bool "[0,0] contains zero"
    (Interval_domain.contains_zero (mk 0 0));
  assert_bool "[1,10] does not contain zero"
    (not (Interval_domain.contains_zero (mk 1 10)));
  assert_bool "Bot does not contain zero"
    (not (Interval_domain.contains_zero Bot))

let test_is_non_negative _ctx =
  assert_bool "[0,10] is non-negative"
    (Interval_domain.is_non_negative (mk 0 10));
  assert_bool "[1,5] is non-negative"
    (Interval_domain.is_non_negative (mk 1 5));
  assert_bool "[-1,5] is not non-negative"
    (not (Interval_domain.is_non_negative (mk (-1) 5)))

let query_suite =
  "Queries" >::: [
    "contains_zero"   >:: test_contains_zero;
    "is_non_negative" >:: test_is_non_negative;
  ]

(* ------------------------------------------------------------------ *)
(* 5. Abstract arithmetic                                             *)
(* ------------------------------------------------------------------ *)

let test_add _ctx =
  assert_iv "[1,5] + [2,3] = [3,8]"
    (mk 3 8) (Interval_domain.abstract_add (mk 1 5) (mk 2 3))

let test_sub _ctx =
  assert_iv "[5,10] - [1,3] = [2,9]"
    (mk 2 9) (Interval_domain.abstract_sub (mk 5 10) (mk 1 3))

let test_neg _ctx =
  assert_iv "neg([1,5]) = [-5,-1]"
    (mk (-5) (-1)) (Interval_domain.abstract_neg (mk 1 5))

let test_mul _ctx =
  assert_iv "[1,3] * [2,4] = [2,12]"
    (mk 2 12) (Interval_domain.abstract_mul (mk 1 3) (mk 2 4));
  assert_iv "[-1,2] * [3,4] = [-4,8]"
    (mk (-4) 8) (Interval_domain.abstract_mul (mk (-1) 2) (mk 3 4))

let test_bot_propagation _ctx =
  assert_iv "Bot + [1,5] = Bot"
    Bot (Interval_domain.abstract_add Bot (mk 1 5));
  assert_iv "[1,5] * Bot = Bot"
    Bot (Interval_domain.abstract_mul (mk 1 5) Bot)

let arith_suite =
  "Arithmetic" >::: [
    "add"             >:: test_add;
    "sub"             >:: test_sub;
    "neg"             >:: test_neg;
    "mul"             >:: test_mul;
    "bot propagation" >:: test_bot_propagation;
  ]

(* ------------------------------------------------------------------ *)
(* 6. Expression evaluator                                            *)
(* ------------------------------------------------------------------ *)

let test_eval_intlit _ctx =
  let env = StringMap.empty in
  assert_iv "eval 42"
    (mk 42 42) (Interval_eval.eval_expr env (Shared_ast.Ast_types.IntLit 42))

let test_eval_add_expr _ctx =
  let env = env_of_list [
    ("x", mk 1 5);
    ("y", mk 2 3);
  ] in
  assert_iv "eval x + y"
    (mk 3 8) (Interval_eval.eval_expr env
      (Shared_ast.Ast_types.BinOp (Add, Var "x", Var "y")))

let eval_suite =
  "Eval" >::: [
    "int literal"  >:: test_eval_intlit;
    "add vars"     >:: test_eval_add_expr;
  ]

(* ------------------------------------------------------------------ *)
(* Run                                                                *)
(* ------------------------------------------------------------------ *)

let () =
  run_test_tt_main
    ("Interval Domain" >::: [
       bound_suite;
       lattice_suite;
       widen_suite;
       query_suite;
       arith_suite;
       eval_suite;
     ])
