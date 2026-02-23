(** Vulnerability checker: detects security issues (Part B: 25 points).

    Walks the AST checking each function call against the security
    configuration. When a sink is called with tainted arguments,
    a vulnerability is recorded.
*)

(** A detected vulnerability. *)
type vulnerability = {
  vuln_type : string;
  location : string;
  source_var : string;
  sink_name : string;
  message : string;
}

(** Check a Call node: if it's a sink and the checked argument
    is potentially tainted, return a vulnerability. *)
let check_call (_config : Security_config.config)
    (_env : Taint_analyzer.Env.t)
    (_func_name : string) (_call_name : string)
    (_args : Shared_ast.Ast_types.expr list) : vulnerability list =
  failwith "TODO: check if call is a sink with tainted arguments"

(** Check a statement for vulnerabilities, threading the environment.
    Returns (updated_env, new_vulnerabilities). *)
let check_stmt (_config : Security_config.config) (_func_name : string)
    (_env : Taint_analyzer.Env.t) (_s : Shared_ast.Ast_types.stmt)
    : Taint_analyzer.Env.t * vulnerability list =
  failwith "TODO: check statement for vulnerabilities"

let check_stmts (_config : Security_config.config) (_func_name : string)
    (_env : Taint_analyzer.Env.t) (_stmts : Shared_ast.Ast_types.stmt list)
    : Taint_analyzer.Env.t * vulnerability list =
  failwith "TODO: fold check_stmt over statements"

(** Check a function for vulnerabilities. *)
let check_function (_config : Security_config.config)
    (_func : Shared_ast.Ast_types.func_def) : vulnerability list =
  failwith "TODO: check function for vulnerabilities"

(** Check an entire program (all functions). *)
let check_program (_config : Security_config.config)
    (_prog : Shared_ast.Ast_types.program) : vulnerability list =
  failwith "TODO: check all functions for vulnerabilities"
