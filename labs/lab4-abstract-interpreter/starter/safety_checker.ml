(** Safety checker: detects potential runtime errors using abstract analysis.

    Part B (35 points): Given the results of abstract analysis, checks for:
    1. Division by zero: divisor may be zero
    2. Unreachable code: environment is bottom (dead code)
    3. Constant assignment: variable always has the same value
*)

module StringMap = Map.Make (String)

module Make (D : Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN) = struct

  module Analyzer = Analyzer.Make (D)

  (** A safety issue found during analysis. *)
  type issue = {
    kind : string;       (** "div-by-zero", "unreachable", "constant-value" *)
    location : string;   (** function name *)
    variable : string;   (** variable involved *)
    message : string;    (** human-readable description *)
  }

  (** Check a single expression for division-by-zero in the given env.
      Returns a list of issues. *)
  let check_expr_safety (_env : Analyzer.Env.t) (_loc : string)
      (_e : Shared_ast.Ast_types.expr) : issue list =
    failwith "TODO: walk the expression tree, flag divisions where divisor may include zero"

  (** Walk a function's body, collecting safety issues at each point. *)
  let check_stmt (_env : Analyzer.Env.t) (_loc : string)
      (_s : Shared_ast.Ast_types.stmt) : issue list * Analyzer.Env.t =
    failwith "TODO: check each statement, thread the environment, collect issues"

  let check_stmts (_env : Analyzer.Env.t) (_loc : string)
      (_stmts : Shared_ast.Ast_types.stmt list) : issue list * Analyzer.Env.t =
    failwith "TODO: fold check_stmt over statements"

  (** Analyze a function for safety issues. *)
  let check_function (_func : Shared_ast.Ast_types.func_def) : issue list =
    failwith "TODO: build initial env, check all statements"

  (** Analyze a whole program. *)
  let check_program (_prog : Shared_ast.Ast_types.program) : issue list =
    failwith "TODO: check each function, concatenate issues"
end
