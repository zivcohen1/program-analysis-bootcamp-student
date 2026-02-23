(** Taint abstract domain.

    Four-element flat lattice: Bot < Untainted, Tainted < Top.
    Satisfies {!Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN}. *)

type taint = Bot | Untainted | Tainted | Top

val bottom : taint
val top : taint
val join : taint -> taint -> taint
val meet : taint -> taint -> taint
val leq : taint -> taint -> bool
val equal : taint -> taint -> bool
val widen : taint -> taint -> taint
val to_string : taint -> string

(** Returns true if the value may be tainted (Tainted or Top). *)
val is_potentially_tainted : taint -> bool

(** Propagation: combines taint from two operands.
    Tainted if either operand is potentially tainted. *)
val propagate : taint -> taint -> taint
