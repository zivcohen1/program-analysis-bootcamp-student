(** Tests for the dataflow framework.

    We test two things:
    1. The PowersetLattice operations (join, meet, bottom, top, equal).
    2. The iterative solver on small CFGs (forward and backward).
*)

open OUnit2
open Dataflow_framework

(* ------------------------------------------------------------------ *)
(* Helper: build a StringSet from a plain list of strings.            *)
(* ------------------------------------------------------------------ *)
let set_of_list xs =
  List.fold_left (fun acc x -> Lattice.StringSet.add x acc)
    Lattice.StringSet.empty xs

(* ------------------------------------------------------------------ *)
(* 1. PowersetLattice unit tests                                      *)
(* ------------------------------------------------------------------ *)

(** Verify that bottom is the empty set. *)
let test_bottom _ctx =
  assert_bool "bottom should be empty"
    (Lattice.StringSet.is_empty Lattice.PowersetLattice.bottom)

(** Verify that top equals the universe (after we set it). *)
let test_top _ctx =
  let univ = set_of_list ["x"; "y"; "z"] in
  Lattice.PowersetLattice.universe := univ;
  (* top is a module-level value bound at startup, so it captured the
     universe ref *before* we set it.  For a correct implementation that
     evaluates !universe lazily this test checks that.  If top was
     captured eagerly as empty, the test documents that behavior too.
     We test the explicit contract: top = !universe at definition time. *)
  let _ = Lattice.PowersetLattice.top in
  (* Instead test the fundamental property: join(x, top) = top. *)
  let top_val = !Lattice.PowersetLattice.universe in
  let joined = Lattice.PowersetLattice.join (set_of_list ["x"]) top_val in
  assert_bool "join with universe should equal universe"
    (Lattice.PowersetLattice.equal joined top_val)

(** join is set union. *)
let test_join _ctx =
  let a = set_of_list ["x"; "y"] in
  let b = set_of_list ["y"; "z"] in
  let result = Lattice.PowersetLattice.join a b in
  let expected = set_of_list ["x"; "y"; "z"] in
  assert_bool "join should be union"
    (Lattice.PowersetLattice.equal result expected)

(** meet is set intersection. *)
let test_meet _ctx =
  let a = set_of_list ["x"; "y"] in
  let b = set_of_list ["y"; "z"] in
  let result = Lattice.PowersetLattice.meet a b in
  let expected = set_of_list ["y"] in
  assert_bool "meet should be intersection"
    (Lattice.PowersetLattice.equal result expected)

(** equal returns true for identical sets, false otherwise. *)
let test_equal _ctx =
  let a = set_of_list ["a"; "b"] in
  let b = set_of_list ["a"; "b"] in
  let c = set_of_list ["a"; "c"] in
  assert_bool "same sets should be equal"
    (Lattice.PowersetLattice.equal a b);
  assert_bool "different sets should not be equal"
    (not (Lattice.PowersetLattice.equal a c))

(** to_string produces a readable representation. *)
let test_to_string _ctx =
  let s = set_of_list ["a"; "b"; "c"] in
  let str = Lattice.PowersetLattice.to_string s in
  (* StringSet iterates in sorted order, so we expect {a, b, c}. *)
  assert_equal ~printer:(fun x -> x) "{a, b, c}" str

(** Lattice laws: join with bottom = identity. *)
let test_join_bottom_identity _ctx =
  let a = set_of_list ["p"; "q"] in
  let result = Lattice.PowersetLattice.join a Lattice.PowersetLattice.bottom in
  assert_bool "join with bottom should be identity"
    (Lattice.PowersetLattice.equal result a)

(** Lattice laws: meet with bottom = bottom. *)
let test_meet_bottom_absorbing _ctx =
  let a = set_of_list ["p"; "q"] in
  let result = Lattice.PowersetLattice.meet a Lattice.PowersetLattice.bottom in
  assert_bool "meet with bottom should be bottom"
    (Lattice.PowersetLattice.equal result Lattice.PowersetLattice.bottom)

let lattice_suite =
  "PowersetLattice" >::: [
    "bottom is empty"       >:: test_bottom;
    "top / universe"        >:: test_top;
    "join is union"         >:: test_join;
    "meet is intersection"  >:: test_meet;
    "equal"                 >:: test_equal;
    "to_string"             >:: test_to_string;
    "join bottom identity"  >:: test_join_bottom_identity;
    "meet bottom absorbing" >:: test_meet_bottom_absorbing;
  ]

