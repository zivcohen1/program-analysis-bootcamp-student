(** Generic iterative dataflow analysis solver.

    This module implements the classic worklist-based fixpoint algorithm
    that underlies most dataflow analyses (reaching definitions, live
    variables, available expressions, etc.).

    The solver is parameterized by:
    - [direction]: whether information flows forward or backward
    - [init]: initial lattice value for every block
    - [merge]: how to combine values from multiple predecessors/successors
    - [transfer]: how a single basic block transforms a lattice value
    - [equal]: when to stop iterating (fixpoint test)

    The CFG is given as a list of
      (block_label, predecessor_labels, successor_labels)
    triples. The solver returns (block_label, in_value, out_value)
    for every block once a fixpoint is reached.
*)

type direction = Forward | Backward

type 'a analysis = {
  direction : direction;
  init : 'a;
  merge : 'a -> 'a -> 'a;
  transfer : string -> 'a -> 'a;
  equal : 'a -> 'a -> bool;
}

module StringMap = Map.Make (String)

(** [solve analysis cfg] runs the iterative fixpoint algorithm.

    @param analysis  the analysis configuration (direction, transfer, etc.)
    @param cfg       list of (block_label, predecessors, successors)
    @return          list of (block_label, in_value, out_value) at fixpoint

    Algorithm sketch (forward case):
    {v
      1. Initialize IN[B] = OUT[B] = analysis.init for every block B.
      2. Repeat until nothing changes:
         For each block B:
           a. IN[B]  = merge over all predecessors P of B: OUT[P]
           b. OUT[B] = transfer(B, IN[B])
      3. Return the final IN/OUT for each block.
    v}

    For the backward case, swap the roles of IN/OUT and
    predecessors/successors.

    TODO: Implement this function. It currently raises [Failure "TODO"].
*)
let solve (_analysis : 'a analysis)
    (_cfg : (string * string list * string list) list)
    : (string * 'a * 'a) list =
  failwith "TODO: implement iterative fixpoint solver"
