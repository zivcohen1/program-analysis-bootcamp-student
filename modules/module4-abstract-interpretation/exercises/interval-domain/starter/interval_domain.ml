(** Interval abstract domain.

    Values are represented as intervals [lo, hi] where bounds can be
    finite integers or +/- infinity.

    This domain has infinite height and requires widening for
    termination of fixpoint iteration in loops.
*)

(** Bounds can be negative infinity, a finite integer, or positive infinity. *)
type bound = NegInf | Finite of int | PosInf

(** An interval is either bottom (empty) or a closed interval [lo, hi]. *)
type interval = Bot | Interval of bound * bound

(* ------------------------------------------------------------------ *)
(* Bound arithmetic helpers                                           *)
(* ------------------------------------------------------------------ *)

(** Add two bounds.  NegInf + PosInf is undefined; we treat it as Top
    by returning [-inf, +inf] at the interval level. *)
let add_bound (_a : bound) (_b : bound) : bound =
  failwith "TODO: implement bound addition"

(** Negate a bound: neg(PosInf) = NegInf, neg(Finite n) = Finite(-n). *)
let neg_bound (_a : bound) : bound =
  failwith "TODO: implement bound negation"

(** Minimum of two bounds. *)
let min_bound (_a : bound) (_b : bound) : bound =
  failwith "TODO: return the smaller bound"

(** Maximum of two bounds. *)
let max_bound (_a : bound) (_b : bound) : bound =
  failwith "TODO: return the larger bound"

(* ------------------------------------------------------------------ *)
(* ABSTRACT_DOMAIN operations                                         *)
(* ------------------------------------------------------------------ *)

let bottom : interval =
  failwith "TODO"

let top : interval =
  failwith "TODO"

let join (_a : interval) (_b : interval) : interval =
  failwith "TODO: least upper bound of two intervals"

let meet (_a : interval) (_b : interval) : interval =
  failwith "TODO: greatest lower bound (intersection) of two intervals"

let leq (_a : interval) (_b : interval) : bool =
  failwith "TODO: partial order (subset of intervals)"

let equal (_a : interval) (_b : interval) : bool =
  failwith "TODO: structural equality"

(** Widening: if bounds grow, jump to infinity.
    widen([a,b], [c,d]) =
      [ if c < a then -inf else a,
        if d > b then +inf else b ] *)
let widen (_a : interval) (_b : interval) : interval =
  failwith "TODO: implement widening operator"

let to_string (_v : interval) : string =
  failwith "TODO: pretty-print"

(* ------------------------------------------------------------------ *)
(* Interval queries                                                   *)
(* ------------------------------------------------------------------ *)

(** Does the interval contain zero? *)
let contains_zero (_v : interval) : bool =
  failwith "TODO"

(** Is the interval entirely non-negative (>= 0)? *)
let is_non_negative (_v : interval) : bool =
  failwith "TODO"

(* ------------------------------------------------------------------ *)
(* Abstract arithmetic                                                *)
(* ------------------------------------------------------------------ *)

let abstract_add (_a : interval) (_b : interval) : interval =
  failwith "TODO"

let abstract_sub (_a : interval) (_b : interval) : interval =
  failwith "TODO"

let abstract_mul (_a : interval) (_b : interval) : interval =
  failwith "TODO"

let abstract_neg (_a : interval) : interval =
  failwith "TODO"

(** Abstract division.  Returns Bot if the divisor definitely contains
    only zero.  Returns Top if the divisor may contain zero (conservative). *)
let abstract_div (_a : interval) (_b : interval) : interval =
  failwith "TODO"