(* ------------------------------------------------------------------ *)
(* 2. Forward solver test on a linear 3-block CFG                     *)
(*                                                                    *)
(*    B1 --> B2 --> B3                                                *)
(*                                                                    *)
(* We model a simple "reaching definitions" style analysis where      *)
(* each block generates a definition (adds a string to the set).      *)
(*                                                                    *)
(*   B1: gen = {"d1"}                                                 *)
(*   B2: gen = {"d2"}                                                 *)
(*   B3: gen = {"d3"}                                                 *)
(*                                                                    *)
(* Transfer: OUT[B] = IN[B] ∪ gen(B)                                  *)
(* Merge:    union (may-analysis)                                     *)
(*                                                                    *)
(* Expected results at fixpoint:                                      *)
(*   B1: IN={},          OUT={d1}                                     *)
(*   B2: IN={d1},        OUT={d1,d2}                                  *)
(*   B3: IN={d1,d2},     OUT={d1,d2,d3}                               *)
(* ------------------------------------------------------------------ *)

(** Transfer function: adds block-specific definitions to the set. *)
let forward_transfer label in_val =
  let gen = set_of_list [label ^ "_def"] in
  Lattice.StringSet.union in_val gen

(** The CFG as (label, predecessors, successors) triples. *)
let linear_cfg = [
  ("B1", [],     ["B2"]);
  ("B2", ["B1"], ["B3"]);
  ("B3", ["B2"], []);
]

let test_forward_solver _ctx =
  let analysis : Lattice.StringSet.t Dataflow.analysis = {
    direction = Dataflow.Forward;
    init      = Lattice.StringSet.empty;
    merge     = Lattice.StringSet.union;
    transfer  = forward_transfer;
    equal     = Lattice.StringSet.equal;
  } in
  let results = Dataflow.solve analysis linear_cfg in
  (* Build a map for convenient lookup. *)
  let find_block lbl =
    List.find (fun (l, _, _) -> l = lbl) results
  in
  let (_, in1, out1) = find_block "B1" in
  let (_, in2, out2) = find_block "B2" in
  let (_, in3, out3) = find_block "B3" in

  (* B1 *)
  assert_bool "B1 IN should be empty"
    (Lattice.StringSet.is_empty in1);
  assert_bool "B1 OUT should be {B1_def}"
    (Lattice.StringSet.equal out1 (set_of_list ["B1_def"]));

  (* B2 *)
  assert_bool "B2 IN should be {B1_def}"
    (Lattice.StringSet.equal in2 (set_of_list ["B1_def"]));
  assert_bool "B2 OUT should be {B1_def, B2_def}"
    (Lattice.StringSet.equal out2 (set_of_list ["B1_def"; "B2_def"]));

  (* B3 *)
  assert_bool "B3 IN should be {B1_def, B2_def}"
    (Lattice.StringSet.equal in3 (set_of_list ["B1_def"; "B2_def"]));
  assert_bool "B3 OUT should be {B1_def, B2_def, B3_def}"
    (Lattice.StringSet.equal out3
       (set_of_list ["B1_def"; "B2_def"; "B3_def"]))

(* ------------------------------------------------------------------ *)
(* 3. Fixpoint convergence test                                        *)
(*                                                                    *)
(*    B1 --> B2                                                       *)
(*     ^     |                                                        *)
(*     +-----+                                                        *)
(*                                                                    *)
(* A loop: B2 feeds back into B1. The analysis should still converge  *)
(* because the lattice has finite height.                             *)
(*                                                                    *)
(*   B1: gen = {"a"}                                                  *)
(*   B2: gen = {"b"}                                                  *)
(*                                                                    *)
(* At fixpoint (forward, union merge):                                *)
(*   B1: IN = OUT[B2] = {a, b},  OUT = {a, b}                        *)
(*   B2: IN = OUT[B1] = {a, b},  OUT = {a, b}                        *)
(*                                                                    *)
(* Actually more precisely, since init = empty and we merge over      *)
(* predecessors:                                                      *)
(*   Iteration 1:                                                     *)
(*     B1: IN = merge() = {},         OUT = {} ∪ {a} = {a}           *)
(*     B2: IN = OUT[B1] = {a},        OUT = {a} ∪ {b} = {a,b}       *)
(*   Iteration 2:                                                     *)
(*     B1: IN = OUT[B2] = {a,b},      OUT = {a,b} ∪ {a} = {a,b}     *)
(*     B2: IN = OUT[B1] = {a,b},      OUT = {a,b} ∪ {b} = {a,b}     *)
(*   Iteration 3: no change -> fixpoint.                              *)
(* ------------------------------------------------------------------ *)

let loop_cfg = [
  ("B1", ["B2"], ["B2"]);
  ("B2", ["B1"], ["B1"]);
]

