(** Sign abstract domain.

    The sign lattice has five elements:

        Top        (any sign -- no information)
       / | \
     Neg Zero Pos  (definitely negative / zero / positive)
       \ | /
        Bot        (unreachable -- bottom)

    This module implements {!Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN}.
*)

type sign = Bot | Neg | Zero | Pos | Top

(* ------------------------------------------------------------------ *)
(* ABSTRACT_DOMAIN operations                                         *)
(* ------------------------------------------------------------------ *)

let bottom : sign =
  failwith "TODO: return the bottom element"

let top : sign =
  failwith "TODO: return the top element"

let join (_a : sign) (_b : sign) : sign =
  failwith "TODO: compute the least upper bound of a and b"

let meet (_a : sign) (_b : sign) : sign =
  failwith "TODO: compute the greatest lower bound of a and b"

let leq (_a : sign) (_b : sign) : bool =
  failwith "TODO: return true iff a is below b in the lattice"

let equal (_a : sign) (_b : sign) : bool =
  failwith "TODO: return true iff a and b are the same sign"

let widen (_a : sign) (_b : sign) : sign =
  failwith "TODO: widening (for finite domains, same as join)"

let to_string (_s : sign) : string =
  failwith "TODO: pretty-print a sign value"

(* ------------------------------------------------------------------ *)
(* Abstraction function                                               *)
(* ------------------------------------------------------------------ *)

(** Map a concrete integer to its sign. *)
let alpha_int (_n : int) : sign =
  failwith "TODO: return Neg, Zero, or Pos depending on n"

(* ------------------------------------------------------------------ *)
(* Abstract arithmetic                                                *)
(* ------------------------------------------------------------------ *)

let abstract_neg (_a : sign) : sign =
  failwith "TODO: abstract unary negation"

let abstract_add (_a : sign) (_b : sign) : sign =
  failwith "TODO: abstract addition"

let abstract_sub (_a : sign) (_b : sign) : sign =
  failwith "TODO: abstract subtraction"

let abstract_mul (_a : sign) (_b : sign) : sign =
  failwith "TODO: abstract multiplication"

let abstract_div (_a : sign) (_b : sign) : sign =
  failwith "TODO: abstract division (Bot if divisor is Zero)"
