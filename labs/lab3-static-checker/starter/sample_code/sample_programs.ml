(* Pre-built ASTs for testing the static checker.
   These use Ast_types from the shared_ast library directly,
   so no parser is needed. *)

open Shared_ast.Ast_types

(** A function where variable "unused" is assigned but never read.
    Equivalent to:
      def unused_example(x):
        unused = 42
        y = x + 1
        return y *)
let unused_var_program : program =
  [
    {
      name = "unused_example";
      params = ["x"];
      body = [
        Assign ("unused", IntLit 42);
        Assign ("y", BinOp (Add, Var "x", IntLit 1));
        Return (Some (Var "y"));
      ];
    };
  ]

(** A function with code after a return statement.
    Equivalent to:
      def unreachable_example():
        return 1
        x = 2
        return x *)
let unreachable_code_program : program =
  [
    {
      name = "unreachable_example";
      params = [];
      body = [
        Return (Some (IntLit 1));
        Assign ("x", IntLit 2);
        Return (Some (Var "x"));
      ];
    };
  ]

(** A function where variable "x" is assigned at the outer level
    and then re-assigned inside an if block (shadowing).
    Equivalent to:
      def shadow_example(flag):
        x = 10
        if flag:
          x = 20
        return x *)
let shadow_program : program =
  [
    {
      name = "shadow_example";
      params = ["flag"];
      body = [
        Assign ("x", IntLit 10);
        If (
          Var "flag",
          [ Assign ("x", IntLit 20) ],   (* then branch: shadows outer x *)
          []                               (* else branch: empty *)
        );
        Return (Some (Var "x"));
      ];
    };
  ]

(** A function with no issues -- everything is clean.
    Equivalent to:
      def clean_example(a, b):
        c = a + b
        return c *)
let clean_program : program =
  [
    {
      name = "clean_example";
      params = ["a"; "b"];
      body = [
        Assign ("c", BinOp (Add, Var "a", Var "b"));
        Return (Some (Var "c"));
      ];
    };
  ]
