(** Tests for the taint lattice (Exercise 1). *)

open OUnit2
open Taint_lattice_ex

let taint_printer = Taint_domain.to_string
let assert_taint msg expected actual =
  assert_equal ~printer:taint_printer ~msg expected actual

(* ------------------------------------------------------------------ *)
(* Lattice law tests                                                  *)
(* ------------------------------------------------------------------ *)

let test_bottom _ctx =
  assert_taint "bottom is Bot" Taint_domain.Bot Taint_domain.bottom

let test_top _ctx =
  assert_taint "top is Top" Taint_domain.Top Taint_domain.top

let test_join_identity _ctx =
  assert_taint "join Bot x = x" Taint_domain.Tainted
    (Taint_domain.join Taint_domain.Bot Taint_domain.Tainted);
  assert_taint "join x Bot = x" Taint_domain.Untainted
    (Taint_domain.join Taint_domain.Untainted Taint_domain.Bot)

let test_join_same _ctx =
  assert_taint "join Tainted Tainted" Taint_domain.Tainted
    (Taint_domain.join Taint_domain.Tainted Taint_domain.Tainted)

let test_join_different _ctx =
  assert_taint "join Tainted Untainted = Top" Taint_domain.Top
    (Taint_domain.join Taint_domain.Tainted Taint_domain.Untainted)

let test_join_top _ctx =
  assert_taint "join Top x = Top" Taint_domain.Top
    (Taint_domain.join Taint_domain.Top Taint_domain.Tainted)

let test_meet_identity _ctx =
  assert_taint "meet Top x = x" Taint_domain.Tainted
    (Taint_domain.meet Taint_domain.Top Taint_domain.Tainted);
  assert_taint "meet x Top = x" Taint_domain.Untainted
    (Taint_domain.meet Taint_domain.Untainted Taint_domain.Top)

let test_meet_same _ctx =
  assert_taint "meet Tainted Tainted" Taint_domain.Tainted
    (Taint_domain.meet Taint_domain.Tainted Taint_domain.Tainted)

let test_meet_different _ctx =
  assert_taint "meet Tainted Untainted = Bot" Taint_domain.Bot
    (Taint_domain.meet Taint_domain.Tainted Taint_domain.Untainted)

let test_leq _ctx =
  assert_bool "Bot leq everything" (Taint_domain.leq Taint_domain.Bot Taint_domain.Tainted);
  assert_bool "everything leq Top" (Taint_domain.leq Taint_domain.Tainted Taint_domain.Top);
  assert_bool "Tainted leq Tainted" (Taint_domain.leq Taint_domain.Tainted Taint_domain.Tainted);
  assert_bool "Tainted not leq Untainted"
    (not (Taint_domain.leq Taint_domain.Tainted Taint_domain.Untainted))

let test_equal _ctx =
  assert_bool "Bot = Bot" (Taint_domain.equal Taint_domain.Bot Taint_domain.Bot);
  assert_bool "Tainted = Tainted" (Taint_domain.equal Taint_domain.Tainted Taint_domain.Tainted);
  assert_bool "Tainted <> Untainted"
    (not (Taint_domain.equal Taint_domain.Tainted Taint_domain.Untainted))

let test_widen _ctx =
  assert_taint "widen = join" Taint_domain.Top
    (Taint_domain.widen Taint_domain.Tainted Taint_domain.Untainted)

let test_to_string _ctx =
  assert_equal ~printer:Fun.id "Bot" (Taint_domain.to_string Taint_domain.Bot);
  assert_equal ~printer:Fun.id "Tainted" (Taint_domain.to_string Taint_domain.Tainted);
  assert_equal ~printer:Fun.id "Untainted" (Taint_domain.to_string Taint_domain.Untainted);
  assert_equal ~printer:Fun.id "Top" (Taint_domain.to_string Taint_domain.Top)

(* ------------------------------------------------------------------ *)
(* Taint-specific tests                                               *)
(* ------------------------------------------------------------------ *)

let test_is_potentially_tainted _ctx =
  assert_bool "Tainted is potentially tainted"
    (Taint_domain.is_potentially_tainted Taint_domain.Tainted);
  assert_bool "Top is potentially tainted"
    (Taint_domain.is_potentially_tainted Taint_domain.Top);
  assert_bool "Untainted is not potentially tainted"
    (not (Taint_domain.is_potentially_tainted Taint_domain.Untainted));
  assert_bool "Bot is not potentially tainted"
    (not (Taint_domain.is_potentially_tainted Taint_domain.Bot))

let test_propagate_clean _ctx =
  assert_taint "propagate Untainted Untainted = Untainted"
    Taint_domain.Untainted
    (Taint_domain.propagate Taint_domain.Untainted Taint_domain.Untainted)

let test_propagate_tainted _ctx =
  assert_taint "propagate Tainted Untainted = Tainted"
    Taint_domain.Tainted
    (Taint_domain.propagate Taint_domain.Tainted Taint_domain.Untainted);
  assert_taint "propagate Untainted Tainted = Tainted"
    Taint_domain.Tainted
    (Taint_domain.propagate Taint_domain.Untainted Taint_domain.Tainted)

let test_propagate_bot _ctx =
  assert_taint "propagate Bot x = Bot"
    Taint_domain.Bot
    (Taint_domain.propagate Taint_domain.Bot Taint_domain.Tainted)

let test_propagate_top _ctx =
  assert_taint "propagate Top Untainted = Top"
    Taint_domain.Top
    (Taint_domain.propagate Taint_domain.Top Taint_domain.Untainted)

let () =
  run_test_tt_main
    ("Taint Lattice" >::: [
       (* Lattice laws: 12 tests *)
       "bottom"             >:: test_bottom;
       "top"                >:: test_top;
       "join identity"      >:: test_join_identity;
       "join same"          >:: test_join_same;
       "join different"     >:: test_join_different;
       "join top"           >:: test_join_top;
       "meet identity"      >:: test_meet_identity;
       "meet same"          >:: test_meet_same;
       "meet different"     >:: test_meet_different;
       "leq"                >:: test_leq;
       "equal"              >:: test_equal;
       "widen"              >:: test_widen;
       "to_string"          >:: test_to_string;
       (* Taint-specific: 5 tests *)
       "is_potentially_tainted" >:: test_is_potentially_tainted;
       "propagate clean"    >:: test_propagate_clean;
       "propagate tainted"  >:: test_propagate_tainted;
       "propagate bot"      >:: test_propagate_bot;
       "propagate top"      >:: test_propagate_top;
     ])
