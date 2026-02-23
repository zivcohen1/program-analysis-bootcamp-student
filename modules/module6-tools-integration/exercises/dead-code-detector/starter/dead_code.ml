(** Dead code detector: purely AST-level analysis.

    Detects unreachable code after Return statements,
    unused variables, and unused function parameters. *)

open Shared_ast.Ast_types

module StringSet = Set.Make (String)

let next_id = ref 0

let fresh_id () =
  incr next_id;
  !next_id

(* ------------------------------------------------------------------ *)
(* Return detection                                                   *)
(* ------------------------------------------------------------------ *)

(** Check if a statement list contains a Return at the top level. *)
let has_return (_stmts : stmt list) : bool =
  failwith "TODO: has_return"

(** Return the list of statements after the first top-level Return. *)
let stmts_after_return (_stmts : stmt list) : stmt list =
  failwith "TODO: stmts_after_return"

(* ------------------------------------------------------------------ *)
(* Variable collection                                                *)
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
(* Finding generators                                                 *)
(* ------------------------------------------------------------------ *)

(** Find unreachable code after Return in a function.
    Produces CodeQuality/Medium findings. *)
let find_unreachable_code (_func : func_def) : Finding_types.finding list =
  failwith "TODO: find_unreachable_code"

(** Find variables that are assigned but never read.
    Produces CodeQuality/Low findings.
    Variables prefixed with [_] are exempt. *)
let find_unused_variables (_func : func_def) : Finding_types.finding list =
  failwith "TODO: find_unused_variables"

(** Find function parameters that are never read in the body.
    Produces CodeQuality/Info findings.
    Parameters prefixed with [_] are exempt. *)
let find_unused_parameters (_func : func_def) : Finding_types.finding list =
  failwith "TODO: find_unused_parameters"

(* ------------------------------------------------------------------ *)
(* Top-level analysis                                                 *)
(* ------------------------------------------------------------------ *)

(** Analyze a single function for all dead code patterns. *)
let analyze_function (_func : func_def) : Finding_types.finding list =
  failwith "TODO: analyze_function"

(** Analyze all functions in a program. *)
let analyze_program (_prog : program) : Finding_types.finding list =
  failwith "TODO: analyze_program"
