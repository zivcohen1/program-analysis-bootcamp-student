(** Flat constant abstract domain.

    The constant lattice:

              Top           "not a constant"
         /  |  |  |  \
    ... Const(-1) Const(0) Const(1) ...
         \  |  |  |  /
              Bot           "unreachable"

    Height 3, infinite width.
    Implements {!Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN}.
*)

type const_val = Bot | Const of int | Top

(* ------------------------------------------------------------------ *)
(* ABSTRACT_DOMAIN operations                                         *)
(* ------------------------------------------------------------------ *)

let bottom : const_val =
  failwith "TODO: return the bottom element"

let top : const_val =
  failwith "TODO: return the top element"

let join (_a : const_val) (_b : const_val) : const_val =
  failwith "TODO: least upper bound on flat lattice"

let meet (_a : const_val) (_b : const_val) : const_val =
  failwith "TODO: greatest lower bound on flat lattice"

let leq (_a : const_val) (_b : const_val) : bool =
  failwith "TODO: partial order on flat lattice"

let equal (_a : const_val) (_b : const_val) : bool =
  failwith "TODO: structural equality"

let widen (_a : const_val) (_b : const_val) : const_val =
  failwith "TODO: widening (same as join for finite-height domain)"

let to_string (_v : const_val) : string =
  failwith "TODO: pretty-print"

(* ------------------------------------------------------------------ *)
(* Abstract arithmetic                                                *)
(* ------------------------------------------------------------------ *)

(** Evaluate a binary operator on abstract constant values. *)
let abstract_binop (_op : Shared_ast.Ast_types.op) (_a : const_val) (_b : const_val) : const_val =
  failwith "TODO: implement abstract binary operations for Add, Sub, Mul, Div, Eq, Neq, Lt, Gt, Le, Ge"

(** Evaluate a unary operator on an abstract constant value. *)
let abstract_unaryop (_op : Shared_ast.Ast_types.uop) (_a : const_val) : const_val =
  failwith "TODO: implement abstract unary operations for Neg, Not"
