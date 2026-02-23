(** Expression evaluator over the constant domain.

    Given an abstract environment mapping variable names to
    {!Constant_domain.const_val}, evaluate an AST expression
    to produce an abstract constant result.
*)

module StringMap = Map.Make (String)

(** Evaluate an expression in an abstract constant environment.
    Variables not in the map are treated as [Top] (unknown). *)
let eval_expr (_env : Constant_domain.const_val StringMap.t)
    (_e : Shared_ast.Ast_types.expr) : Constant_domain.const_val =
  failwith "TODO: recursively evaluate expressions using Constant_domain operations"
