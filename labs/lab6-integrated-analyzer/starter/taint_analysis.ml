(** Part B: Taint analysis pass (15 points).

    Uses the taint domain and taint_config to detect injection
    vulnerabilities (source → sink without sanitizer). *)

open Shared_ast.Ast_types

module TaintEnv = Abstract_domains.Abstract_env.MakeEnv (struct
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

let config = Taint_config.default_config

let next_id = ref 200
let fresh_id () = incr next_id; !next_id

(* ------------------------------------------------------------------ *)
(* Abstract evaluation (TODO)                                         *)
(* ------------------------------------------------------------------ *)

(** Evaluate an expression for taint:
    - Literals → Untainted
    - Var → lookup in env
    - BinOp/UnaryOp → propagate taint
    - Call to source → Tainted
    - Call to sanitizer → Untainted
    - Unknown call → Top *)
let eval_expr (_env : TaintEnv.t) (_e : expr) : Taint_domain.taint =
  failwith "TODO: eval_expr"

(* ------------------------------------------------------------------ *)
(* Transfer + vulnerability check (TODO)                              *)
(* ------------------------------------------------------------------ *)

(** Transfer a statement: update env, check for tainted data at sinks.
    For Assign(x, Call(sink, args)): if first arg is potentially tainted,
    emit a Critical/Security finding with the sink's vuln_type.
    Handle If/While/Block recursively. *)
let transfer_stmt (_func_name : string) (_env : TaintEnv.t)
    (_s : stmt) : TaintEnv.t * Finding.finding list =
  ignore fresh_id;
  failwith "TODO: transfer_stmt"

(* ------------------------------------------------------------------ *)
(* Top-level (TODO)                                                   *)
(* ------------------------------------------------------------------ *)

(** Analyze a function: init params to Top, transfer all stmts. *)
let analyze_function (_func : func_def) : Finding.finding list =
  failwith "TODO: analyze_function"

(** Analyze all functions in a program. *)
let analyze_program (_prog : program) : Finding.finding list =
  failwith "TODO: analyze_program"
