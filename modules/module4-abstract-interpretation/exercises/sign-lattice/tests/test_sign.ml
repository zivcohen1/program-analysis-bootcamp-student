(** Tests for the sign abstract domain. *)

open OUnit2
open Sign_lattice_ex

(* ------------------------------------------------------------------ *)
(* Helper                                                             *)
(* ------------------------------------------------------------------ *)

let sign_printer = Sign_domain.to_string

let assert_sign msg expected actual =
  assert_equal ~printer:sign_printer ~msg expected actual

(* ------------------------------------------------------------------ *)
(* 1. Lattice structure tests                                         *)
(* ------------------------------------------------------------------ *)

let test_bottom _ctx =
  assert_sign "bottom should be Bot"
    Sign_domain.Bot Sign_domain.bottom

let test_top _ctx =
  assert_sign "top should be Top"
    Sign_domain.Top Sign_domain.top

let test_join_identity _ctx =
  assert_sign "join(Pos, Bot) = Pos"
    Sign_domain.Pos (Sign_domain.join Sign_domain.Pos Sign_domain.Bot);
  assert_sign "join(Bot, Neg) = Neg"
    Sign_domain.Neg (Sign_domain.join Sign_domain.Bot Sign_domain.Neg)

let test_join_top _ctx =
  assert_sign "join(Pos, Top) = Top"
    Sign_domain.Top (Sign_domain.join Sign_domain.Pos Sign_domain.Top);
  assert_sign "join(Neg, Pos) = Top"
    Sign_domain.Top (Sign_domain.join Sign_domain.Neg Sign_domain.Pos)

let test_join_idempotent _ctx =
  assert_sign "join(Neg, Neg) = Neg"
    Sign_domain.Neg (Sign_domain.join Sign_domain.Neg Sign_domain.Neg)

let test_join_commutative _ctx =
  assert_sign "join(Neg, Zero) = join(Zero, Neg)"
    (Sign_domain.join Sign_domain.Neg Sign_domain.Zero)
    (Sign_domain.join Sign_domain.Zero Sign_domain.Neg)

let test_meet_identity _ctx =
  assert_sign "meet(Pos, Top) = Pos"
    Sign_domain.Pos (Sign_domain.meet Sign_domain.Pos Sign_domain.Top);
  assert_sign "meet(Top, Neg) = Neg"
    Sign_domain.Neg (Sign_domain.meet Sign_domain.Top Sign_domain.Neg)

let test_meet_bot _ctx =
  assert_sign "meet(Pos, Bot) = Bot"
    Sign_domain.Bot (Sign_domain.meet Sign_domain.Pos Sign_domain.Bot);
  assert_sign "meet(Neg, Pos) = Bot"
    Sign_domain.Bot (Sign_domain.meet Sign_domain.Neg Sign_domain.Pos)

let test_leq _ctx =
  assert_bool "Bot leq Pos" (Sign_domain.leq Sign_domain.Bot Sign_domain.Pos);
  assert_bool "Neg leq Top" (Sign_domain.leq Sign_domain.Neg Sign_domain.Top);
  assert_bool "Pos leq Pos" (Sign_domain.leq Sign_domain.Pos Sign_domain.Pos);
  assert_bool "not (Pos leq Neg)" (not (Sign_domain.leq Sign_domain.Pos Sign_domain.Neg));
  assert_bool "not (Top leq Zero)" (not (Sign_domain.leq Sign_domain.Top Sign_domain.Zero))

let test_equal _ctx =
  assert_bool "Pos = Pos" (Sign_domain.equal Sign_domain.Pos Sign_domain.Pos);
  assert_bool "Bot = Bot" (Sign_domain.equal Sign_domain.Bot Sign_domain.Bot);
  assert_bool "Pos <> Neg" (not (Sign_domain.equal Sign_domain.Pos Sign_domain.Neg))

let test_widen _ctx =
  assert_sign "widen = join for finite domain"
    Sign_domain.Top (Sign_domain.widen Sign_domain.Neg Sign_domain.Pos)

let test_to_string _ctx =
  assert_equal ~printer:(fun x -> x) "Pos" (Sign_domain.to_string Sign_domain.Pos);
  assert_equal ~printer:(fun x -> x) "Bot" (Sign_domain.to_string Sign_domain.Bot);
  assert_equal ~printer:(fun x -> x) "Top" (Sign_domain.to_string Sign_domain.Top)

let lattice_suite =
  "Lattice" >::: [
    "bottom"              >:: test_bottom;
    "top"                 >:: test_top;
    "join identity"       >:: test_join_identity;
    "join top"            >:: test_join_top;
    "join idempotent"     >:: test_join_idempotent;
    "join commutative"    >:: test_join_commutative;
    "meet identity"       >:: test_meet_identity;
    "meet bot"            >:: test_meet_bot;
    "leq"                 >:: test_leq;
    "equal"               >:: test_equal;
    "widen"               >:: test_widen;
    "to_string"           >:: test_to_string;
  ]

