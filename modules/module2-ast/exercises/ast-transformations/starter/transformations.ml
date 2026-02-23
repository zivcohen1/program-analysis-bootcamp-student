(* transformations.ml - AST transformation passes.

   Each transformation is a pure function: it takes an AST (or part of one)
   and returns a *new* AST with the transformation applied.  The original
   tree is never mutated.

   Implement the three transformations below.  Each one exercises a
   different kind of recursive tree rewriting. *)

open Shared_ast.Ast_types

(* --------------------------------------------------------------------------
   1. Constant folding
   --------------------------------------------------------------------------
   Simplify expressions whose operands are known at compile time.

   Strategy:
     - Recursively fold sub-expressions first (bottom-up).
     - After folding, check whether a BinOp has two IntLit children.
       If so, evaluate the operation and return a single IntLit (or BoolLit
       for comparison / logical operators).
     - Leave everything else unchanged.

   Examples:
     BinOp(Add, IntLit 2, IntLit 3)           --> IntLit 5
     BinOp(Mul, IntLit 2, BinOp(Add, IntLit 1, IntLit 3))
                                                --> IntLit 8
     BinOp(Add, Var "x", IntLit 1)            --> BinOp(Add, Var "x", IntLit 1)
*)
let constant_fold (_expr : expr) : expr =
  (* TODO *)
  failwith "TODO"

(* --------------------------------------------------------------------------
   2. Variable renaming
   --------------------------------------------------------------------------
   Replace every occurrence of a variable named [old_name] with [new_name]
   throughout a list of statements.  This includes:
     - Var references inside expressions
     - The left-hand side of Assign statements
   Other identifiers (function names in Call, etc.) are left alone.

   You will need a helper to rename inside expressions as well.

   Example:
     rename_variable "x" "tmp"
       [Assign("x", IntLit 1); Print [Var "x"]]
     -->
       [Assign("tmp", IntLit 1); Print [Var "tmp"]]
*)
let rename_variable (_old_name : string) (_new_name : string)
    (_stmts : stmt list) : stmt list =
  (* TODO *)
  failwith "TODO"

(* --------------------------------------------------------------------------
   3. Dead-code elimination
   --------------------------------------------------------------------------
   Remove statements that can never execute.  Two cases to handle:

   a) Unreachable code after Return:
      In a statement list, once a Return is encountered, all subsequent
      statements in that same list are dead and should be removed.

   b) Trivially-decided If:
      - If(BoolLit true,  then_branch, _)  --> replace with then_branch
      - If(BoolLit false, _, else_branch)   --> replace with else_branch

   Apply these rules recursively into nested blocks (If branches, While
   bodies, Block contents).

   Example:
     [Return (Some (IntLit 42)); Print [Var "unreachable"]]
     -->
     [Return (Some (IntLit 42))]
*)
let eliminate_dead_code (_stmts : stmt list) : stmt list =
  (* TODO *)
  failwith "TODO"
