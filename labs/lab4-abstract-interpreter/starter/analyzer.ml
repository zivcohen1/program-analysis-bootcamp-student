(** Multi-domain abstract analyzer.

    Part A (40 points): Implements a functor-based analyzer
    parameterized by an ABSTRACT_DOMAIN.  Given a function definition,
    the analyzer:
    1. Evaluates expressions abstractly
    2. Transfers statements through abstract environments
    3. Handles branches (join) and loops (widening + fixpoint)
    4. Returns the final abstract environment

    This is the core engine of the lab.
*)

module StringMap = Map.Make (String)

module Make (D : Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN) = struct

  module Env = Environment.MakeAnalysisEnv (D)

  (** Evaluate an expression in an abstract environment.
      - IntLit n: abstract the integer (you may use D.top as a default)
      - BoolLit: D.top
      - Var x: look up x in env
      - BinOp: evaluate both sides, combine with D.join (conservative)
      - UnaryOp: evaluate operand
      - Call: D.top (unknown) *)
  let eval_expr (_env : Env.t) (_e : Shared_ast.Ast_types.expr) : D.t =
    failwith "TODO: implement abstract expression evaluation"

  (** Transfer a statement: given input environment, produce output environment. *)
  let transfer_stmt (_env : Env.t) (_s : Shared_ast.Ast_types.stmt) : Env.t =
    failwith "TODO: implement transfer for Assign, If, While, Return, Print, Block"

  let transfer_stmts (_env : Env.t) (_stmts : Shared_ast.Ast_types.stmt list) : Env.t =
    failwith "TODO: fold transfer_stmt over statement list"

  (** Analyze a function definition.
      Initialize parameters to D.top, then transfer the body. *)
  let analyze_function (_func : Shared_ast.Ast_types.func_def) : Env.t =
    failwith "TODO: build initial env, transfer body, return final env"

  (** Analyze a complete program (list of function definitions).
      Returns (function_name, final_env) for each function. *)
  let analyze_program (_prog : Shared_ast.Ast_types.program)
      : (string * Env.t) list =
    failwith "TODO: map analyze_function over all functions"
end
