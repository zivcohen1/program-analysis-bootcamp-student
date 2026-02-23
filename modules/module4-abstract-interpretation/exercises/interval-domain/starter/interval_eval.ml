(** Expression evaluator over the interval domain.

    Given an abstract environment mapping variable names to
    {!Interval_domain.interval}, evaluate an AST expression
    to produce an abstract interval result.
*)

module StringMap = Map.Make (String)

(** Evaluate an expression in an abstract interval environment.
    Variables not in the map are treated as top ([-inf, +inf]). *)
let eval_expr (_env : Interval_domain.interval StringMap.t)
    (_e : Shared_ast.Ast_types.expr) : Interval_domain.interval =
  failwith "TODO: recursively evaluate expressions using Interval_domain operations"