(* ------------------------------------------------------------------ *)
(* 2. Abstraction function tests                                      *)
(* ------------------------------------------------------------------ *)

let test_alpha_positive _ctx =
  assert_sign "alpha(42) = Pos" Sign_domain.Pos (Sign_domain.alpha_int 42)

let test_alpha_negative _ctx =
  assert_sign "alpha(-7) = Neg" Sign_domain.Neg (Sign_domain.alpha_int (-7))

let test_alpha_zero _ctx =
  assert_sign "alpha(0) = Zero" Sign_domain.Zero (Sign_domain.alpha_int 0)

let alpha_suite =
  "Alpha" >::: [
    "positive" >:: test_alpha_positive;
    "negative" >:: test_alpha_negative;
    "zero"     >:: test_alpha_zero;
  ]

(* ------------------------------------------------------------------ *)
(* 3. Abstract arithmetic tests                                       *)
(* ------------------------------------------------------------------ *)

let test_neg _ctx =
  assert_sign "neg(Pos) = Neg" Sign_domain.Neg (Sign_domain.abstract_neg Sign_domain.Pos);
  assert_sign "neg(Neg) = Pos" Sign_domain.Pos (Sign_domain.abstract_neg Sign_domain.Neg);
  assert_sign "neg(Zero) = Zero" Sign_domain.Zero (Sign_domain.abstract_neg Sign_domain.Zero);
  assert_sign "neg(Bot) = Bot" Sign_domain.Bot (Sign_domain.abstract_neg Sign_domain.Bot)

let test_add _ctx =
  assert_sign "Pos + Pos = Pos" Sign_domain.Pos
    (Sign_domain.abstract_add Sign_domain.Pos Sign_domain.Pos);
  assert_sign "Neg + Neg = Neg" Sign_domain.Neg
    (Sign_domain.abstract_add Sign_domain.Neg Sign_domain.Neg);
  assert_sign "Pos + Neg = Top" Sign_domain.Top
    (Sign_domain.abstract_add Sign_domain.Pos Sign_domain.Neg);
  assert_sign "Zero + Pos = Pos" Sign_domain.Pos
    (Sign_domain.abstract_add Sign_domain.Zero Sign_domain.Pos);
  assert_sign "Bot + Pos = Bot" Sign_domain.Bot
    (Sign_domain.abstract_add Sign_domain.Bot Sign_domain.Pos)

let test_mul _ctx =
  assert_sign "Neg * Neg = Pos" Sign_domain.Pos
    (Sign_domain.abstract_mul Sign_domain.Neg Sign_domain.Neg);
  assert_sign "Pos * Neg = Neg" Sign_domain.Neg
    (Sign_domain.abstract_mul Sign_domain.Pos Sign_domain.Neg);
  assert_sign "Zero * Pos = Zero" Sign_domain.Zero
    (Sign_domain.abstract_mul Sign_domain.Zero Sign_domain.Pos);
  assert_sign "Zero * Top = Zero" Sign_domain.Zero
    (Sign_domain.abstract_mul Sign_domain.Zero Sign_domain.Top)

let test_div _ctx =
  assert_sign "Pos / Pos = Pos" Sign_domain.Pos
    (Sign_domain.abstract_div Sign_domain.Pos Sign_domain.Pos);
  assert_sign "Neg / Neg = Pos" Sign_domain.Pos
    (Sign_domain.abstract_div Sign_domain.Neg Sign_domain.Neg);
  assert_sign "Pos / Zero = Bot" Sign_domain.Bot
    (Sign_domain.abstract_div Sign_domain.Pos Sign_domain.Zero);
  assert_sign "Zero / Pos = Zero" Sign_domain.Zero
    (Sign_domain.abstract_div Sign_domain.Zero Sign_domain.Pos)

let test_sub _ctx =
  assert_sign "Pos - Neg = Pos" Sign_domain.Pos
    (Sign_domain.abstract_sub Sign_domain.Pos Sign_domain.Neg);
  assert_sign "Neg - Pos = Neg" Sign_domain.Neg
    (Sign_domain.abstract_sub Sign_domain.Neg Sign_domain.Pos);
  assert_sign "Pos - Pos = Top" Sign_domain.Top
    (Sign_domain.abstract_sub Sign_domain.Pos Sign_domain.Pos)

let arith_suite =
  "Arithmetic" >::: [
    "negation"       >:: test_neg;
    "addition"       >:: test_add;
    "multiplication" >:: test_mul;
    "division"       >:: test_div;
    "subtraction"    >:: test_sub;
  ]

(* ------------------------------------------------------------------ *)
(* Run all suites                                                     *)
(* ------------------------------------------------------------------ *)

let () =
  run_test_tt_main
    ("Sign Domain" >::: [
       lattice_suite;
       alpha_suite;
       arith_suite;
     ])
