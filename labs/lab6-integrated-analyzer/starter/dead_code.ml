(** Part A: Dead code detection (20 points).

    Purely AST-level analysis detecting unreachable code,
    unused variables, and unused parameters. *)

open Shared_ast.Ast_types

module StringSet = Set.Make (String)

let next_id = ref 0
let fresh_id () = incr next_id; !next_id

(* ------------------------------------------------------------------ *)
(* Variable collection (TODO)                                         *)
(* ------------------------------------------------------------------ *)

(** Collect all variables read in an expression. *)
let collect_used_vars_expr (_e : expr) : StringSet.t =
  failwith "TODO: collect_used_vars_expr"

(** Collect all variables read across a statement list. *)
let collect_used_vars_stmts (_stmts : stmt list) : StringSet.t =
  ignore collect_used_vars_expr;
  failwith "TODO: collect_used_vars_stmts"

(** Collect all variables assigned in a statement list. *)
let collect_assigned_vars (_stmts : stmt list) : StringSet.t =
  failwith "TODO: collect_assigned_vars"

(* ------------------------------------------------------------------ *)
(* Finding generators (TODO)                                          *)
(* ------------------------------------------------------------------ *)

(** Find unreachable code after Return.
    Produces CodeQuality/Medium findings. *)
let find_unreachable_code (_func : func_def) : Finding.finding list =
  failwith "TODO: find_unreachable_code"

(** Find variables assigned but never read.
    Variables prefixed with [_] are exempt.
    Produces CodeQuality/Low findings. *)
let find_unused_variables (_func : func_def) : Finding.finding list =
  failwith "TODO: find_unused_variables"

(** Find function parameters never read in the body.
    Parameters prefixed with [_] are exempt.
    Produces CodeQuality/Info findings. *)
let find_unused_parameters (_func : func_def) : Finding.finding list =
  failwith "TODO: find_unused_parameters"

(* ------------------------------------------------------------------ *)
(* Top-level (TODO)                                                   *)
(* ------------------------------------------------------------------ *)

let analyze_function (_func : func_def) : Finding.finding list =
  failwith "TODO: analyze_function"

let analyze_program (_prog : program) : Finding.finding list =
  failwith "TODO: analyze_program"
