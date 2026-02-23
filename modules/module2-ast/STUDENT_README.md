# Module 2: Code Representation and Abstract Syntax Trees -- Student Guide

Welcome to Module 2! You will explore how compilers and analyzers represent
source code internally as Abstract Syntax Trees (ASTs). You will build
visualizers, traversal algorithms, a scoped symbol table, and AST
transformation passes -- all in OCaml.

```
Source Code  -->  Lexer  -->  Tokens  -->  Parser  -->  AST
                                                         |
                              +──────────────────────────+──────────────+
                              |              |           |              |
                         Visualize     Traverse     Symbol Table   Transform
                        (Exercise 1)  (Exercise 2)  (Exercise 3)  (Exercise 4)
```

**Exercises:** 4 (63 tests) | **Lab:** Lab 2 -- AST Parser (9 tests)
**Estimated time:** 1.5--2 hours for exercises, 2--3 hours for the lab

---

## Table of Contents

1. [How Exercises Work](#1-how-exercises-work)
2. [Background: The AST Types](#2-background-the-ast-types)
3. [Exercise 1: AST Structure Mapping (no tests)](#3-exercise-1-ast-structure-mapping-no-tests)
4. [Exercise 2: Traversal Algorithms (27 tests)](#4-exercise-2-traversal-algorithms-27-tests)
5. [Exercise 3: Symbol Table (6 tests)](#5-exercise-3-symbol-table-6-tests)
6. [Exercise 4: AST Transformations (30 tests)](#6-exercise-4-ast-transformations-30-tests)
7. [Lab 2: AST Parser and Analyzer (9 tests)](#7-lab-2-ast-parser-and-analyzer-9-tests)
8. [Troubleshooting](#8-troubleshooting)
9. [Exercise Progression Cheat Sheet](#9-exercise-progression-cheat-sheet)

---

## 1. How Exercises Work

For environment setup (OCaml, opam, dune, ounit2, menhir), follow the
instructions in `resources/tools/installation-guides/ocaml-setup.md`.

Each exercise has this structure:

```
exercises/traversal-algorithms/
├── dune                          <-- tells dune which dirs to build
├── starter/
│   ├── dune                      <-- library definition
│   ├── traversals.ml             <-- YOUR FILE -- edit this
│   └── visitor.ml                <-- YOUR FILE -- edit this
└── tests/
    ├── dune                      <-- test configuration
    └── test_traversals.ml        <-- read-only test file
```

**The workflow:**

1. **Read the starter file** -- types and docstrings are provided; every function
   body is `failwith "TODO"` with a comment explaining what to implement.

2. **Implement one function at a time** -- replace the `failwith` with real code.

3. **Run tests** -- see your progress:
   ```bash
   dune runtest modules/module2-ast/exercises/traversal-algorithms/
   ```

4. **Interpret the output:**

   **Early on** (many TODOs remaining), you will often see:
   ```
   Fatal error: exception Failure("TODO: ...")
   ```
   This means the tests hit a `failwith "TODO"` stub and crashed before they
   could run individually. Keep implementing functions from the top of the file.

   **Once enough functions are implemented**, you will see per-test results:
   ```
   ..E.FEEEE
   ```
   - `.` = test passed
   - `E` = error (your code threw an exception -- likely a remaining TODO)
   - `F` = failure (your code ran but returned the wrong answer -- check logic)

5. **Repeat** until all tests pass: `....................` (all dots!)

**Tips:**
- Implement functions **in the order they appear** in the file -- later functions
  often depend on earlier ones.
- Read the test file (`tests/test_*.ml`) to understand exactly what is expected.
- Tests are read-only -- do not modify them.
- Always run `dune` commands from the **repository root**, not from inside an
  exercise directory.

---

## 2. Background: The AST Types

All exercises in this module (except Exercise 3) use the shared AST types
defined in `lib/shared_ast/ast_types.ml`. You access them via
`Shared_ast.Ast_types` or with `open Shared_ast.Ast_types`.

### Operators

```ocaml
type op =
  | Add | Sub | Mul | Div          (* arithmetic *)
  | Eq | Neq | Lt | Gt | Le | Ge  (* comparison *)
  | And | Or                       (* logical *)

type uop = Neg | Not               (* unary operators *)
```

### Expressions

```ocaml
type expr =
  | IntLit of int              (* 42 *)
  | BoolLit of bool            (* true *)
  | Var of string              (* x *)
  | BinOp of op * expr * expr  (* x + y *)
  | UnaryOp of uop * expr      (* -x *)
  | Call of string * expr list (* f(x, y) *)
```

### Statements

```ocaml
type stmt =
  | Assign of string * expr           (* x = e *)
  | If of expr * stmt list * stmt list (* if e { ... } else { ... } *)
  | While of expr * stmt list         (* while e { ... } *)
  | Return of expr option             (* return e  or  return *)
  | Print of expr list                (* print(e1, e2) *)
  | Block of stmt list                (* { s1; s2; ... } *)
```

### Functions and Programs

```ocaml
type func_def = {
  name : string;
  params : string list;
  body : stmt list;
}

type program = func_def list
```

### How it fits together

Here is how the statement `x = (2 + 3) * 4` looks as an AST:

```
      Assign("x")
          |
      BinOp(Mul)
       /       \
  BinOp(Add)   IntLit(4)
   /     \
IntLit(2) IntLit(3)
```

Each node in the tree corresponds to one constructor from the types above.
Your exercises will build, walk, query, and rewrite these trees.

---

## 3. Exercise 1: AST Structure Mapping (no tests)

**Goal:** Build three visualization functions that render ASTs in different
formats. This is a warm-up exercise with no automated tests -- you run the
executable and inspect the output visually.

**Time:** ~20 minutes

**Files to edit:**
`exercises/ast-structure-mapping/starter/ast_visualizer.ml`

**Also provided:**
- `exercises/ast-structure-mapping/starter/sample_asts.ml` -- pre-built AST
  examples that re-export programs from `Shared_ast.Sample_programs`
- `exercises/ast-structure-mapping/starter/worksheet.md` -- guided hand-drawing
  exercises (fill in on paper or in the file)

### What to implement

| # | Function | What it does |
|---|----------|-------------|
| 1 | `dump_expr` / `dump_stmt` / `dump_stmts` / `dump_ast` | Indented tree dump: each node on its own line, children indented 2 more spaces |
| 2 | `inc` / `count_expr` / `count_stmt` / `count_stmts` / `count_node_types` | Walk the AST and count how many of each node type appear; return an association list |
| 3 | `string_of_op` / `string_of_uop` / `expr_to_string` / `pp_stmt` / `pp_stmts` / `print_tree` | Pretty-print the AST as human-readable pseudo-code |

### Run the executable

```bash
dune exec modules/module2-ast/exercises/ast-structure-mapping/starter/ast_visualizer.exe
```

There are **no automated tests** for this exercise. Verify your output visually
against the comments in the starter file. The executable runs your three
visualizers on three sample programs (`simple_arithmetic`, `branching`,
`loop_example`).

### Hints

- **`dump_ast`**: Use the `indent depth` helper to build the padding string.
  For compound nodes like `BinOp`, print the parent at the current depth, then
  recursively print children at `depth + 1`.
- **`count_node_types`**: Thread an accumulator `(string * int) list` through
  the recursion. The `inc` helper should increment a key if present, or add
  `(key, 1)` if not.
- **`print_tree`**: This is the most substantial function. Pattern-match on
  each statement variant and format it like readable pseudo-code (see the
  comments in the file for the expected format of each case).

---

## 4. Exercise 2: Traversal Algorithms (27 tests)

**Goal:** Implement three classic tree traversal strategies and two visitor-style
operations on the AST.

**Time:** ~30 minutes

**Files to edit:**
- `exercises/traversal-algorithms/starter/traversals.ml` -- pre-order,
  post-order, and BFS traversals
- `exercises/traversal-algorithms/starter/visitor.ml` -- `count_nodes` and
  `evaluate`

**Dependencies:** `shared_ast`

### The three traversals

Each traversal walks a `stmt list` and collects a string label for every node
visited. Labels look like:

- Statements: `"Assign"`, `"If"`, `"While"`, `"Return"`, `"Print"`, `"Block"`
- Expressions: `"IntLit(3)"`, `"BoolLit(true)"`, `"Var(x)"`, `"BinOp(+)"`,
  `"UnaryOp(-)"`, `"Call(f)"`

```
Example: Assign("x", BinOp(Add, IntLit 1, IntLit 2))

Pre-order:   ["Assign"; "BinOp(+)"; "IntLit(1)"; "IntLit(2)"]
             Visit node FIRST, then children left-to-right.

Post-order:  ["IntLit(1)"; "IntLit(2)"; "BinOp(+)"; "Assign"]
             Visit children FIRST, then the node itself.

BFS:         ["Assign"; "BinOp(+)"; "IntLit(1)"; "IntLit(2)"]
             All nodes at depth d before any at depth d+1.
```

### What to implement

**In `traversals.ml`:**

| # | Function | Hint |
|---|----------|------|
| 1 | `label_of_expr e` | Pattern match on `expr` and return the label string, e.g., `IntLit n` returns `"IntLit(" ^ string_of_int n ^ ")"` |
| 2 | `label_of_stmt s` | Pattern match on `stmt` and return just the constructor name, e.g., `Assign _` returns `"Assign"` |
| 3 | `pre_order stmts` | Emit current node label, then recurse into children. Use mutual recursion with helpers for `expr` and `stmt` |
| 4 | `post_order stmts` | Recurse into children first, then emit the current node label |
| 5 | `bfs stmts` | Use the OCaml `Queue` module. You need a sum type to handle both `stmt` and `expr` nodes in the same queue |

**In `visitor.ml`:**

| # | Function | Hint |
|---|----------|------|
| 6 | `count_nodes stmts` | Walk the AST and count each constructor name (without parameters). Return an association list like `[("Assign", 2); ("BinOp", 3); ...]` |
| 7 | `evaluate e` | Evaluate constant integer expressions. Return `Some int` for pure arithmetic, `None` if variables/booleans/calls/comparisons appear. Division by zero returns `None` |

### Run tests

```bash
dune runtest modules/module2-ast/exercises/traversal-algorithms/
```

**Starter output:** `EEEEEEEEEEEEEEEEEEEEEEEEEEE` (27 errors -- all TODOs)

### Hints

- **Pre-order/Post-order**: Write mutually recursive helpers
  `pre_order_expr`, `pre_order_stmt`, `pre_order_stmts` (and likewise for
  post-order). For pre-order, cons the label before the recursive results; for
  post-order, append the label after.
- **BFS**: Define a sum type like `type node = Stmt_node of stmt | Expr_node of expr`.
  Seed the queue with all top-level statements, then dequeue a node, emit its
  label, and enqueue its children. Repeat until empty.
- **`evaluate`**: Use `Option.bind` to chain recursive calls. If either operand
  of a `BinOp` returns `None`, the whole expression is `None`.

---

## 5. Exercise 3: Symbol Table (6 tests)

**Goal:** Implement a scoped symbol table using a stack of maps. This exercise
is self-contained -- it does not depend on `shared_ast`.

**Time:** ~15 minutes

**Files to edit:**
- `exercises/symbol-table/starter/symbol_table.ml` -- the implementation
- `exercises/symbol-table/starter/symbol_table.mli` -- the interface (provided,
  read-only)

### The data structures

```ocaml
(* Each symbol has a name, type, and mutability flag *)
type symbol_info = {
  sym_name : string;
  sym_type : string;
  mutable_flag : bool;
}

(* The table is a scope stack: a list of maps from names to symbol_info.
   Head = innermost scope, tail = enclosing scopes. *)
type t = symbol_info StringMap.t list
```

### How scoping works

```
Global scope:  { x -> int }
               |
               +-- Inner scope: { x -> float, y -> bool }
                                  ^
                    x is shadowed (float wins over int)
                    y is only visible here

After exit_scope:
Global scope:  { x -> int }
               y is gone, x is int again
```

### What to implement

| # | Function | Hint |
|---|----------|------|
| 1 | `create ()` | Return a list with one empty `StringMap.t`: `[StringMap.empty]` |
| 2 | `define tbl name info` | Add the binding to the head (innermost) map using `StringMap.add` |
| 3 | `lookup tbl name` | Search from innermost scope outward; return the first match. Use `List.find_map` or a recursive scan |
| 4 | `enter_scope tbl` | Push `StringMap.empty` onto the front of the list |
| 5 | `exit_scope tbl` | Pop the head. If only one scope remains (the global scope), return `None`; otherwise return `Some rest` |

### Run tests

```bash
dune runtest modules/module2-ast/exercises/symbol-table/
```

**Starter output:** `EEEEEE` (6 errors -- all TODOs)

### Hints

- The entire implementation is a list of `StringMap.t` values. `create` returns
  `[StringMap.empty]`, `enter_scope` conses another empty map, and `exit_scope`
  returns the tail.
- For `lookup`, iterate through the list of scopes and check
  `StringMap.find_opt name scope` in each. The first `Some` you find is the
  answer (innermost scope wins).
- `exit_scope` should refuse to pop the last remaining scope (the global scope).

---

## 6. Exercise 4: AST Transformations (30 tests)

**Goal:** Implement three pure AST-to-AST transformation passes: constant
folding, variable renaming, and dead-code elimination.

**Time:** ~30 minutes

**File to edit:**
`exercises/ast-transformations/starter/transformations.ml`

**Dependencies:** `shared_ast`

**Also provided:**
`exercises/ast-transformations/starter/build_sample_ast.ml` -- small AST
fragments used by the tests

### What to implement

| # | Function | What it does |
|---|----------|-------------|
| 1 | `constant_fold expr` | Bottom-up: fold sub-expressions first, then if a `BinOp` has two `IntLit` (or `BoolLit`) children, compute the result. Handle arithmetic, comparison, logical, and unary operators |
| 2 | `rename_variable old_name new_name stmts` | Replace every `Var old_name` with `Var new_name` and every `Assign(old_name, ...)` with `Assign(new_name, ...)`. Recurse into all nested structures |
| 3 | `eliminate_dead_code stmts` | Two rules: (a) remove all statements after a `Return` in the same list; (b) replace `If(BoolLit true, then_b, _)` with `Block then_b` and `If(BoolLit false, _, else_b)` with `Block else_b`. Apply recursively into nested blocks |

### Constant folding examples

```
BinOp(Add, IntLit 2, IntLit 3)                     -->  IntLit 5
BinOp(Mul, IntLit 2, BinOp(Add, IntLit 1, IntLit 3))  -->  IntLit 8
BinOp(Add, Var "x", BinOp(Add, IntLit 2, IntLit 3))   -->  BinOp(Add, Var "x", IntLit 5)
BinOp(Lt, IntLit 3, IntLit 5)                      -->  BoolLit true
UnaryOp(Neg, IntLit 5)                              -->  IntLit (-5)
UnaryOp(Not, BoolLit true)                          -->  BoolLit false
```

### Dead-code elimination examples

```
[Return (Some (IntLit 42)); Print [Var "x"]]
  -->  [Return (Some (IntLit 42))]

[If (BoolLit true, [Assign("x", IntLit 1)], [Assign("x", IntLit 2)])]
  -->  [Block [Assign("x", IntLit 1)]]
```

### Run tests

```bash
dune runtest modules/module2-ast/exercises/ast-transformations/
```

**Starter output:** `EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE` (30 errors -- all TODOs,
displayed as 28 due to terminal line truncation)

### Hints

- **Constant folding**: This is a bottom-up transformation. First recursively
  fold both operands, then check whether the result is two literals. Write a
  helper `eval_binop : op -> expr -> expr -> expr` that handles all operator
  cases (`Add`, `Sub`, `Mul`, `Div`, `Lt`, `Gt`, `Eq`, etc.). Return a
  `BoolLit` for comparison/logical operators and an `IntLit` for arithmetic.
  For logical operators (`And`, `Or`), also handle `BoolLit` operands.
- **Variable renaming**: Write a helper `rename_expr` for expressions and
  `rename_stmt` for statements. Pattern match each constructor and rebuild it
  with the renamed parts. Remember to rename both the LHS of `Assign` and `Var`
  nodes inside expressions.
- **Dead-code elimination**: Process the statement list left-to-right. If you
  encounter a `Return`, keep it and discard everything after it. For `If` nodes,
  check the condition -- if it is `BoolLit true` or `BoolLit false`, replace the
  whole `If` with a `Block` of the live branch. Recurse into `If` branches,
  `While` bodies, and `Block` contents.

---

## 7. Lab 2: AST Parser and Analyzer (9 tests)

After completing the exercises, tackle the lab. You will build a parser for a
small language (MiniLang) using Menhir and implement AST analysis functions.

**Location:** `labs/lab2-ast-parser/`

**Read the full spec:** `labs/lab2-ast-parser/README.md`

### What is provided

| File | Status | Description |
|------|--------|-------------|
| `starter/lexer.mll` | Complete | Tokenizes MiniLang source code (do not modify) |
| `starter/ast_parser.ml` | Complete | Wires the lexer and parser together (do not modify) |
| `starter/parser.mly` | **TODO** | Menhir grammar -- implement the `stmt`, `expr`, and `atom` rules |
| `starter/analyzer.ml` | **TODO** | Implement `extract_functions`, `extract_variables`, `extract_calls` |
| `starter/sample_programs/` | Provided | `.mini` source files for testing |

### What to implement

**In `parser.mly` (grammar rules):**

| Rule | Cases to handle |
|------|----------------|
| `stmt` | Assignment (`IDENT = expr ;`), If/else, While, Return (with/without expr), Print |
| `expr` | Binary operations with the precedence declared at the top of the file. Use `atom` for leaf expressions |
| `atom` | Integer/boolean literals, variables, parenthesized expressions, unary `-`/`!`, function calls |

**In `analyzer.ml`:**

| Function | What it does |
|----------|-------------|
| `extract_functions prog` | Return a list of all function names in the program |
| `extract_variables stmts` | Return all variable names from `Assign` LHS (including nested blocks) |
| `extract_calls stmts` | Return all function names from `Call` expressions (including nested blocks) |

### Build and test

```bash
# Build
dune build labs/lab2-ast-parser/

# Run tests (9 student-visible tests)
dune runtest labs/lab2-ast-parser/
```

**Starter output:** `EEEEEEEEE` (9 errors -- all TODOs)

### Tips

- The `program` and `func_def` rules in `parser.mly` are provided as examples.
  Study them to understand the Menhir syntax before writing your own rules.
- Use `%prec UMINUS` and `%prec UNOT` annotations for unary operators to
  resolve precedence.
- The precedence/associativity declarations are already set up at the top of the
  file -- your `expr` rule just needs to list the binary operation patterns.
- Start with `atom` (simplest), then `expr`, then `stmt`.

---

## 8. Troubleshooting

### Build errors

| Error | Fix |
|-------|-----|
| `ocaml: command not found` | Run `eval $(opam env)` or add it to your `~/.bashrc`/`~/.zshrc` |
| `dune: command not found` | `opam install dune && eval $(opam env)` |
| `Error: Unbound module OUnit2` | `opam install ounit2` |
| `Error: Unbound module Shared_ast` | Run `dune build` from the repo root first (not from inside an exercise) |
| `Error: Unbound module Traversal_exercises` | Same -- `dune build` from the repo root |
| Parser warnings from `labs/lab2-ast-parser/` | Expected -- the parser starter has unused tokens until you complete the grammar |

### Test errors

| Symptom | Meaning |
|---------|---------|
| `EEEEEE` | Every test errors -- functions still have `failwith "TODO"` |
| `..EEEE` | First 2 tests pass, rest still TODO |
| `..F.EE` | 3rd test **fails** (wrong answer) -- read the error message for expected vs actual |
| `Fatal error: exception Failure("TODO: ...")` | The first function called is still a TODO -- implement it first |

### Common OCaml mistakes

| Mistake | Fix |
|---------|-----|
| `match` not exhaustive | Add all cases for the AST variants (every `expr` and `stmt` constructor) |
| Wrong traversal order | Double-check: pre-order visits the node *before* children; post-order visits *after* |
| BFS does not differ from pre-order | BFS uses a queue, not a stack. Make sure you enqueue children and dequeue level-by-level |
| `count_nodes` counts are wrong | Make sure you count the node *and* recurse into its children -- do not forget both steps |
| `evaluate` hits `Not_found` | Use `Option.bind` to propagate `None` from sub-expressions instead of unwrapping with `Option.get` |
| `exit_scope` crashes | Return `None` when there is only one scope left, not an exception |
| Renaming misses some occurrences | Check both `Var` references in expressions *and* the LHS of `Assign` statements |
| Dead-code elimination not recursive | Apply the rules inside `If` branches, `While` bodies, and `Block` contents, not just at the top level |

### Running tests from the right directory

Always run `dune` commands from the **repository root**, not from inside an
exercise directory:

```bash
# CORRECT -- from repo root:
dune runtest modules/module2-ast/exercises/traversal-algorithms/

# WRONG -- from inside the exercise (will fail to find shared libraries):
cd modules/module2-ast/exercises/traversal-algorithms/
dune runtest   # ERROR: can't find shared_ast
```

---

## 9. Exercise Progression Cheat Sheet

```
Exercise 1: AST Structure Mapping      <-- warm-up: visualize ASTs, no tests
     |
Exercise 2: Traversal Algorithms       <-- walk the tree three ways + visitor pattern
     |
Exercise 3: Symbol Table               <-- scoped lookups with a stack of maps
     |
Exercise 4: AST Transformations        <-- rewrite the tree: fold, rename, eliminate dead code
     |
Lab 2: AST Parser and Analyzer         <-- parse source code into an AST with Menhir
```

| Exercise | Tests | Key concepts |
|----------|-------|-------------|
| 1. AST Structure Mapping | 0 (run executable) | AST construction, indentation, pretty-printing |
| 2. Traversal Algorithms | 27 | Pre-order, post-order, BFS, visitor pattern, expression evaluation |
| 3. Symbol Table | 6 | Scope stacks, lexical scoping, shadowing |
| 4. AST Transformations | 30 | Constant folding, variable renaming, dead-code elimination |
| **Exercise total** | **63** | |
| Lab 2: AST Parser | 9 | Menhir grammars, lexing, parsing, AST analysis |
| **Grand total** | **72** | |

Good luck!
