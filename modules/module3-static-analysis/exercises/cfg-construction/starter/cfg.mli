(** Control Flow Graph (CFG) representation and operations.

    A CFG represents the flow of control in a program as a directed graph
    where nodes are basic blocks (sequences of statements with a single
    entry and single exit) and edges represent possible control flow paths.

    Every CFG has a distinguished ENTRY block and EXIT block. *)

module StringSet : Set.S with type elt = string
module StringMap : Map.S with type key = string

(** A basic block: a maximal sequence of statements with one entry point
    and one exit point. Control always enters at the top and leaves at
    the bottom (or via a branch at the end). *)
type basic_block = {
  label : string;
  stmts : Shared_ast.Ast_types.stmt list;
  mutable succs : string list;
  mutable preds : string list;
}

(** A control flow graph. The [blocks] map stores all blocks keyed by
    their label. [entry] and [exit_label] name the distinguished
    entry and exit blocks. *)
type cfg = {
  entry : string;
  exit_label : string;
  blocks : basic_block StringMap.t;
}

(** [create_block label stmts] creates a new basic block with the given
    label and statement list, with empty successor and predecessor lists. *)
val create_block : string -> Shared_ast.Ast_types.stmt list -> basic_block

(** [add_edge cfg src dst] returns a new CFG where block [src] has [dst]
    in its successors and block [dst] has [src] in its predecessors.
    Both [src] and [dst] must be labels of blocks already in [cfg]. *)
val add_edge : cfg -> string -> string -> cfg

(** [predecessors cfg label] returns the predecessor labels of the
    block named [label] in [cfg]. *)
val predecessors : cfg -> string -> string list

(** [successors cfg label] returns the successor labels of the
    block named [label] in [cfg]. *)
val successors : cfg -> string -> string list

(** [to_string cfg] returns a human-readable multi-line representation
    of the CFG, showing each block with its successors and predecessors. *)
val to_string : cfg -> string
