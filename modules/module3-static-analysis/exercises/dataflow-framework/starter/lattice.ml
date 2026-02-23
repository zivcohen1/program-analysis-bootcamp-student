(** Lattice module types and implementations for dataflow analysis.

    A lattice provides the mathematical foundation for dataflow analysis:
    - bottom: the least element (no information)
    - top: the greatest element (all information)
    - join: least upper bound (combines information from branches)
    - meet: greatest lower bound (intersects information)

    The PowersetLattice models sets of strings, which is useful for
    analyses like reaching definitions, live variables, etc.
*)

module type LATTICE = sig
  type t

  (** The least element of the lattice. *)
  val bottom : t

  (** The greatest element of the lattice. *)
  val top : t

  (** Least upper bound: join a b >= a and join a b >= b. *)
  val join : t -> t -> t

  (** Greatest lower bound: meet a b <= a and meet a b <= b. *)
  val meet : t -> t -> t

  (** Equality test on lattice elements. *)
  val equal : t -> t -> bool

  (** Pretty-print a lattice element. *)
  val to_string : t -> string
end

module StringSet = Set.Make (String)

(** PowersetLattice: a lattice over sets of strings.

    The lattice ordering is subset inclusion:
    - bottom = empty set (no facts known)
    - top = the full universe of strings
    - join = set union (merge information from branches)
    - meet = set intersection

    The [universe] ref must be set before calling [top] so that
    the lattice knows the full set of possible elements.

    TODO: Implement all functions below. Each one currently raises
    [Failure "TODO"]. Replace them with correct implementations using
    the [StringSet] module.
*)
module PowersetLattice : sig
  include LATTICE with type t = StringSet.t
  val universe : StringSet.t ref
end = struct
  type t = StringSet.t

  let universe = ref StringSet.empty

  let bottom = failwith "TODO: return the least element of the powerset lattice"

  let top = failwith "TODO: return the greatest element of the powerset lattice"

  let join _a _b = failwith "TODO: compute the least upper bound (union)"

  let meet _a _b = failwith "TODO: compute the greatest lower bound (intersection)"

  let equal _a _b = failwith "TODO: test equality of two sets"

  let to_string _s = failwith "TODO: format as {a, b, c}"
end
