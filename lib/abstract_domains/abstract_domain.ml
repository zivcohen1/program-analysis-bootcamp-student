(** Abstract domain module type for abstract interpretation.

    Extends the LATTICE signature from Module 3 with partial ordering
    ([leq]) and a widening operator ([widen]) needed for domains with
    infinite ascending chains (e.g. intervals).

    Every abstract domain used in Module 4 satisfies this signature.
*)

module type ABSTRACT_DOMAIN = sig
  type t

  (** The least element: no information / unreachable. *)
  val bottom : t

  (** The greatest element: no knowledge about value. *)
  val top : t

  (** Least upper bound. *)
  val join : t -> t -> t

  (** Greatest lower bound. *)
  val meet : t -> t -> t

  (** Partial order: [leq a b] iff [a] is below [b] in the lattice.
      Equivalently, [join a b = b]. *)
  val leq : t -> t -> bool

  (** Equality on abstract values. *)
  val equal : t -> t -> bool

  (** Widening operator.  For finite-height domains this can simply be
      [join].  For infinite-height domains (e.g. intervals) widening
      must guarantee termination of the ascending chain. *)
  val widen : t -> t -> t

  (** Pretty-print an abstract value. *)
  val to_string : t -> string
end
