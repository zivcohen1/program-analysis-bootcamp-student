(** Sample programs for abstract interpretation analysis. *)

open Shared_ast.Ast_types

(** Simple constant assignment. *)
let constant_program : func_def =
  { name = "constants"; params = [];
    body = [
      Assign ("x", IntLit 5);
      Assign ("y", IntLit 3);
      Assign ("z", BinOp (Add, Var "x", Var "y"));
    ] }

(** Program with potential division by zero. *)
let div_by_zero_program : func_def =
  { name = "div_danger"; params = ["a"];
    body = [
      Assign ("b", BinOp (Sub, Var "a", Var "a"));
      Assign ("c", BinOp (Div, IntLit 10, Var "b"));
    ] }

(** Program where division is safe. *)
let safe_div_program : func_def =
  { name = "safe_div"; params = [];
    body = [
      Assign ("x", IntLit 5);
      Assign ("y", BinOp (Add, Var "x", IntLit 1));
      Assign ("z", BinOp (Div, IntLit 100, Var "y"));
    ] }

(** Program with a branch. *)
let branch_program : func_def =
  { name = "branch"; params = ["x"];
    body = [
      Assign ("a", IntLit 1);
      If (BinOp (Gt, Var "x", IntLit 0),
        [Assign ("a", IntLit 10)],
        [Assign ("a", IntLit 20)]);
      Assign ("b", BinOp (Add, Var "a", IntLit 1));
    ] }

(** Program with a simple loop. *)
let loop_program : func_def =
  { name = "loop"; params = [];
    body = [
      Assign ("i", IntLit 0);
      While (BinOp (Lt, Var "i", IntLit 10),
        [Assign ("i", BinOp (Add, Var "i", IntLit 1))]);
    ] }
