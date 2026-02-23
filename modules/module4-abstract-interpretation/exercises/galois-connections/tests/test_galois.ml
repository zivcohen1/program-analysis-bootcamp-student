(** Tests for Galois connections. *)

open OUnit2
open Galois_ex

(* ------------------------------------------------------------------ *)
(* Helpers                                                            *)
(* ------------------------------------------------------------------ *)

let intset_of_list xs = Galois.IntSet.of_list xs

let sign_printer = Galois.sign_to_string

let assert_sign msg expected actual =
  assert_equal ~printer:sign_printer ~msg expected actual

(* ------------------------------------------------------------------ *)
(* 1. Alpha correctness                                               *)
(* ------------------------------------------------------------------ *)

let test_alpha_empty _ctx =
  assert_sign "alpha({}) = Bot"
    Galois.Bot (Galois.alpha (intset_of_list []))

let test_alpha_positives _ctx =
  assert_sign "alpha({1,2,3}) = Pos"
    Galois.Pos (Galois.alpha (intset_of_list [1; 2; 3]))

let test_alpha_negatives _ctx =
  assert_sign "alpha({-5,-1}) = Neg"
    Galois.Neg (Galois.alpha (intset_of_list [-5; -1]))

let test_alpha_zero _ctx =
  assert_sign "alpha({0}) = Zero"
    Galois.Zero (Galois.alpha (intset_of_list [0]))

let test_alpha_mixed _ctx =
  assert_sign "alpha({-1,0,1}) = Top"
    Galois.Top (Galois.alpha (intset_of_list [-1; 0; 1]))

let test_alpha_neg_zero _ctx =
  assert_sign "alpha({-3, 0}) = Top"
    Galois.Top (Galois.alpha (intset_of_list [-3; 0]))

let alpha_suite =
  "Alpha" >::: [
    "empty set"   >:: test_alpha_empty;
    "positives"   >:: test_alpha_positives;
    "negatives"   >:: test_alpha_negatives;
    "zero"        >:: test_alpha_zero;
    "mixed"       >:: test_alpha_mixed;
    "neg and zero" >:: test_alpha_neg_zero;
  ]

(* ------------------------------------------------------------------ *)
(* 2. Gamma correctness                                               *)
(* ------------------------------------------------------------------ *)

let test_gamma_bot _ctx =
  let (s, exact) = Galois.gamma_repr Galois.Bot in
  assert_bool "gamma(Bot) is empty" (Galois.IntSet.is_empty s);
  assert_bool "gamma(Bot) is exact" exact

let test_gamma_zero _ctx =
  let (s, exact) = Galois.gamma_repr Galois.Zero in
  assert_bool "gamma(Zero) contains 0" (Galois.IntSet.mem 0 s);
  assert_equal ~printer:string_of_int 1 (Galois.IntSet.cardinal s);
  assert_bool "gamma(Zero) is exact" exact

let test_in_gamma _ctx =
  assert_bool "5 in gamma(Pos)" (Galois.in_gamma 5 Galois.Pos);
  assert_bool "-3 in gamma(Neg)" (Galois.in_gamma (-3) Galois.Neg);
  assert_bool "0 in gamma(Zero)" (Galois.in_gamma 0 Galois.Zero);
  assert_bool "42 in gamma(Top)" (Galois.in_gamma 42 Galois.Top);
  assert_bool "not (0 in gamma(Pos))" (not (Galois.in_gamma 0 Galois.Pos));
  assert_bool "not (1 in gamma(Neg))" (not (Galois.in_gamma 1 Galois.Neg));
  assert_bool "not (5 in gamma(Bot))" (not (Galois.in_gamma 5 Galois.Bot))

let gamma_suite =
  "Gamma" >::: [
    "gamma Bot"   >:: test_gamma_bot;
    "gamma Zero"  >:: test_gamma_zero;
    "in_gamma"    >:: test_in_gamma;
  ]

(* ------------------------------------------------------------------ *)
(* 3. Adjunction property                                             *)
(* ------------------------------------------------------------------ *)

let test_adjunction_pos_pos _ctx =
  assert_bool "adjunction({1,2}, Pos)"
    (Galois.verify_adjunction (intset_of_list [1; 2]) Galois.Pos)

let test_adjunction_pos_neg _ctx =
  assert_bool "adjunction({1,2}, Neg)"
    (Galois.verify_adjunction (intset_of_list [1; 2]) Galois.Neg)

let test_adjunction_empty_bot _ctx =
  assert_bool "adjunction({}, Bot)"
    (Galois.verify_adjunction (intset_of_list []) Galois.Bot)

let test_adjunction_zero_pos _ctx =
  assert_bool "adjunction({0}, Pos)"
    (Galois.verify_adjunction (intset_of_list [0]) Galois.Pos)

let test_adjunction_mixed_top _ctx =
  assert_bool "adjunction({-1,0,1}, Top)"
    (Galois.verify_adjunction (intset_of_list [-1; 0; 1]) Galois.Top)

let adjunction_suite =
  "Adjunction" >::: [
    "{1,2} vs Pos"     >:: test_adjunction_pos_pos;
    "{1,2} vs Neg"     >:: test_adjunction_pos_neg;
    "{} vs Bot"        >:: test_adjunction_empty_bot;
    "{0} vs Pos"       >:: test_adjunction_zero_pos;
    "{-1,0,1} vs Top"  >:: test_adjunction_mixed_top;
  ]

(* ------------------------------------------------------------------ *)
(* 4. Monotonicity                                                    *)
(* ------------------------------------------------------------------ *)

let test_monotone_subset _ctx =
  assert_bool "monotone: {1,2} subset {1,2,-3}"
    (Galois.verify_alpha_monotone
       (intset_of_list [1; 2]) (intset_of_list [1; 2; -3]))

let test_monotone_empty _ctx =
  assert_bool "monotone: {} subset {5}"
    (Galois.verify_alpha_monotone
       (intset_of_list []) (intset_of_list [5]))

let monotone_suite =
  "Monotonicity" >::: [
    "subset grows"  >:: test_monotone_subset;
    "empty subset"  >:: test_monotone_empty;
  ]

(* ------------------------------------------------------------------ *)
(* Run                                                                *)
(* ------------------------------------------------------------------ *)

let () =
  run_test_tt_main
    ("Galois Connections" >::: [
       alpha_suite;
       gamma_suite;
       adjunction_suite;
       monotone_suite;
     ])
