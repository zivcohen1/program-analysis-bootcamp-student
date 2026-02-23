---
title: Code Representation and Abstract Syntax Trees
theme: white
highlightTheme: github
transition: slide
---

# Code Representation and ASTs
## Module 2: Abstract Syntax Trees

**Instructor:** Weihao
**Office Hours:** By appointment, HH227

---

## Learning Objectives

- **Analyze** source code and construct AST representations
- **Implement** traversal algorithms (DFS, BFS, Visitor pattern)
- **Create** symbol tables with nested scope resolution
- **Apply** AST transformations (constant folding, renaming, dead code elimination)

---

## Why Do We Need ASTs?

Raw source code is just text:
```ocaml
let result = (2 + 3) * 4
```

To analyze it systematically, we need **structure**.

ASTs convert flat text into a tree that captures the program's logical organization.

---

## What is an AST?

**Abstract Syntax Tree:** A tree representation where:
- Each **node** represents a programming construct
- **Edges** represent containment/composition
- **Syntactic noise** (parentheses, semicolons) is removed
- **Semantic structure** is preserved

---

## AST Example

Expression: `(2 + 3) * 4`

```
        *
       / \
      +   4
     / \
    2   3
```

The tree structure encodes operator precedence directly.

---

## AST Node Categories: Expressions

**Expressions** evaluate to values:
- **Literals:** `42`, `"hello"`, `true`
- **Binary ops:** `a + b`, `x * y`
- **Unary ops:** `-x`, `!done`
- **Identifiers:** `x`, `myVar`

---

## AST Node Categories: Statements & Declarations

**Statements** perform actions:
- **Assignment:** `x = 5`
- **Control flow:** `if/else`, `while/for`, `return`

**Declarations** introduce names:
- **Variable:** `int x = 5`
- **Function:** `def foo()`
- **Class:** `class Bar`

---

## AST vs Parse Tree

| Feature | Parse Tree | AST |
|---------|-----------|-----|
| Parentheses | Included | Removed |
| Semicolons | Included | Removed |
| Intermediate grammar rules | Included | Removed |
| Semantic structure | Preserved | Preserved |
| Size | Larger | Compact |
| Use case | Parsing | Analysis |

ASTs are what analysis tools actually work with.

---

## Node Attributes

Each AST node carries metadata:

```ocaml
type ast_node = {
  value : string;          (* The operation or value *)
  children : ast_node list; (* Child nodes *)
  line : int option;       (* Source location *)
  col : int option;        (* Column number *)
  type_info : string option; (* Type annotation *)
}
```

---

## Building ASTs in OCaml

We define ASTs as algebraic data types:

```ocaml
type expr =
  | IntLit of int | BoolLit of bool | Var of string
  | BinOp of op * expr * expr
  | UnaryOp of uop * expr
  | Call of string * expr list

type stmt =
  | Assign of string * expr | If of expr * stmt list * stmt list
  | While of expr * stmt list | Return of expr option
  | Print of expr list
```

Each variant is a node type. Children are embedded directly.

---

## OCaml AST Example

```ocaml
(* if x > 0 then y = x + 1 *)
let example_ast =
  If (BinOp (Gt, Var "x", IntLit 0),
    [Assign ("y", BinOp (Add, Var "x", IntLit 1))],
    [])
(* If -> BinOp(Gt, Var "x", IntLit 0)
      -> [Assign("y", BinOp(Add, Var "x", IntLit 1))] *)
```

---

## Hierarchical Structure

`2 + 3 * 4` (precedence: * before +)

```
    BinOp(+)
    /       \
  2       BinOp(*)
          /      \
         3        4
```

Higher precedence operators appear **lower** in the tree.
The root operator is evaluated **last**.

---

## Lesson 2: Traversal Algorithms

How do we systematically visit every node in an AST?

Three main strategies:
1. **Pre-order DFS** (top-down)
2. **Post-order DFS** (bottom-up)
3. **BFS / Level-order**

---

## Pre-order Traversal

**Visit node FIRST, then children**

```
        *
       / \
      +   4
     / \
    2   3
```

Visit order: `*, +, 2, 3, 4`

Use case: Top-down analyses (type checking, scope entry)

---

## Pre-order Implementation

```ocaml
let rec pre_order node =
  node.value :: List.concat_map pre_order node.children
```

---

## Post-order Traversal

**Visit children FIRST, then node**

```
        *
       / \
      +   4
     / \
    2   3
```

Visit order: `2, 3, +, 4, *`

Use case: Bottom-up analyses (expression evaluation, code generation)

---

## Post-order Implementation

```ocaml
let rec post_order node =
  List.concat_map post_order node.children @ [node.value]
```

---

## BFS / Level-order Traversal

**Visit all nodes at depth d before depth d+1**

```
        *         ← Level 0
       / \
      +   4       ← Level 1
     / \
    2   3         ← Level 2
```

Visit order: `*, +, 4, 2, 3`

Use case: Level-based analysis, finding shortest paths

---

## BFS Implementation

```ocaml
let bfs root =
  let q = Queue.create () in
  Queue.push root q;
  let result = ref [] in
  while not (Queue.is_empty q) do
    let current = Queue.pop q in
    result := current.value :: !result;
    List.iter (fun c -> Queue.push c q) current.children
  done;
  List.rev !result
```

---

## Pattern Matching over ASTs

In OCaml, **pattern matching** replaces the visitor pattern:

