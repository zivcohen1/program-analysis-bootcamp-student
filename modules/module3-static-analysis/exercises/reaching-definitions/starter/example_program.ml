(* Example Program for Reaching Definitions Analysis
 *
 * The classic if-else example:
 *
 *   def example(x):
 *       a = 1          # Block B1: d1 (defines a)
 *       b = 2          #           d2 (defines b)
 *       if x > 0:
 *           a = 3      # Block B2: d3 (defines a)
 *           c = a      #           d4 (defines c)
 *       else:
 *           b = 4      # Block B3: d5 (defines b)
 *           c = b      #           d6 (defines c)
 *       print(a, b, c) # Block B4: uses a, b, c
 *
 * CFG:
 *   ENTRY -> B1 -> B2 -> B4 -> EXIT
 *                  |           ^
 *                  +---> B3 ---+
 *)

open Reaching_definitions

let definitions = [
  { def_id = "d1"; var_name = "a"; block = "B1" };
  { def_id = "d2"; var_name = "b"; block = "B1" };
  { def_id = "d3"; var_name = "a"; block = "B2" };
  { def_id = "d4"; var_name = "c"; block = "B2" };
  { def_id = "d5"; var_name = "b"; block = "B3" };
  { def_id = "d6"; var_name = "c"; block = "B3" };
]

(* CFG as (block_label, predecessor_labels) pairs.
 * B1 has no predecessors (entry block).
 * B2 and B3 are both reached from B1 (the two branches).
 * B4 is reached from both B2 and B3 (the merge point).
 *)
let cfg = [
  ("B1", []);
  ("B2", ["B1"]);
  ("B3", ["B1"]);
  ("B4", ["B2"; "B3"]);
]
