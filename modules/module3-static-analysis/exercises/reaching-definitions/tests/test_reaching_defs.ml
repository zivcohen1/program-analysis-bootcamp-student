open OUnit2
open Reaching_defs.Reaching_definitions

(* Helper: build a StringSet from a list of strings *)
let set_of_list lst =
  List.fold_left (fun s x -> StringSet.add x s) StringSet.empty lst

(* Helper: assert two StringSets are equal, with a readable error message.
   We must pass ~cmp because OUnit's assert_equal uses polymorphic (=) by
   default, which compares AVL tree structure rather than logical set
   equality.  StringSet.equal compares the sets semantically. *)
let assert_set_equal ~msg expected actual =
  let to_str s =
    "{" ^ String.concat ", " (StringSet.elements s) ^ "}"
  in
  assert_equal ~msg ~cmp:StringSet.equal ~printer:to_str expected actual

(* The example program definitions and CFG *)
let definitions = Reaching_defs.Example_program.definitions
let cfg = Reaching_defs.Example_program.cfg

(* -------------------------------------------------------------------
   Test compute_gen
   ------------------------------------------------------------------- *)

let test_gen_b1 _ =
  let gen = compute_gen definitions "B1" in
  assert_set_equal ~msg:"gen[B1] should be {d1, d2}"
    (set_of_list ["d1"; "d2"]) gen

let test_gen_b2 _ =
  let gen = compute_gen definitions "B2" in
  assert_set_equal ~msg:"gen[B2] should be {d3, d4}"
    (set_of_list ["d3"; "d4"]) gen

let test_gen_b3 _ =
  let gen = compute_gen definitions "B3" in
  assert_set_equal ~msg:"gen[B3] should be {d5, d6}"
    (set_of_list ["d5"; "d6"]) gen

let test_gen_b4 _ =
  let gen = compute_gen definitions "B4" in
  assert_set_equal ~msg:"gen[B4] should be empty (no definitions)"
    StringSet.empty gen

(* -------------------------------------------------------------------
   Test compute_kill
   ------------------------------------------------------------------- *)

let test_kill_b1 _ =
  (* B1 defines a (d1) and b (d2).
     kill = other defs of a and b = {d3} (other def of a) U {d5} (other def of b) *)
  let kill = compute_kill definitions "B1" in
  assert_set_equal ~msg:"kill[B1] should be {d3, d5}"
    (set_of_list ["d3"; "d5"]) kill

let test_kill_b2 _ =
  (* B2 defines a (d3) and c (d4).
     kill = other defs of a and c = {d1} (other def of a) U {d6} (other def of c) *)
  let kill = compute_kill definitions "B2" in
  assert_set_equal ~msg:"kill[B2] should be {d1, d6}"
    (set_of_list ["d1"; "d6"]) kill

let test_kill_b3 _ =
  (* B3 defines b (d5) and c (d6).
     kill = other defs of b and c = {d2} (other def of b) U {d4} (other def of c) *)
  let kill = compute_kill definitions "B3" in
  assert_set_equal ~msg:"kill[B3] should be {d2, d4}"
    (set_of_list ["d2"; "d4"]) kill

let test_kill_b4 _ =
  let kill = compute_kill definitions "B4" in
  assert_set_equal ~msg:"kill[B4] should be empty (no definitions)"
    StringSet.empty kill

(* -------------------------------------------------------------------
   Test analyze (full iterative fixpoint)
   ------------------------------------------------------------------- *)

(* Helper: look up a block's result in the analysis output *)
let find_block label results =
  match List.find_opt (fun (l, _, _) -> l = label) results with
  | Some (_, in_s, out_s) -> (in_s, out_s)
  | None -> failwith ("Block " ^ label ^ " not found in analysis results")

let test_analyze_out_b1 _ =
  let results = analyze cfg definitions in
  let (_in_b1, out_b1) = find_block "B1" results in
  assert_set_equal ~msg:"OUT[B1] should be {d1, d2}"
    (set_of_list ["d1"; "d2"]) out_b1

let test_analyze_out_b2 _ =
  let results = analyze cfg definitions in
  let (_in_b2, out_b2) = find_block "B2" results in
  assert_set_equal ~msg:"OUT[B2] should be {d2, d3, d4}"
    (set_of_list ["d2"; "d3"; "d4"]) out_b2

let test_analyze_out_b3 _ =
  let results = analyze cfg definitions in
  let (_in_b3, out_b3) = find_block "B3" results in
  assert_set_equal ~msg:"OUT[B3] should be {d1, d5, d6}"
    (set_of_list ["d1"; "d5"; "d6"]) out_b3

let test_analyze_in_b4 _ =
  let results = analyze cfg definitions in
  let (in_b4, _out_b4) = find_block "B4" results in
  assert_set_equal ~msg:"IN[B4] should be {d1, d2, d3, d4, d5, d6}"
    (set_of_list ["d1"; "d2"; "d3"; "d4"; "d5"; "d6"]) in_b4

let test_analyze_in_b1 _ =
  let results = analyze cfg definitions in
  let (in_b1, _out_b1) = find_block "B1" results in
  assert_set_equal ~msg:"IN[B1] should be empty (no predecessors)"
    StringSet.empty in_b1

let test_analyze_in_b2 _ =
  let results = analyze cfg definitions in
  let (in_b2, _out_b2) = find_block "B2" results in
  assert_set_equal ~msg:"IN[B2] should be {d1, d2} (from OUT[B1])"
    (set_of_list ["d1"; "d2"]) in_b2

let test_analyze_in_b3 _ =
  let results = analyze cfg definitions in
  let (in_b3, _out_b3) = find_block "B3" results in
  assert_set_equal ~msg:"IN[B3] should be {d1, d2} (from OUT[B1])"
    (set_of_list ["d1"; "d2"]) in_b3

(* -------------------------------------------------------------------
   Test suite
   ------------------------------------------------------------------- *)

let suite =
  "Reaching Definitions" >::: [
    "gen" >::: [
      "gen[B1]" >:: test_gen_b1;
      "gen[B2]" >:: test_gen_b2;
      "gen[B3]" >:: test_gen_b3;
      "gen[B4]" >:: test_gen_b4;
    ];
    "kill" >::: [
      "kill[B1]" >:: test_kill_b1;
      "kill[B2]" >:: test_kill_b2;
      "kill[B3]" >:: test_kill_b3;
      "kill[B4]" >:: test_kill_b4;
    ];
    "analyze" >::: [
      "OUT[B1]" >:: test_analyze_out_b1;
      "OUT[B2]" >:: test_analyze_out_b2;
      "OUT[B3]" >:: test_analyze_out_b3;
      "IN[B4]"  >:: test_analyze_in_b4;
      "IN[B1]"  >:: test_analyze_in_b1;
      "IN[B2]"  >:: test_analyze_in_b2;
      "IN[B3]"  >:: test_analyze_in_b3;
    ];
  ]

let () = run_test_tt_main suite