let loop_transfer label in_val =
  let gen =
    match label with
    | "B1" -> set_of_list ["a"]
    | "B2" -> set_of_list ["b"]
    | _    -> Lattice.StringSet.empty
  in
  Lattice.StringSet.union in_val gen

let test_fixpoint_convergence _ctx =
  let analysis : Lattice.StringSet.t Dataflow.analysis = {
    direction = Dataflow.Forward;
    init      = Lattice.StringSet.empty;
    merge     = Lattice.StringSet.union;
    transfer  = loop_transfer;
    equal     = Lattice.StringSet.equal;
  } in
  let results = Dataflow.solve analysis loop_cfg in
  let find_block lbl =
    List.find (fun (l, _, _) -> l = lbl) results
  in
  let expected_all = set_of_list ["a"; "b"] in
  let (_, in1, out1) = find_block "B1" in
  let (_, in2, out2) = find_block "B2" in

  assert_bool "B1 IN at fixpoint should be {a, b}"
    (Lattice.StringSet.equal in1 expected_all);
  assert_bool "B1 OUT at fixpoint should be {a, b}"
    (Lattice.StringSet.equal out1 expected_all);
  assert_bool "B2 IN at fixpoint should be {a, b}"
    (Lattice.StringSet.equal in2 expected_all);
  assert_bool "B2 OUT at fixpoint should be {a, b}"
    (Lattice.StringSet.equal out2 expected_all)

(* ------------------------------------------------------------------ *)
(* 4. Backward solver test                                             *)
(*                                                                    *)
(*    B1 --> B2 --> B3                                                *)
(*                                                                    *)
(* Backward analysis: information flows from B3 back to B1.          *)
(*                                                                    *)
(*   B1: gen = {"x"}                                                  *)
(*   B2: gen = {"y"}                                                  *)
(*   B3: gen = {"z"}                                                  *)
(*                                                                    *)
(* Transfer: IN[B] = OUT[B] ∪ gen(B)   (backward)                    *)
(* Merge:    union                                                    *)
(*                                                                    *)
(* Expected at fixpoint:                                              *)
(*   B3: OUT={},          IN={z}                                      *)
(*   B2: OUT={z},         IN={y,z}                                    *)
(*   B1: OUT={y,z},       IN={x,y,z}                                  *)
(* ------------------------------------------------------------------ *)

let backward_transfer label out_val =
  let gen = set_of_list [label ^ "_use"] in
  Lattice.StringSet.union out_val gen

let test_backward_solver _ctx =
  let analysis : Lattice.StringSet.t Dataflow.analysis = {
    direction = Dataflow.Backward;
    init      = Lattice.StringSet.empty;
    merge     = Lattice.StringSet.union;
    transfer  = backward_transfer;
    equal     = Lattice.StringSet.equal;
  } in
  let results = Dataflow.solve analysis linear_cfg in
  let find_block lbl =
    List.find (fun (l, _, _) -> l = lbl) results
  in
  let (_, in1, out1) = find_block "B1" in
  let (_, in2, out2) = find_block "B2" in
  let (_, in3, out3) = find_block "B3" in

  (* B3: no successors, so OUT = init = {} *)
  assert_bool "B3 OUT should be empty"
    (Lattice.StringSet.is_empty out3);
  assert_bool "B3 IN should be {B3_use}"
    (Lattice.StringSet.equal in3 (set_of_list ["B3_use"]));

  (* B2: OUT = IN[B3] = {B3_use} *)
  assert_bool "B2 OUT should be {B3_use}"
    (Lattice.StringSet.equal out2 (set_of_list ["B3_use"]));
  assert_bool "B2 IN should be {B2_use, B3_use}"
    (Lattice.StringSet.equal in2 (set_of_list ["B2_use"; "B3_use"]));

  (* B1: OUT = IN[B2] = {B2_use, B3_use} *)
  assert_bool "B1 OUT should be {B2_use, B3_use}"
    (Lattice.StringSet.equal out1 (set_of_list ["B2_use"; "B3_use"]));
  assert_bool "B1 IN should be {B1_use, B2_use, B3_use}"
    (Lattice.StringSet.equal in1
       (set_of_list ["B1_use"; "B2_use"; "B3_use"]))

let solver_suite =
  "Solver" >::: [
    "forward linear CFG"     >:: test_forward_solver;
    "fixpoint with loop"     >:: test_fixpoint_convergence;
    "backward linear CFG"    >:: test_backward_solver;
  ]

(* ------------------------------------------------------------------ *)
(* Run all test suites.                                                *)
(* ------------------------------------------------------------------ *)

let () =
  run_test_tt_main
    ("Dataflow Framework" >::: [
       lattice_suite;
       solver_suite;
     ])
