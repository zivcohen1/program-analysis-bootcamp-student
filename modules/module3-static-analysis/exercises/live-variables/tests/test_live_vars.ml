open OUnit2
open Live_variables

(* ================================================================
 * Test CFG: Classic live variables example
 *
 * This is a diamond-shaped CFG with four blocks:
 *
 *         B1
 *        /  \
 *       B2   B3
 *        \  /
 *         B4
 *
 * B1: a := ...; b := ...       def={a,b}, use={}
 * B2: ... := a; a := ...; c := ...   def={a,c}, use={a}
 * B3: ... := b; b := ...; c := ...   def={b,c}, use={b}
 * B4: ... := a; ... := b; ... := c   def={},    use={a,b,c}
 *
 * Expected live variable results (backward analysis):
 *
 *   IN[B4] = {a, b, c}   -- all three are used in B4
 *   OUT[B4] = {}          -- B4 has no successors
 *
 *   IN[B2] = {a, b}       -- a is used locally; b passes through
 *                            (b is in OUT[B2] = IN[B4] = {a,b,c},
 *                             b not in def[B2], so b survives;
 *                             a,c are in def[B2] so killed from OUT,
 *                             but a is in use[B2] so added back)
 *   IN[B3] = {a, b}       -- symmetric: b used locally; a passes through
 *
 *   OUT[B1] = IN[B2] U IN[B3] = {a, b}
 *   IN[B1] = use[B1] U (OUT[B1] - def[B1])
 *          = {} U ({a,b} - {a,b})
 *          = {}           -- a and b are defined before any use
 * ================================================================ *)

let blocks = [
  (* (label, defined_vars, used_vars, successor_labels) *)
  ("B1", ["a"; "b"], [],              ["B2"; "B3"]);
  ("B2", ["a"; "c"], ["a"],           ["B4"]);
  ("B3", ["b"; "c"], ["b"],           ["B4"]);
  ("B4", [],         ["a"; "b"; "c"], []);
]

(* Helper: find the result triple for a given label *)
let find_result label results =
  List.find (fun (l, _, _) -> l = label) results

(* Helper: assert that a StringSet equals an expected list of strings *)
let assert_set_equal ~msg expected_list actual_set =
  let expected = StringSet.of_list expected_list in
  assert_equal ~msg
    ~cmp:StringSet.equal
    ~printer:(fun s ->
      "{" ^ String.concat ", " (StringSet.elements s) ^ "}")
    expected actual_set

(* ---- compute_use tests ---- *)

let test_compute_use_empty _ =
  let result = compute_use ("B1", ["a"; "b"], []) in
  assert_set_equal ~msg:"use[B1] should be empty" [] result

let test_compute_use_single _ =
  let result = compute_use ("B2", ["a"; "c"], ["a"]) in
  assert_set_equal ~msg:"use[B2] should be {a}" ["a"] result

let test_compute_use_multiple _ =
  let result = compute_use ("B4", [], ["a"; "b"; "c"]) in
  assert_set_equal ~msg:"use[B4] should be {a,b,c}" ["a"; "b"; "c"] result

(* ---- compute_def tests ---- *)

let test_compute_def_empty _ =
  let result = compute_def ("B4", [], ["a"; "b"; "c"]) in
  assert_set_equal ~msg:"def[B4] should be empty" [] result

let test_compute_def_two _ =
  let result = compute_def ("B1", ["a"; "b"], []) in
  assert_set_equal ~msg:"def[B1] should be {a,b}" ["a"; "b"] result

(* ---- Full analysis tests ---- *)

let test_in_b4 _ =
  let results = analyze blocks in
  let (_, in_b4, _) = find_result "B4" results in
  assert_set_equal ~msg:"IN[B4] = {a, b, c}"
    ["a"; "b"; "c"] in_b4

let test_out_b4 _ =
  let results = analyze blocks in
  let (_, _, out_b4) = find_result "B4" results in
  assert_set_equal ~msg:"OUT[B4] = {} (no successors)"
    [] out_b4

let test_in_b2 _ =
  let results = analyze blocks in
  let (_, in_b2, _) = find_result "B2" results in
  assert_set_equal ~msg:"IN[B2] = {a, b}"
    ["a"; "b"] in_b2

let test_in_b3 _ =
  let results = analyze blocks in
  let (_, in_b3, _) = find_result "B3" results in
  assert_set_equal ~msg:"IN[B3] = {a, b}"
    ["a"; "b"] in_b3

