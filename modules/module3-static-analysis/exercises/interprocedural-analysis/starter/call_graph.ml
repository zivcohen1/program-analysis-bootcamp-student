(** Interprocedural Analysis: Call Graph Construction

    Build a call graph from a program and use it to answer questions
    about function relationships like reachability and recursion. *)

open Shared_ast.Ast_types

module StringSet = Set.Make(String)
module StringMap = Map.Make(String)

type call_graph = {
  nodes : StringSet.t;               (** All function names in the program *)
  edges : StringSet.t StringMap.t;   (** caller -> set of callees *)
}

(** Extract function names called in an expression.

    Walk the expression tree and collect every function name that
    appears in a [Call(name, args)] node. Don't forget to also
    recurse into the argument expressions -- a call like
    [f(g(x))] should return both "f" and "g".

    Examples:
    - [IntLit 5] -> []
    - [Call("f", [Var "x"])] -> ["f"]
    - [Call("f", [Call("g", [IntLit 1])])] -> ["f"; "g"]
    - [BinOp(Add, Call("a", []), Call("b", []))] -> ["a"; "b"] *)
(* Hint: You will need [let rec] when you implement this. *)
let calls_in_expr (_expr : expr) : string list =
  failwith "TODO: Extract function calls from an expression"

(** Extract all function names called in a list of statements.

    Walk every statement recursively:
    - [Assign(_, e)] -> calls in e
    - [If(cond, then_branch, else_branch)] -> calls in cond + both branches
    - [While(cond, body)] -> calls in cond + body
    - [Return(Some e)] -> calls in e
    - [Return(None)] -> []
    - [Print(exprs)] -> calls in each expr
    - [Block(stmts)] -> recurse into stmts *)
(* Hint: You will need [let rec ... and ...] for mutual recursion
   between calls_in_stmts and a per-statement helper. *)
let calls_in_stmts (_stmts : stmt list) : string list =
  failwith "TODO: Extract all function calls from a statement list"

(** Build a call graph from a program.

    For each function definition in the program:
    1. Add it as a node in the graph
    2. Find all function calls in its body using [calls_in_stmts]
    3. Record these as edges: caller -> {callees}

    The result should have:
    - [nodes]: the set of all function names
    - [edges]: a map from each function name to the set of functions it calls *)
let build_call_graph (_program : program) : call_graph =
  failwith "TODO: Build call graph from a program"

(** Find all functions reachable from a given starting function.

    Perform a BFS or DFS traversal following the call graph edges.
    Return the set of all functions that can be reached (directly
    or transitively), NOT including the starting function itself
    (unless it calls itself recursively).

    Example for: main -> process_data -> helper
    - [reachable_from graph "main"] = {"process_data", "helper"}
    - [reachable_from graph "process_data"] = {"helper"}
    - [reachable_from graph "helper"] = {} *)
let reachable_from (_cg : call_graph) (_start : string) : StringSet.t =
  failwith "TODO: Find all reachable functions from a given function"

(** Detect recursive functions in the call graph.

    A function is recursive if it appears in a cycle in the call graph.
    This includes:
    - Direct recursion: f calls f
    - Mutual recursion: f calls g, g calls f

    Hint: A function f is recursive if f is in [reachable_from graph f].

    Return a sorted list of all recursive function names. *)
let find_recursive (_cg : call_graph) : string list =
  failwith "TODO: Detect recursive functions"
