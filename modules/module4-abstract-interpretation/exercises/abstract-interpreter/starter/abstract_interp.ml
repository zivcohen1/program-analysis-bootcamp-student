(** Abstract interpreter: evaluates programs over abstract domains.

    This module provides a functor [Make] that, given an abstract domain,
    produces an interpreter capable of:
    - Evaluating expressions abstractly
    - Transferring statements through abstract environments
    - Analyzing complete functions to produce per-statement environments
    - Detecting potential division-by-zero errors
*)

module StringMap = Map.Make (String)

(** Functor: given an ABSTRACT_DOMAIN, produce an abstract interpreter. *)
module Make (D : Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN) = struct

  module Env = Abstract_domains.Abstract_env.MakeEnv (D)

  (** Evaluate an expression in an abstract environment. *)
  let eval_expr (_env : Env.t) (_e : Shared_ast.Ast_types.expr) : D.t =
    failwith "TODO: recursively evaluate expressions using D operations"

  (** Transfer a single statement: given an input environment, produce
      the output environment after the statement executes. *)
  let transfer_stmt (_env : Env.t) (_s : Shared_ast.Ast_types.stmt) : Env.t =
    failwith "TODO: implement abstract transfer for Assign, If, While, Return, Print, Block"

  (** Transfer a sequence of statements. *)
  let transfer_stmts (_env : Env.t) (_stmts : Shared_ast.Ast_types.stmt list) : Env.t =
    failwith "TODO: fold transfer_stmt over the statement list"

  (** Analyze a function: run abstract interpretation on its body,
      starting from an initial environment where parameters are Top. *)
  let analyze_function (_func : Shared_ast.Ast_types.func_def) : Env.t =
    failwith "TODO: build initial env with params -> D.top, then transfer body"

  (** Check a function for potential division-by-zero.
      Returns a list of (variable, message) pairs for each division
      where the divisor may be zero. *)
  let check_div_by_zero (_func : Shared_ast.Ast_types.func_def) : (string * string) list =
    failwith "TODO: walk the function body collecting divisions where divisor may be zero"
end

(* ------------------------------------------------------------------ *)
(* Built-in domain implementations for self-contained use             *)
(* ------------------------------------------------------------------ *)

(** Sign domain -- self-contained version for this exercise. *)
module SignDomain : Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN = struct
  type t = Bot | Neg | Zero | Pos | Top [@@warning "-37"]

  let bottom = Bot
  let top = Top

  let join a b = match a, b with
    | Bot, x | x, Bot -> x
    | x, y when x = y -> x
    | _ -> Top

  let meet a b = match a, b with
    | Top, x | x, Top -> x
    | x, y when x = y -> x
    | _ -> Bot

  let leq a b = match a, b with
    | Bot, _ -> true | _, Top -> true
    | x, y -> x = y

  let equal a b = a = b

  let widen a b = join a b

  let to_string = function
    | Bot -> "Bot" | Neg -> "Neg" | Zero -> "Zero"
    | Pos -> "Pos" | Top -> "Top"
end

(** Constant domain -- self-contained version for this exercise. *)
module ConstDomain : Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN = struct
  type t = Bot | Const of int | Top

  let bottom = Bot
  let top = Top

  let join a b = match a, b with
    | Bot, x | x, Bot -> x
    | Const m, Const n when m = n -> Const m
    | _ -> Top

  let meet a b = match a, b with
    | Top, x | x, Top -> x
    | Const m, Const n when m = n -> Const m
    | _ -> Bot

  let leq a b = match a, b with
    | Bot, _ -> true | _, Top -> true
    | Const m, Const n -> m = n
    | _ -> false

  let equal a b = a = b

  let widen a b = join a b

  let to_string = function
    | Bot -> "Bot" | Const n -> Printf.sprintf "Const(%d)" n
    | Top -> "Top"
end

(** Interval domain -- self-contained version for this exercise. *)
module IntervalDomain : Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN = struct
  type bound = NegInf | Finite of int | PosInf [@@warning "-37"]
  type t = Bot | Interval of bound * bound

  let bound_leq a b = match a, b with
    | NegInf, _ -> true | _, PosInf -> true
    | Finite m, Finite n -> m <= n
    | _ -> false

  let min_b a b = if bound_leq a b then a else b
  let max_b a b = if bound_leq a b then b else a

  let bottom = Bot
  let top = Interval (NegInf, PosInf)

  let join a b = match a, b with
    | Bot, x | x, Bot -> x
    | Interval (l1,h1), Interval (l2,h2) ->
      Interval (min_b l1 l2, max_b h1 h2)

  let make lo hi = if bound_leq lo hi then Interval (lo, hi) else Bot

  let meet a b = match a, b with
    | Bot, _ | _, Bot -> Bot
    | Interval (l1,h1), Interval (l2,h2) ->
      make (max_b l1 l2) (min_b h1 h2)

  let leq a b = match a, b with
    | Bot, _ -> true | _, Bot -> false
    | Interval (l1,h1), Interval (l2,h2) ->
      bound_leq l2 l1 && bound_leq h1 h2

  let equal a b = a = b

  let widen a b = match a, b with
    | Bot, x -> x | x, Bot -> x
    | Interval (l1,h1), Interval (l2,h2) ->
      let nl = if bound_leq l1 l2 then l1 else NegInf in
      let nh = if bound_leq h2 h1 then h1 else PosInf in
      Interval (nl, nh)

  let bts = function NegInf -> "-inf" | PosInf -> "+inf"
    | Finite n -> string_of_int n

  let to_string = function
    | Bot -> "Bot"
    | Interval (lo, hi) -> Printf.sprintf "[%s, %s]" (bts lo) (bts hi)
end