let test_out_b1 _ =
  let results = analyze blocks in
  let (_, _, out_b1) = find_result "B1" results in
  assert_set_equal ~msg:"OUT[B1] = IN[B2] U IN[B3] = {a, b}"
    ["a"; "b"] out_b1

let test_in_b1 _ =
  let results = analyze blocks in
  let (_, in_b1, _) = find_result "B1" results in
  assert_set_equal ~msg:"IN[B1] = {} (a,b defined before use)"
    [] in_b1

(* ---- Loop test: ensure fixpoint handles cycles ---- *)

(* A simple loop:
 *
 *   B1 -> B2 -> B3
 *          ^    |
 *          +----+
 *
 * B1: def={x}, use={},  succs=[B2]
 * B2: def={},  use={x}, succs=[B3]
 * B3: def={x}, use={y}, succs=[B2]    (back edge to B2)
 *
 * Expected:
 *   IN[B3] = {y}  U (OUT[B3] - {x})
 *   OUT[B3] = IN[B2]
 *   IN[B2] = {x} U (OUT[B2] - {})  = {x} U IN[B3] = {x, y}
 *   OUT[B2] = IN[B3]
 *
 * So IN[B2] = {x, y}, IN[B3] = {x, y}
 *   (y flows through B2 since B2 doesn't def y;
 *    x is used in B2 and flows backward through B3 since
 *    B3 defs x but we add y from use[B3], and x from OUT-def)
 *
 * Actually let's trace carefully:
 *   IN[B3] = use[B3] U (OUT[B3] - def[B3])
 *          = {y} U (IN[B2] - {x})
 *   IN[B2] = use[B2] U (OUT[B2] - def[B2])
 *          = {x} U (IN[B3] - {})
 *          = {x} U IN[B3]
 *
 * Substituting: IN[B3] = {y} U (({x} U IN[B3]) - {x})
 *             = {y} U (IN[B3] - {x})
 * If IN[B3] = {y}: {y} U ({y} - {x}) = {y} U {y} = {y}. Fixpoint!
 *
 * So IN[B2] = {x} U {y} = {x, y}
 *    IN[B3] = {y}
 *    IN[B1] = {} U (IN[B2] - {x}) = {y}
 *)
let loop_blocks = [
  ("B1", ["x"], [],    ["B2"]);
  ("B2", [],    ["x"], ["B3"]);
  ("B3", ["x"], ["y"], ["B2"]);
]

let test_loop_in_b2 _ =
  let results = analyze loop_blocks in
  let (_, in_b2, _) = find_result "B2" results in
  assert_set_equal ~msg:"Loop: IN[B2] = {x, y}"
    ["x"; "y"] in_b2

let test_loop_in_b3 _ =
  let results = analyze loop_blocks in
  let (_, in_b3, _) = find_result "B3" results in
  assert_set_equal ~msg:"Loop: IN[B3] = {y}"
    ["y"] in_b3

let test_loop_in_b1 _ =
  let results = analyze loop_blocks in
  let (_, in_b1, _) = find_result "B1" results in
  assert_set_equal ~msg:"Loop: IN[B1] = {y}"
    ["y"] in_b1

(* ---- Test suite ---- *)

let suite =
  "Live Variables Analysis" >::: [
    "compute_use: empty use set"     >:: test_compute_use_empty;
    "compute_use: single variable"   >:: test_compute_use_single;
    "compute_use: multiple variables" >:: test_compute_use_multiple;
    "compute_def: empty def set"     >:: test_compute_def_empty;
    "compute_def: two variables"     >:: test_compute_def_two;
    "analyze: IN[B4] = {a,b,c}"     >:: test_in_b4;
    "analyze: OUT[B4] = {}"          >:: test_out_b4;
    "analyze: IN[B2] = {a,b}"       >:: test_in_b2;
    "analyze: IN[B3] = {a,b}"       >:: test_in_b3;
    "analyze: OUT[B1] = {a,b}"      >:: test_out_b1;
    "analyze: IN[B1] = {}"          >:: test_in_b1;
    "loop: IN[B2] = {x,y}"          >:: test_loop_in_b2;
    "loop: IN[B3] = {y}"            >:: test_loop_in_b3;
    "loop: IN[B1] = {y}"            >:: test_loop_in_b1;
  ]

let () = run_test_tt_main suite
