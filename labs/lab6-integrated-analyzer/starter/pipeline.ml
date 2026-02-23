(** Part B: Analysis pipeline (10 points).

    Runs multiple analysis passes and combines results. *)

type pass = {
  name : string;
  run : Shared_ast.Ast_types.program -> Finding.finding list;
}

(* ------------------------------------------------------------------ *)
(* Pipeline (TODO)                                                    *)
(* ------------------------------------------------------------------ *)

(** Return the default list of analysis passes:
    dead_code, safety, taint. *)
let default_passes () : pass list =
  failwith "TODO: default_passes"

(** Run all passes on a program and combine findings,
    sorted by severity (highest first). *)
let run_all (_passes : pass list) (_prog : Shared_ast.Ast_types.program)
    : Finding.finding list =
  failwith "TODO: run_all"
