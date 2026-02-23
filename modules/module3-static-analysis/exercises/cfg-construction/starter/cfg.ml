(** Control Flow Graph implementation.

    Students: implement the functions marked with TODO below.
    [create_block] is provided as a reference. *)

module StringSet = Set.Make(String)
module StringMap = Map.Make(String)

type basic_block = {
  label : string;
  stmts : Shared_ast.Ast_types.stmt list;
  mutable succs : string list;
  mutable preds : string list;
}

type cfg = {
  entry : string;
  exit_label : string;
  blocks : basic_block StringMap.t;
}

(* --- Provided ----------------------------------------------------------- *)

let create_block (label : string) (stmts : Shared_ast.Ast_types.stmt list) : basic_block =
  { label; stmts; succs = []; preds = [] }

(* --- TODO: implement these ---------------------------------------------- *)

let add_edge (cfg : cfg) (src : string) (dst : string) : cfg =
  (* TODO: Return a new cfg where:
     1. The block named [src] has [dst] appended to its succs list
     2. The block named [dst] has [src] appended to its preds list
     3. All other blocks remain unchanged
     Hint: Look up both blocks in cfg.blocks using StringMap.find,
     create updated copies, and build a new blocks map with StringMap.add. *)
  ignore (cfg, src, dst);
  failwith "TODO: add_edge"

let predecessors (cfg : cfg) (label : string) : string list =
  (* TODO: Look up the block with the given label in cfg.blocks
     and return its preds list.
     Hint: Use StringMap.find. *)
  ignore (cfg, label);
  failwith "TODO: predecessors"

let successors (cfg : cfg) (label : string) : string list =
  (* TODO: Look up the block with the given label in cfg.blocks
     and return its succs list.
     Hint: Use StringMap.find. *)
  ignore (cfg, label);
  failwith "TODO: successors"

let to_string (cfg : cfg) : string =
  (* TODO: Build a human-readable string representation of the CFG.
     For each block, print its label, the number of statements it
     contains, its successors, and its predecessors.  Format example:

       Block: ENTRY (0 stmts)
         succs: [B1]
         preds: []

     Hint: Use StringMap.fold to iterate over cfg.blocks.
     Use String.concat to join lists of labels. *)
  ignore cfg;
  failwith "TODO: to_string"
