(** Galois connections for abstract interpretation.

    A Galois connection (C, alpha, gamma, A) formalizes the
    relationship between concrete and abstract domains:

    - alpha : C -> A  (abstraction: concrete -> abstract)
    - gamma : A -> C  (concretization: abstract -> concrete)

    The adjunction property:
      alpha(c) <= a   iff   c <= gamma(a)

    This exercise uses the sign domain as the abstract domain
    and sets of integers as the concrete domain.
*)

module IntSet = Set.Make (Int)

(** Sign type -- matches the sign lattice from Exercise 1.
    We redefine it here so this exercise is self-contained. *)
type sign = Bot | Neg | Zero | Pos | Top

(* ------------------------------------------------------------------ *)
(* Ordering on signs (needed for Galois connection checks)            *)
(* ------------------------------------------------------------------ *)

let sign_leq (_a : sign) (_b : sign) : bool =
  failwith "TODO: partial order on signs (same as Exercise 1)"

let sign_equal (_a : sign) (_b : sign) : bool =
  failwith "TODO: equality on signs"

let sign_to_string (_s : sign) : string =
  failwith "TODO: pretty-print a sign"

(* ------------------------------------------------------------------ *)
(* Alpha: abstraction function                                        *)
(* ------------------------------------------------------------------ *)

(** Abstract a single integer to its sign. *)
let alpha_int (_n : int) : sign =
  failwith "TODO: map an integer to Neg, Zero, or Pos"

(** Abstract a set of integers to a sign.
    The result must be the *least* sign that covers all integers in
    the set.  An empty set maps to Bot. *)
let alpha (_s : IntSet.t) : sign =
  failwith "TODO: fold over the set, joining individual signs"

(* ------------------------------------------------------------------ *)
(* Gamma: concretization function                                     *)
(* ------------------------------------------------------------------ *)

(** Concretize a sign to a (possibly infinite) description.
    Since we cannot represent infinite sets, we return a finite
    *representative* subset plus a flag indicating whether the
    set is exact or an approximation.

    gamma_repr Bot  = (empty, true)     -- exact
    gamma_repr Zero = ({0}, true)       -- exact
    gamma_repr Neg  = ({-1,-2,-3,...}, false)  -- sample, not exact
    gamma_repr Pos  = ({1,2,3,...}, false)     -- sample, not exact
    gamma_repr Top  = ({-1,0,1,...}, false)    -- sample, not exact
*)
let gamma_repr (_s : sign) : IntSet.t * bool =
  failwith "TODO: return (representative_set, is_exact)"

(** Check whether a concrete integer is in gamma(a). *)
let in_gamma (_n : int) (_a : sign) : bool =
  failwith "TODO: return true iff n is represented by sign a"

(* ------------------------------------------------------------------ *)
(* Galois connection verification                                     *)
(* ------------------------------------------------------------------ *)

(** Verify the adjunction property on a sample:
    alpha(c) <= a  iff  c is a subset of gamma(a).

    Since gamma may be infinite, we check using [in_gamma]. *)
let verify_adjunction (_c : IntSet.t) (_a : sign) : bool =
  failwith "TODO: check that alpha(c) <= a iff all elements of c are in gamma(a)"

(** Verify that alpha is monotone on two sample sets:
    if s1 is a subset of s2, then alpha(s1) <= alpha(s2). *)
let verify_alpha_monotone (_s1 : IntSet.t) (_s2 : IntSet.t) : bool =
  failwith "TODO: check monotonicity of alpha"
