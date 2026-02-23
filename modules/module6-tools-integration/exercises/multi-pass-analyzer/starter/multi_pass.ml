(** Multi-pass analyzer: compose safety, taint, and dead-code analyses.

    Uses the record-based analysis pass pattern to build independent
    passes that can be run individually or composed. *)

open Shared_ast.Ast_types

(* ------------------------------------------------------------------ *)
(* Analysis pass type (provided -- not a TODO)                        *)
(* ------------------------------------------------------------------ *)

type analysis_pass = {
  name : string;
  category : Finding_types.category;
  run : program -> Finding_types.finding list;
}

(* ------------------------------------------------------------------ *)
(* ID generation (provided)                                           *)
(* ------------------------------------------------------------------ *)

let next_id = ref 0

let fresh_id () =
  incr next_id;
  !next_id

(* ------------------------------------------------------------------ *)
(* Safety pass (sign domain)                                          *)
(* ------------------------------------------------------------------ *)

(** Create SignEnv using MakeEnv functor with Sign_domain.
    Then implement eval_sign : SignEnv.t -> expr -> Sign_domain.sign
    that evaluates expressions using abstract sign arithmetic.

    The safety pass should detect division-by-zero by checking
    BinOp(Div, _, denom) -- if denom evaluates to Zero, emit
    a High-severity Safety finding; if Top, emit Medium. *)
let make_safety_pass () : analysis_pass =
  ignore fresh_id;
  failwith "TODO: make_safety_pass"

(* ------------------------------------------------------------------ *)
(* Taint pass                                                         *)
(* ------------------------------------------------------------------ *)

(** Create TaintEnv using MakeEnv functor with Taint_domain.
    Implement eval_taint : TaintEnv.t -> expr -> Taint_domain.taint.
    Use hardcoded sources/sinks:
      Sources: get_param, read_cookie, read_input, read_file, get_header
      Sinks: (exec_query, sql-injection), (send_response, xss),
             (exec_cmd, command-injection), (open_file, path-traversal)
      Sanitizers: escape_sql, html_encode, shell_escape, validate_path

    The taint pass should check sink calls for tainted arguments and
    emit Critical-severity Security findings. *)
let make_taint_pass () : analysis_pass =
  failwith "TODO: make_taint_pass"

(* ------------------------------------------------------------------ *)
(* Composition                                                        *)
(* ------------------------------------------------------------------ *)

(** Run a single pass on a program. *)
let run_pass (_pass : analysis_pass) (_prog : program) : Finding_types.finding list =
  failwith "TODO: run_pass"

(** Run all passes on a program, collecting all findings. *)
let run_all_passes (_passes : analysis_pass list) (_prog : program)
    : Finding_types.finding list =
  failwith "TODO: run_all_passes"

(** Flatten a list of finding lists and sort by severity (highest first). *)
let merge_findings (_findings_list : Finding_types.finding list list)
    : Finding_types.finding list =
  failwith "TODO: merge_findings"

(** Group findings by pass_name, preserving first-seen order.
    Returns (pass_name, findings) pairs. *)
let partition_by_pass (_findings : Finding_types.finding list)
    : (string * Finding_types.finding list) list =
  failwith "TODO: partition_by_pass"

(** Return the default set of passes: [safety; taint]. *)
let default_passes () : analysis_pass list =
  failwith "TODO: default_passes"
