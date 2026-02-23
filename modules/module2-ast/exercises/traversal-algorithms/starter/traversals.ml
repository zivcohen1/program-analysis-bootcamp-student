(* traversals.ml - AST traversal algorithms exercise.
   Implement three classic tree traversal strategies on the AST:
   pre-order (depth-first), post-order (depth-first), and
   breadth-first (level-order).

   Each function walks a list of statements and collects a string label
   for every node visited. Labels should look like:
     Statements: "Assign", "If", "While", "Return", "Print", "Block"
     Expressions: "IntLit(3)", "BoolLit(true)", "Var(x)", "BinOp(+)",
                  "UnaryOp(-)", "Call(f)"
*)

open Shared_ast.Ast_types

(** Helper: produce a string label for a single expression node.
    Examples: IntLit(3), BoolLit(true), Var(x), BinOp(+), UnaryOp(-), Call(f) *)
let label_of_expr (_e : expr) : string =
  (* TODO: pattern match on the expression and return its label string *)
  failwith "TODO"

(** Helper: produce a string label for a single statement node.
    Examples: "Assign", "If", "While", "Return", "Print", "Block" *)
let label_of_stmt (_s : stmt) : string =
  (* TODO: pattern match on the statement and return its label string *)
  failwith "TODO"

(** Pre-order depth-first traversal.
    Visit the current node FIRST, then recurse into its children
    left-to-right.

    For example, on [Assign("x", BinOp(Add, IntLit 1, IntLit 2))]:
      ["Assign"; "BinOp(+)"; "IntLit(1)"; "IntLit(2)"]

    Hint: write a mutual recursion with helpers for expr and stmt lists. *)
let pre_order (_stmts : stmt list) : string list =
  (* TODO: implement pre-order DFS traversal *)
  (* 1. Emit the label of the current node
     2. Then recurse into children *)
  failwith "TODO"

(** Post-order depth-first traversal.
    Recurse into children FIRST, then visit the current node.

    For example, on [Assign("x", BinOp(Add, IntLit 1, IntLit 2))]:
      ["IntLit(1)"; "IntLit(2)"; "BinOp(+)"; "Assign"]

    Hint: same structure as pre_order but emit the label at the end. *)
let post_order (_stmts : stmt list) : string list =
  (* TODO: implement post-order DFS traversal *)
  (* 1. Recurse into children first
     2. Then emit the label of the current node *)
  failwith "TODO"

(** Breadth-first (level-order) traversal.
    Visit all nodes at depth d before any node at depth d+1.

    For example, on [Assign("x", BinOp(Add, IntLit 1, IntLit 2))]:
      ["Assign"; "BinOp(+)"; "IntLit(1)"; "IntLit(2)"]
    (In this small case it happens to match pre-order, but differs on
     deeper trees with multiple siblings.)

    Hint: use the OCaml Queue module.
      1. Seed the queue with all top-level stmts.
      2. Dequeue a node, emit its label, enqueue its children.
      3. Repeat until the queue is empty.
    You will need a sum type or two queues to handle both stmt and expr
    nodes uniformly. *)
let bfs (_stmts : stmt list) : string list =
  (* TODO: implement breadth-first traversal using Queue *)
  failwith "TODO"
