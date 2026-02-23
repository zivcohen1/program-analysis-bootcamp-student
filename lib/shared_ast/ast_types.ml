type op =
  | Add | Sub | Mul | Div
  | Eq | Neq | Lt | Gt | Le | Ge
  | And | Or

type uop = Neg | Not

type expr =
  | IntLit of int
  | BoolLit of bool
  | Var of string
  | BinOp of op * expr * expr
  | UnaryOp of uop * expr
  | Call of string * expr list

type stmt =
  | Assign of string * expr
  | If of expr * stmt list * stmt list
  | While of expr * stmt list
  | Return of expr option
  | Print of expr list
  | Block of stmt list

type func_def = {
  name : string;
  params : string list;
  body : stmt list;
}

type program = func_def list
