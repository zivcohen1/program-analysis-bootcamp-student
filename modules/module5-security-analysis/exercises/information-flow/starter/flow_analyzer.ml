(** Information flow analyzer with implicit flow tracking.

    Extends basic taint propagation with a [pc_taint] parameter
    that tracks whether execution is inside a branch controlled
    by tainted data. Assignments inside such branches are
    considered tainted (implicit information flow).

    Sources: "get_param", "read_cookie", "read_input"
    Sanitizers: "escape_sql", "html_encode", "shell_escape"
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

(** The kind of information flow detected. *)
type flow_kind = Explicit | Implicit

(** A detected information flow. *)
type flow = {
  kind : flow_kind;
  variable : string;
  location : string;
}

(** Evaluate an expression in a taint environment.
    Same rules as Exercise 3:
    - Literals → Untainted
    - Var → lookup
    - BinOp → propagate
    - Source → Tainted, Sanitizer → Untainted, Unknown → Top *)
let eval_expr (_env : Env.t) (_e : Shared_ast.Ast_types.expr) : Taint_domain.taint =
  failwith "TODO: implement expression evaluation"

(** Transfer a statement with pc_taint tracking.
    Key difference from Exercise 3: in Assign, combine the
    evaluated taint with [pc_taint] using [Taint_domain.propagate].
    For If: if the condition is tainted, update pc_taint for both branches.
    For While: if the condition is tainted, update pc_taint for the body. *)
let transfer_stmt ~(pc_taint : Taint_domain.taint) (_env : Env.t)
    (_s : Shared_ast.Ast_types.stmt) : Env.t =
  ignore pc_taint;
  failwith "TODO: implement transfer with pc_taint"

let transfer_stmts ~(pc_taint : Taint_domain.taint) (_env : Env.t)
    (_stmts : Shared_ast.Ast_types.stmt list) : Env.t =
  ignore pc_taint;
  failwith "TODO: fold transfer_stmt over statements"

(** Detect information flows in a statement list.
    Walk the statements and record each assignment where
    the resulting taint is potentially tainted.
    Classify as Implicit if pc_taint is potentially tainted,
    otherwise Explicit. *)
let detect_flows ~(pc_taint : Taint_domain.taint) (_env : Env.t)
    (_func_name : string) (_stmts : Shared_ast.Ast_types.stmt list)
    : flow list =
  ignore pc_taint;
  failwith "TODO: detect explicit and implicit flows"

(** Analyze a function: initialize params to Top, transfer body
    with pc_taint = Untainted, detect flows. *)
let analyze_function (_func : Shared_ast.Ast_types.func_def)
    : Env.t * flow list =
  failwith "TODO: analyze function and return (env, flows)"
