(* Comparison: Reaching Definitions vs Live Variables
 *
 * These two analyses are duals of each other in the dataflow framework.
 * Understanding their similarities and differences is key to grasping
 * the general dataflow analysis framework.
 *
 * +-----------------------+---------------------+---------------------+
 * |                       | Reaching Defs       | Live Variables      |
 * +-----------------------+---------------------+---------------------+
 * | Direction             | Forward             | Backward            |
 * | May/Must              | May                 | May                 |
 * | Merge operator        | Union               | Union               |
 * | Transfer function     | gen U (IN - kill)   | use U (OUT - def)   |
 * | Initial (entry/exit)  | Empty               | Empty               |
 * | Information tracks    | Where defs come from| Where uses go to    |
 * | Primary use           | Constant propagation| Register allocation |
 * |                       | Def-use chains      | Dead code detection |
 * +-----------------------+---------------------+---------------------+
 *
 * Key insight: "Forward may" and "backward may" are structurally the
 * same algorithm -- only the direction of traversal along the CFG edges
 * differs. In reaching defs, we propagate facts forward from definitions
 * to uses. In live variables, we propagate facts backward from uses to
 * definitions.
 *)

let print_comparison () =
  Printf.printf "=== Dataflow Analysis Comparison ===\n\n";
  Printf.printf "Reaching Definitions:\n";
  Printf.printf "  Direction:  Forward  (entry -> exit)\n";
  Printf.printf "  Kind:       May analysis\n";
  Printf.printf "  Merge:      Union (facts from ANY path count)\n";
  Printf.printf "  Transfer:   gen[B] U (IN[B] - kill[B])\n";
  Printf.printf "  Question:   Which definitions MIGHT reach this point?\n\n";
  Printf.printf "Live Variables:\n";
  Printf.printf "  Direction:  Backward (exit -> entry)\n";
  Printf.printf "  Kind:       May analysis\n";
  Printf.printf "  Merge:      Union (facts from ANY path count)\n";
  Printf.printf "  Transfer:   use[B] U (OUT[B] - def[B])\n";
  Printf.printf "  Question:   Which variables MIGHT be used later?\n\n";
  Printf.printf "Key difference: direction of information flow\n";
  Printf.printf "  - Reaching defs: propagate forward from definitions\n";
  Printf.printf "  - Live vars:     propagate backward from uses\n"
