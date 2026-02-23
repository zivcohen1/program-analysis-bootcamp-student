(** Taint analyzer: forward taint propagation (Part A: 25 points).

    Propagates taint through expressions and statements using
    the taint domain and security configuration.
*)

module Env = Abstract_domains.Abstract_env.MakeEnv (struct
  type t = Taint_domain.taint
  let bottom = Taint_domain.bottom
  let top = Taint_domain.top
  let join = Taint_domain.join
  let meet = Taint_domain.meet
  let leq = Taint_domain.leq
  let equal = Taint_domain.equal
  let widen = Taint_domain.widen
  let to_string = Taint_domain.to_string
end)

(** Evaluate an expression in a taint environment.
    Uses the security config to identify sources and sanitizers.
    - IntLit/BoolLit → Untainted
    - Var → lookup in env
    - BinOp → propagate taint from both operands
    - UnaryOp → propagate from operand
    - Call to source → Tainted
    - Call to sanitizer → Untainted
    - Call to unknown → Top *)
let eval_expr (_config : Security_config.config) (_env : Env.t)
    (_e : Shared_ast.Ast_types.expr) : Taint_domain.taint =
  failwith "TODO: implement config-aware expression evaluation"

(** Transfer a statement through the taint environment.
    - Assign: evaluate RHS, update env
    - If: transfer both branches, join results
    - While: fixpoint with widening (max 100 iterations)
    - Return/Print: env unchanged
    - Block: transfer nested statements *)
let transfer_stmt (_config : Security_config.config) (_env : Env.t)
    (_s : Shared_ast.Ast_types.stmt) : Env.t =
  failwith "TODO: implement taint transfer for statements"

let transfer_stmts (_config : Security_config.config) (_env : Env.t)
    (_stmts : Shared_ast.Ast_types.stmt list) : Env.t =
  failwith "TODO: fold transfer_stmt over statement list"

(** Analyze a function: initialize params to Top, transfer body. *)
let analyze_function (_config : Security_config.config)
    (_func : Shared_ast.Ast_types.func_def) : Env.t =
  failwith "TODO: build initial env and transfer function body"
