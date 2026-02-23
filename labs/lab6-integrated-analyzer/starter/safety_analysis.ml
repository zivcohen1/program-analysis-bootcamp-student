(** Part B: Safety analysis pass (15 points).

    Uses the sign domain to detect division-by-zero. *)

open Shared_ast.Ast_types

module SignEnv = Abstract_domains.Abstract_env.MakeEnv (struct
  type t = Sign_domain.sign
  let bottom = Sign_domain.bottom
  let top = Sign_domain.top
  let join = Sign_domain.join
  let meet = Sign_domain.meet
  let leq = Sign_domain.leq
  let equal = Sign_domain.equal
  let widen = Sign_domain.widen
  let to_string = Sign_domain.to_string
end)

let next_id = ref 100
let fresh_id () = incr next_id; !next_id

(* ------------------------------------------------------------------ *)
(* Abstract evaluation (TODO)                                         *)
(* ------------------------------------------------------------------ *)

(** Evaluate an expression in the sign domain.
    Use Sign_domain.alpha_int for IntLit, abstract arithmetic
    for BinOp, SignEnv.lookup for Var. *)
let eval_expr (_env : SignEnv.t) (_e : expr) : Sign_domain.sign =
  failwith "TODO: eval_expr"

(* ------------------------------------------------------------------ *)
(* Transfer function (TODO)                                           *)
(* ------------------------------------------------------------------ *)

(** Transfer function: process a statement, update env, collect findings.
    For Assign(x, BinOp(Div, _, denom)): check if denom is Zero (High)
    or Top (Medium). Handle If/While/Block recursively. *)
let transfer_stmt (_func_name : string) (_env : SignEnv.t)
    (_s : stmt) : SignEnv.t * Finding.finding list =
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
