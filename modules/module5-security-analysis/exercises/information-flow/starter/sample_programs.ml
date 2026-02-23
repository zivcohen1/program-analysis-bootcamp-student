(** Sample programs for information flow testing (provided). *)

open Shared_ast.Ast_types

(** Explicit flow: direct data dependency. *)
let explicit_flow : program =
  [{ name = "explicit"; params = [];
     body = [
       Assign ("secret", Call ("get_param", [IntLit 0]));
       Assign ("x", Var "secret");
     ] }]

(** Implicit flow: control dependency via if-then-else. *)
let implicit_flow : program =
  [{ name = "implicit"; params = [];
     body = [
       Assign ("secret", Call ("get_param", [IntLit 0]));
       If (Var "secret",
         [Assign ("x", IntLit 1)],
         [Assign ("x", IntLit 0)]);
     ] }]

(** Nested implicit flow: nested if with tainted condition. *)
let nested_implicit : program =
  [{ name = "nested"; params = [];
     body = [
       Assign ("secret", Call ("get_param", [IntLit 0]));
       If (Var "secret",
         [If (BoolLit true,
           [Assign ("x", IntLit 1)],
           [Assign ("x", IntLit 2)])],
         [Assign ("x", IntLit 0)]);
     ] }]

(** Loop implicit flow: while with tainted condition. *)
let loop_implicit : program =
  [{ name = "loop"; params = [];
     body = [
       Assign ("secret", Call ("get_param", [IntLit 0]));
       Assign ("x", IntLit 0);
       While (Var "secret",
         [Assign ("x", BinOp (Add, Var "x", IntLit 1))]);
     ] }]