```ocaml
let rec visit_expr = function
  | IntLit n -> handle_int n
  | Var s -> handle_var s
  | BinOp (op, l, r) ->
    visit_expr l; visit_expr r; handle_binop op
  | _ -> ()
```

Add new analyses by writing new `match` functions -- no class hierarchy needed.

---

## Example: Node Counter

```ocaml
let count_nodes stmts =
  let counts = Hashtbl.create 16 in
  let inc key =
    let n = try Hashtbl.find counts key with Not_found -> 0 in
    Hashtbl.replace counts key (n + 1) in
  let rec count_expr = function
    | IntLit _ -> inc "IntLit" | Var _ -> inc "Var"
    | BinOp (_, l, r) -> inc "BinOp"; count_expr l; count_expr r
    | _ -> () in
  let rec count_stmt = function
    | Assign (_, e) -> inc "Assign"; count_expr e
    | If (c, t, e) -> inc "If"; count_expr c;
        List.iter count_stmt t; List.iter count_stmt e
    | _ -> () in
  List.iter count_stmt stmts; counts
```

---

## Traversal State Management

Complex analyses pass context through parameters:

```ocaml
let rec analyze_stmt scope = function
  | Assign (name, expr) ->
    let scope' = define scope name in  (* update scope *)
    analyze_expr scope' expr
  | If (cond, then_b, else_b) ->
    let inner = enter_scope scope in   (* new scope *)
    List.iter (analyze_stmt inner) then_b;
    List.iter (analyze_stmt inner) else_b
  | _ -> ()
```

---

## Lesson 3: Symbol Tables

**Problem:** How do we track which variables are declared where, and resolve references to the correct declaration?

```ocaml
let x = 10              (* global x *)
let foo () =
  let x = 20 in         (* local x, shadows global *)
  print_int x           (* which x? → local (20) *)
let () = print_int x    (* which x? → global (10) *)
```

---

## Symbol Table Structure

```ocaml
module StringMap = Map.Make(String)

type t = symbol_info StringMap.t list  (* scope stack *)

let create () = [StringMap.empty]

let define scope name info = match scope with
  | top :: rest -> StringMap.add name info top :: rest
  | [] -> failwith "no scope"

let rec lookup scope name = match scope with
  | top :: rest ->
    (match StringMap.find_opt name top with
     | Some info -> Some info
     | None -> lookup rest name)
  | [] -> None
```

---

## Scope Chains

```
Global Scope: { x: int, foo: function }
    │
    └── foo's Scope: { x: int }
            │
            └── Block Scope: { y: int }
```

Lookup walks **up** the chain: block → function → global

---

## Shadowing

When an inner scope declares a name that exists in an outer scope:

```ocaml
let x = 10               (* global scope: x = 10 *)
let foo () =
  let x = 20 in          (* foo scope: x = 20, shadows global *)
  let bar () =
    print_int x in        (* resolves to foo's x = 20 *)
  bar ()
```

---

## Lesson 4: AST Transformations

ASTs aren't just for reading -- we can **modify** them.

Three fundamental transformations:
1. **Constant Folding:** `2 + 3` → `5`
2. **Variable Renaming:** `x` → `count`
3. **Dead Code Elimination:** Remove unreachable code

---

## Constant Folding

Replace constant expressions with their computed values:

```
Before:           After:
    *                *
   / \              / \
  +   4      →     5   4    →    20
 / \
2   3
```

---

## Variable Renaming

Update all references consistently:

```ocaml
(* Before: rename 'x' to 'count' *)
[Assign ("x", IntLit 0);
 Assign ("x", BinOp (Add, Var "x", IntLit 1));
 Print [Var "x"]]
(* After: *)
[Assign ("count", IntLit 0);
 Assign ("count", BinOp (Add, Var "count", IntLit 1));
 Print [Var "count"]]
```

Must update both declarations AND references.

---

## Dead Code Elimination

Remove code that can never execute:

```ocaml
(* Before: *)
[Return (Some (IntLit 42));
 Print [Var "unreachable"]]   (* ← remove this *)

If (BoolLit true,             (* constant condition *)
  [Assign ("x", IntLit 1)],
  [Assign ("x", IntLit 2)])   (* ← remove else branch *)
```

---

## Transformation Safety

Transformations must preserve program semantics:

- **Immutable updates:** Create new nodes rather than modifying in-place
- **Parent-child consistency:** Update all references when moving nodes
- **Scope awareness:** Variable renaming must respect scope boundaries
- **Order matters:** Apply transformations in the right sequence

---

## Hands-On Exercises

Four exercises building incrementally:

1. **AST Structure Mapping** - Visualize ASTs using `shared_ast` types
2. **Traversal Algorithms** - Implement DFS and BFS via pattern matching
3. **Symbol Table** - Build scoped symbol table with `Map.Make(String)`
4. **AST Transformations** - Constant folding, renaming, dead code elimination

---

## Key Takeaways

- **ASTs provide structured representations** of code for systematic analysis
- **Different traversals serve different needs:** pre-order (top-down), post-order (bottom-up), BFS (level-based)
- **Symbol tables** track identifiers across nested scopes using scope chains
- **AST transformations** enable automated refactoring and optimization
- These concepts are the foundation for **all program analysis tools**

---

## Next Module Preview

**Module 3: Static Analysis Fundamentals**

- Control Flow Graphs (CFGs)
- Dataflow analysis framework
- Reaching definitions, live variables
- Building your first static analyzer

**Prep:** Review set theory (union, intersection) and basic graph theory
