(* visitor.ml - AST visitor pattern exercises.
   Implement two common visitor-style operations that walk the AST
   and accumulate information. *)

open Shared_ast.Ast_types

(** Count the number of each node type in a statement list.
    Returns an association list like:
      [("Assign", 3); ("IntLit", 5); ("BinOp", 2); ...]
    The keys are constructor names WITHOUT parameters (e.g., "IntLit"
    not "IntLit(3)"). Order does not matter.

    Hint:
      - Write recursive helpers for expr and stmt.
      - Use a mutable Hashtbl or a ref to a Map to accumulate counts,
        or thread an accumulator through the recursion.
      - Don't forget to count the node itself AND recurse into its
        children. *)
let count_nodes (_stmts : stmt list) : (string * int) list =
  (* TODO: walk the AST and count occurrences of each constructor *)
  failwith "TODO"

(** Evaluate a constant expression, returning Some int if the
    expression contains only integer literals and arithmetic operators,
    or None if it contains variables, booleans, calls, or comparison
    operators.

    Supported operators: Add, Sub, Mul, Div (integer division).
    Division by zero should return None.

    Examples:
      evaluate (IntLit 42)                        => Some 42
      evaluate (BinOp (Add, IntLit 1, IntLit 2))  => Some 3
      evaluate (BinOp (Add, IntLit 1, Var "x"))   => None
      evaluate (BoolLit true)                      => None

    Hint: use Option.bind or match on recursive results. *)
let evaluate (_e : expr) : int option =
  (* TODO: evaluate constant integer expressions *)
  failwith "TODO"
