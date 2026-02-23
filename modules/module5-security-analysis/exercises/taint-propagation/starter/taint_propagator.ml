(** Forward taint propagation engine.

    Evaluates expressions and transfers statements using
    taint abstract values from Taint_domain.

    This exercise uses a hardcoded set of sources and sanitizers:
    - Sources: "get_param", "read_cookie", "read_input"
    - Sanitizers: "escape_sql", "html_encode", "shell_escape"
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

let sources = ["get_param"; "read_cookie"; "read_input"]
let sanitizers = ["escape_sql"; "html_encode"; "shell_escape"]

let is_source (name : string) : bool = List.mem name sources
let is_sanitizer (name : string) : bool = List.mem name sanitizers

(** Evaluate an expression in a taint environment.
    - IntLit/BoolLit: Untainted (literals are clean)
    - Var x: look up in env
    - BinOp: propagate taint from both operands
    - UnaryOp: propagate taint from operand
    - Call to source: Tainted
    - Call to sanitizer: Untainted
    - Call to unknown: Top *)
let eval_expr (_env : Env.t) (_e : Shared_ast.Ast_types.expr) : Taint_domain.taint =
  failwith "TODO: implement taint expression evaluation"

(** Transfer a statement through the taint environment.
    - Assign: evaluate RHS, update env
    - If: transfer both branches, join results
    - While: fixpoint with widening (max 100 iterations)
    - Return/Print/Block: standard handling *)
let transfer_stmt (_env : Env.t) (_s : Shared_ast.Ast_types.stmt) : Env.t =
  failwith "TODO: implement taint transfer for statements"

let transfer_stmts (_env : Env.t) (_stmts : Shared_ast.Ast_types.stmt list) : Env.t =
  failwith "TODO: fold transfer_stmt over statement list"

(** Analyze a function: initialize params to Top, transfer body. *)
let analyze_function (_func : Shared_ast.Ast_types.func_def) : Env.t =
  failwith "TODO: build initial env and transfer function body"
