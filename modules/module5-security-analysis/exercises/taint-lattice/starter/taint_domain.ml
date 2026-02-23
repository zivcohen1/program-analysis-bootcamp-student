(** Taint abstract domain.

    The taint lattice is a four-element flat lattice:

        Top          "may be tainted or untainted"
       / \
   Tainted  Untainted
       \ /
        Bot          "unreachable"

    Implement all functions to satisfy
    {!Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN}.
*)

type taint = Bot | Untainted | Tainted | Top

(* ------------------------------------------------------------------ *)
(* ABSTRACT_DOMAIN operations                                         *)
(* ------------------------------------------------------------------ *)

(** The least element: unreachable. *)
let bottom : taint =
  failwith "TODO: return the bottom element"

(** The greatest element: no information. *)
let top : taint =
  failwith "TODO: return the top element"

(** Least upper bound of two taint values. *)
let join (_a : taint) (_b : taint) : taint =
  failwith "TODO: implement join (least upper bound)"

(** Greatest lower bound of two taint values. *)
let meet (_a : taint) (_b : taint) : taint =
  failwith "TODO: implement meet (greatest lower bound)"

(** Partial order: [leq a b] iff [a] is below [b] in the lattice. *)
let leq (_a : taint) (_b : taint) : bool =
  failwith "TODO: implement partial order"

(** Equality on taint values. *)
let equal (_a : taint) (_b : taint) : bool =
  failwith "TODO: implement equality"

(** Widening operator. For this finite lattice, widening = join. *)
let widen (_a : taint) (_b : taint) : taint =
  failwith "TODO: implement widening"

(** Pretty-print a taint value. *)
let to_string (_t : taint) : string =
  failwith "TODO: implement to_string"

(* ------------------------------------------------------------------ *)
(* Taint-specific operations                                          *)
(* ------------------------------------------------------------------ *)

(** [is_potentially_tainted t] returns true if [t] may be tainted,
    i.e. [t] is [Tainted] or [Top]. *)
let is_potentially_tainted (_t : taint) : bool =
  failwith "TODO: check if value may be tainted"

(** [propagate a b] combines taint from two operands.
    If either operand is (potentially) tainted, the result is tainted.
    Bot propagates as Bot. *)
let propagate (_a : taint) (_b : taint) : taint =
  failwith "TODO: implement taint propagation"
