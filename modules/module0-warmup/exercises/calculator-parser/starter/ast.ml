(** Calculator AST types.

    These are defined here so both the Menhir-generated parser
    and main.ml can reference them. *)

type op = Add | Sub | Mul | Div

type expr =
  | Num of int
  | Var of string
  | BinOp of op * expr * expr
  | Neg of expr
