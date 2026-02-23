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

let bottom : sign = Bot

let top : sign = Top

let join (a : sign) (b : sign) : sign =
  match a, b with
  | Bot, x | x, Bot -> x
  | x, y when x = y -> x
  | Top, _ | _, Top -> Top
  | _ -> Top

let meet (a : sign) (b : sign) : sign =
  match a, b with
  | Top, x | x, Top -> x
  | x, y when x = y -> x
  | Bot, _ | _, Bot -> Bot
  | _ -> Bot

let leq (a : sign) (b : sign) : bool =
  match a, b with
  | Bot, _ -> true
  | _, Top -> true
  | x, y -> x = y

let equal (a : sign) (b : sign) : bool =
  a = b

let widen (a : sign) (b : sign) : sign =
  join a b

let to_string (s : sign) : string =
  match s with
  | Bot -> "Bot"
  | Neg -> "Neg"
  | Zero -> "Zero"
  | Pos -> "Pos"
  | Top -> "Top"

(* ------------------------------------------------------------------ *)
(* Abstraction function                                               *)
(* ------------------------------------------------------------------ *)

let alpha_int (n : int) : sign =
  if n < 0 then Neg
  else if n = 0 then Zero
  else Pos

(* ------------------------------------------------------------------ *)
(* Abstract arithmetic                                                *)
(* ------------------------------------------------------------------ *)

let abstract_neg (a : sign) : sign =
  match a with
  | Bot -> Bot
  | Neg -> Pos
  | Zero -> Zero
  | Pos -> Neg
  | Top -> Top

let abstract_add (a : sign) (b : sign) : sign =
  match a, b with
  | Bot, _ | _, Bot -> Bot
  | Top, _ | _, Top -> Top
  | Zero, x | x, Zero -> x
  | Neg, Neg -> Neg
  | Pos, Pos -> Pos
  | Neg, Pos | Pos, Neg -> Top

let abstract_sub (a : sign) (b : sign) : sign =
  abstract_add a (abstract_neg b)

let abstract_mul (a : sign) (b : sign) : sign =
  match a, b with
  | Bot, _ | _, Bot -> Bot
  | Zero, _ | _, Zero -> Zero
  | Top, _ | _, Top -> Top
  | Neg, Neg -> Pos
  | Pos, Pos -> Pos
  | Neg, Pos | Pos, Neg -> Neg

let abstract_div (a : sign) (b : sign) : sign =
  match a, b with
  | Bot, _ | _, Bot -> Bot
  | _, Zero -> Bot
  | Zero, _ -> Zero
  | Top, _ | _, Top -> Top
  | Neg, Neg -> Pos
  | Pos, Pos -> Pos
  | Neg, Pos | Pos, Neg -> Neg
