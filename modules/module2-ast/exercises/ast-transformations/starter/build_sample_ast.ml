(* build_sample_ast.ml - Sample AST fragments for testing transformations.

   Each value is a small AST snippet that exercises one of the three
   transformations in transformations.ml.  You can load these in utop
   or pass them to your transformation functions in tests. *)

open Shared_ast.Ast_types

(* --- Constant folding --------------------------------------------------- *)

(* x = 2 + 3   (should fold to x = 5) *)
let fold_example : stmt =
  Assign ("x", BinOp (Add, IntLit 2, IntLit 3))

(* --- Variable renaming -------------------------------------------------- *)

(* x = 1; y = x; print(x)
   Renaming "x" -> "tmp" should give: tmp = 1; y = tmp; print(tmp) *)
let rename_example : stmt list =
  [ Assign ("x", IntLit 1);
    Assign ("y", Var "x");
    Print [Var "x"] ]

(* --- Dead-code elimination ---------------------------------------------- *)

(* return 42; print(unreachable)
   The Print after Return is dead code and should be removed. *)
let dead_code_example : stmt list =
  [ Return (Some (IntLit 42));
    Print [Var "unreachable"] ]
