(** Taint abstract domain (provided -- not a TODO).

    Four-element flat lattice satisfying ABSTRACT_DOMAIN. *)

type taint = Bot | Untainted | Tainted | Top

let bottom : taint = Bot
let top : taint = Top

let join (a : taint) (b : taint) : taint =
  match a, b with
  | Bot, x | x, Bot -> x
  | x, y when x = y -> x
  | Top, _ | _, Top -> Top
  | _ -> Top

let meet (a : taint) (b : taint) : taint =
  match a, b with
  | Top, x | x, Top -> x
  | x, y when x = y -> x
  | Bot, _ | _, Bot -> Bot
  | _ -> Bot

let leq (a : taint) (b : taint) : bool =
  match a, b with
  | Bot, _ -> true
  | _, Top -> true
  | x, y -> x = y

let equal (a : taint) (b : taint) : bool = a = b
let widen (a : taint) (b : taint) : taint = join a b

let to_string (t : taint) : string =
  match t with
  | Bot -> "Bot" | Untainted -> "Untainted"
  | Tainted -> "Tainted" | Top -> "Top"

let is_potentially_tainted (t : taint) : bool =
  match t with Tainted | Top -> true | _ -> false

let propagate (a : taint) (b : taint) : taint =
  match a, b with
  | Bot, _ | _, Bot -> Bot
  | Tainted, _ | _, Tainted -> Tainted
  | Top, _ | _, Top -> Top
  | Untainted, Untainted -> Untainted
