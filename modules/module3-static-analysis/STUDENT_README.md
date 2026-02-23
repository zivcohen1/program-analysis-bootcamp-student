# Module 3: Static Analysis Fundamentals -- Student Guide

Welcome to Module 3! You will build control flow graphs, implement a generic
dataflow framework with powerset lattices and fixpoint iteration, then apply
it to two classic analyses (reaching definitions and live variables), and
finally construct call graphs for interprocedural analysis -- all in OCaml.

```
Source Code  ->  AST  ->  CFG Construction  ->  Dataflow Analysis  ->  Results
                               |                       |
                  +------------+            +----------+-----------+
                  |                         |          |           |
             Basic Blocks              Lattice    Transfer Fn   Fixpoint
             + Edges                  (powerset)  (gen/kill)    Iteration
                                                                   |
                                                    +--------------+--------------+
                                                    |                             |
                                            Forward (may)                 Backward (may)
                                          Reaching Definitions           Live Variables
                                           "which defs reach             "which vars are
                                            this point?"                  used later?"
```

**Exercises:** 5 (72 tests) | **Lab:** Lab 3 -- Static Checker (5 tests)
**Estimated time:** 2--3 hours for exercises, 2--3 hours for the lab

---

## Table of Contents

1. [How Exercises Work](#1-how-exercises-work)
2. [Background: Key Concepts](#2-background-key-concepts)
3. [Exercise 1: CFG Construction (14 tests)](#3-exercise-1-cfg-construction-14-tests)
4. [Exercise 2: Dataflow Framework (11 tests)](#4-exercise-2-dataflow-framework-11-tests)
5. [Exercise 3: Reaching Definitions (15 tests)](#5-exercise-3-reaching-definitions-15-tests)
6. [Exercise 4: Live Variables (14 tests)](#6-exercise-4-live-variables-14-tests)
7. [Exercise 5: Interprocedural Analysis (18 tests)](#7-exercise-5-interprocedural-analysis-18-tests)
8. [Lab 3: Static Checker (5 tests)](#8-lab-3-static-checker-5-tests)
9. [Troubleshooting](#9-troubleshooting)
10. [Exercise Progression Cheat Sheet](#10-exercise-progression-cheat-sheet)

---

## 1. How Exercises Work

Each exercise has this structure:

```
exercises/cfg-construction/
├── dune                          <- tells dune which dirs to build
├── starter/
│   ├── dune                      <- library definition
│   ├── cfg.ml                    <- YOUR FILE -- edit this
│   ├── cfg.mli                   <- interface (read-only)
│   └── exercises.ml              <- YOUR FILE -- edit this
└── tests/
    ├── dune                      <- test configuration
    └── test_cfg.ml               <- read-only test file
```

**The workflow:**

1. **Read the starter file** -- types and docstrings are provided; every function
   body is `failwith "TODO: ..."` with a comment explaining what to implement.

2. **Implement one function at a time** -- replace the `failwith` with real code.

3. **Run tests** -- see your progress:
   ```bash
   dune runtest modules/module3-static-analysis/exercises/cfg-construction/
   ```

4. **Interpret the output:**

   **Early on** (many TODOs remaining), you may see:
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

5. **Repeat** until all tests pass: `..............` (all dots!)

**Tips:**
- Implement functions **in the order they appear** in the file -- later functions
  often depend on earlier ones.
- Read the test file (`tests/test_*.ml`) to understand exactly what is expected.
- Tests are read-only -- do not modify them.
- For OCaml/dune environment setup, see the setup instructions in the Module 4
  student guide or the project-level README.

---

## 2. Background: Key Concepts

Before starting the exercises, review these ideas from the slides
(`slides/static-analysis.md`).

### Control Flow Graphs (CFGs)

A CFG represents a program as a directed graph. Each node is a **basic block**
(a maximal sequence of statements with one entry and one exit). Each edge
represents possible control flow between blocks.

```
    ENTRY              Every CFG has two distinguished blocks:
      |                  ENTRY -- where execution begins
      v                  EXIT  -- where execution ends
     B1
    / \               Basic blocks contain statements.
   v   v              Edges encode branches, loops, and
  B2   B3             fall-through control flow.
   \  /
    v
  B_join
    |
    v
   EXIT
```

### Lattices

A **lattice** provides the mathematical structure for dataflow facts:

- **bottom** -- the least element (no information / unreachable)
- **top** -- the greatest element (all information / unknown)
- **join** (least upper bound) -- combines information from merging paths
- **meet** (greatest lower bound) -- intersects information

For this module, you will work with **powerset lattices** where values are
sets of strings and join = union, meet = intersection.

### Transfer Functions

A transfer function models how a single basic block transforms dataflow facts.

```
Forward analysis:   OUT[B] = transfer(IN[B])
                    e.g., OUT[B] = gen[B] U (IN[B] - kill[B])

Backward analysis:  IN[B] = transfer(OUT[B])
                    e.g., IN[B] = use[B] U (OUT[B] - def[B])
```

### Fixpoint Iteration

The iterative algorithm repeats until no values change:

```
1. Initialize all IN[B] and OUT[B] to the initial value (e.g., empty set)
2. Repeat:
     For each block B:
       - Merge values from predecessor/successor blocks
       - Apply the transfer function
3. Stop when nothing changes (fixpoint reached)
```

Guaranteed to terminate when the lattice has finite height and the transfer
functions are monotone.

### Forward vs. Backward Analysis

```
+-------------------+----------------------+----------------------+
|                   | Forward              | Backward             |
+-------------------+----------------------+----------------------+
| Direction         | ENTRY -> EXIT        | EXIT -> ENTRY        |
| Merge over        | predecessors         | successors           |
| Transfer computes | OUT from IN          | IN from OUT          |
| Example           | Reaching definitions | Live variables       |
| Question answered | "Which defs MIGHT    | "Which vars MIGHT    |
|                   |  reach this point?"  |  be used later?"     |
+-------------------+----------------------+----------------------+
```

### The AST types

Programs are represented as `Shared_ast.Ast_types` (defined in
`lib/shared_ast/ast_types.ml`):

```ocaml
type expr =
  | IntLit of int              (* 42 *)
  | BoolLit of bool            (* true *)
  | Var of string              (* x *)
  | BinOp of op * expr * expr  (* x + y *)
  | UnaryOp of uop * expr      (* -x *)
  | Call of string * expr list (* f(x, y) *)

type stmt =
  | Assign of string * expr           (* x = e *)
  | If of expr * stmt list * stmt list (* if e { ... } else { ... } *)
  | While of expr * stmt list         (* while e { ... } *)
  | Return of expr option             (* return e *)
  | Print of expr list                (* print(e1, e2) *)
  | Block of stmt list                (* { s1; s2; ... } *)

type func_def = { name: string; params: string list; body: stmt list }
type program = func_def list
```

---

## 3. Exercise 1: CFG Construction (14 tests)

**Goal:** Build control flow graphs from AST statement lists. Implement the
core CFG operations (add edges, query predecessors/successors) and three CFG
construction patterns (sequential, if-else diamond, while loop with back edge).

**Time:** ~30 minutes

**Files to edit:**
- `exercises/cfg-construction/starter/cfg.ml` -- core CFG operations
- `exercises/cfg-construction/starter/exercises.ml` -- CFG construction patterns

**Also provided (read-only):**
- `exercises/cfg-construction/starter/cfg.mli` -- interface specification

### CFG patterns you will build

```
Sequential:          If-Else (Diamond):        While (Back Edge):

 ENTRY                  ENTRY                    ENTRY
   |                      |                        |
   v                      v                        v
  B1                   B_cond                    B_pre
   |                   /    \                      |
   v                  v      v                     v
  EXIT             B_then  B_else              B_cond  <---+
                      \    /                   /    \      |
                       v  v                 B_body   \     |
                      B_join                  |       \    |
                        |                     +--------+   |
                        v                              |
                       EXIT                          B_post
                                                       |
                                                       v
                                                      EXIT
```

### What to implement (in order)

**In `cfg.ml`:**

| # | Function | Hint |
|---|----------|------|
| 1 | `add_edge cfg src dst` | Find both blocks in `cfg.blocks`, append `dst` to src's succs and `src` to dst's preds, update the map with `StringMap.add` |
| 2 | `predecessors cfg label` | `StringMap.find` the block, return its `preds` |
| 3 | `successors cfg label` | `StringMap.find` the block, return its `succs` |
| 4 | `to_string cfg` | `StringMap.fold` over blocks; for each, print label, stmt count, succs, preds |

**In `exercises.ml`:**

| # | Function | Hint |
|---|----------|------|
| 5 | `build_cfg_sequential stmts` | Create ENTRY, B1 (all stmts), EXIT blocks; add edges ENTRY->B1->EXIT |
| 6 | `build_cfg_ifelse stmts` | Partition around the `If` node; create B_cond, B_then, B_else, B_join; wire the diamond |
| 7 | `build_cfg_while stmts` | Partition around the `While` node; create B_pre, B_cond, B_body, B_post; wire the back edge B_body->B_cond |

### Run tests

```bash
dune runtest modules/module3-static-analysis/exercises/cfg-construction/
```

**Starter output:** `.EEEEE.EEEEEEE`

Some tests already pass (the dots) because the provided `create_block` helper
function works out of the box -- its tests do not depend on your TODO stubs.
The `E` results are the tests that call your unimplemented functions. As you
implement `add_edge`, `predecessors`, `successors`, and `to_string`, the
middle tests will turn to dots. Then tackle `exercises.ml` for the remaining
tests.

**Hint for build_cfg_ifelse:** You need to split the statement list into three
parts: statements before the `If`, the `If` itself (from which you extract
`then_stmts` and `else_stmts`), and statements after the `If`. A recursive
helper or `List.fold_left` works well for this partitioning.

**Hint for build_cfg_while:** Same partitioning idea, but around the `While`
node. Remember that `B_cond` is empty (the condition is implicit in the
branching edges), and the key addition is the **back edge** from `B_body` to
`B_cond`.

---

## 4. Exercise 2: Dataflow Framework (11 tests)

**Goal:** Implement a powerset lattice (sets of strings) and a generic
iterative fixpoint solver that works for both forward and backward analyses.

**Time:** ~30 minutes

**Files to edit:**
- `exercises/dataflow-framework/starter/lattice.ml` -- powerset lattice operations
- `exercises/dataflow-framework/starter/dataflow.ml` -- iterative fixpoint solver

### The powerset lattice

```
     {a, b, c}        <- top (the full universe)
      / | \
  {a,b} {a,c} {b,c}
    / \  / \  / \
   {a} {b}  {c}
     \  |  /
       {}              <- bottom (empty set)
```

### What to implement (in order)

**In `lattice.ml`:**

| # | Function | Hint |
|---|----------|------|
| 1 | `bottom` | The empty set: `StringSet.empty` |
| 2 | `top` | The universe: `!universe` (dereference the ref) |
| 3 | `join a b` | Set union: `StringSet.union` |
| 4 | `meet a b` | Set intersection: `StringSet.inter` |
| 5 | `equal a b` | Set equality: `StringSet.equal` |
| 6 | `to_string s` | Format as `{a, b, c}` -- use `StringSet.elements` and `String.concat` |

**In `dataflow.ml`:**

| # | Function | Hint |
|---|----------|------|
| 7 | `solve analysis cfg` | Implement the iterative worklist algorithm (see below) |

### The fixpoint algorithm

```
Forward case:
  1. Initialize IN[B] = OUT[B] = analysis.init for every block B
  2. Repeat until nothing changes:
       For each block B:
         IN[B]  = merge over all predecessors P: OUT[P]
         OUT[B] = transfer(B, IN[B])
  3. Return (label, IN[B], OUT[B]) for each block

Backward case:
  Swap the roles of IN/OUT and predecessors/successors:
    OUT[B] = merge over all successors S: IN[S]
    IN[B]  = transfer(B, OUT[B])
```

**Hint:** Use `StringMap` to store the IN and OUT values for each block. In
each iteration, check whether any value changed using `analysis.equal`. When
nothing changes, you have reached the fixpoint.

### Run tests

```bash
dune runtest modules/module3-static-analysis/exercises/dataflow-framework/
```

**Starter output:**

```
Fatal error: exception Failure("TODO: return the least element of the powerset lattice")
```

This fatal error occurs because the `bottom` value is evaluated at module load
time. The test runner crashes immediately before it can show per-test results.
Once you implement `bottom` (and the other lattice functions), you will start
seeing per-test output like `........EEE` as the solver tests remain TODO.

---

## 5. Exercise 3: Reaching Definitions (15 tests)

**Goal:** Implement a forward may-analysis that tracks which variable
definitions can reach each program point.

**Time:** ~25 minutes

**Files to edit:**
- `exercises/reaching-definitions/starter/reaching_definitions.ml` -- gen/kill sets + fixpoint

**Also provided (read-only):**
- `exercises/reaching-definitions/starter/example_program.ml` -- the test program
- `exercises/reaching-definitions/starter/worksheet.md` -- guided walkthrough

### The example program

```
    B1: a = 1  (d1)           CFG:   B1
        b = 2  (d2)                 / \
                                   v   v
    B2: a = 3  (d3)              B2    B3
        c = a  (d4)               \   /
                                   v v
    B3: b = 4  (d5)               B4
        c = b  (d6)

    B4: print(a, b, c)
```

### Transfer function

```
OUT[B] = gen[B] U (IN[B] - kill[B])
IN[B]  = U{ OUT[P] | P is a predecessor of B }
```

- **gen[B]**: definitions created in block B (last def of each variable in B)
- **kill[B]**: definitions killed by B (other defs of variables that B defines)

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `compute_gen defs block` | Filter `defs` by block, keep only the last definition per variable, return their `def_id`s as a `StringSet` |
| 2 | `compute_kill defs block` | For each variable defined in this block, find all OTHER definitions of that variable from any block; exclude gen[B] |
| 3 | `analyze cfg defs` | Iterative fixpoint: initialize OUT[B] = {} for all B, repeat merge + transfer until stable |

### Run tests

```bash
dune runtest modules/module3-static-analysis/exercises/reaching-definitions/
```

**Starter output:** `EEEEEEEEEEEEEEE`

All 15 tests error because every function is still a TODO stub. The tests are
organized in groups: 4 gen tests, 4 kill tests, 7 analyze tests. Implement
`compute_gen` first to get the first 4 passing, then `compute_kill`, then
`analyze`.

**Hint for compute_gen:** Filter `defs` to those in the given block. If a
variable has multiple definitions in the same block, only the last one counts.
Use `List.filter` and `List.rev` or fold from right to left.

**Hint for analyze:** The CFG is given as `(label, predecessor_labels)` pairs
(not full block objects). Use `StringMap` to store the OUT set for each block
and iterate until no OUT set changes.

---

## 6. Exercise 4: Live Variables (14 tests)

**Goal:** Implement a backward may-analysis that tracks which variables may be
used in the future (are "live") at each program point.

**Time:** ~25 minutes

**Files to edit:**
- `exercises/live-variables/starter/live_variables.ml` -- use/def extraction + fixpoint

**Also provided (read-only):**
- `exercises/live-variables/starter/comparison.ml` -- side-by-side comparison of
  reaching defs vs. live variables (reference reading)

### The example program

```
         B1: def={a,b}, use={}
        /  \
       v    v
      B2    B3
 def={a,c}  def={b,c}
 use={a}    use={b}
       \   /
        v v
         B4: def={}, use={a,b,c}
```

### Transfer function (backward!)

```
IN[B]  = use[B] U (OUT[B] - def[B])
OUT[B] = U{ IN[S] | S is a successor of B }
```

- **use[B]**: variables read in B before being (re)defined
- **def[B]**: variables assigned/written in B

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `compute_use (label, defs, uses)` | Return `StringSet.of_list uses` |
| 2 | `compute_def (label, defs, uses)` | Return `StringSet.of_list defs` |
| 3 | `analyze blocks` | Backward iterative fixpoint: initialize IN[B] = {} for all B, merge over successors to get OUT, apply transfer to get IN, repeat until stable |

### Run tests

```bash
dune runtest modules/module3-static-analysis/exercises/live-variables/
```

**Starter output:** `EEEEEEEEEEEEEE`

All 14 tests error because every function is a TODO. The tests include 3
compute_use tests, 2 compute_def tests, 6 diamond-CFG analysis tests, and 3
loop analysis tests. Start with `compute_use` and `compute_def` (straightforward
one-liners), then tackle `analyze`.

**Key difference from Exercise 3:** This is a **backward** analysis. You merge
over **successors** (not predecessors) to compute OUT, then apply the transfer
function to compute IN. The fixpoint check is on IN values (not OUT).

**Hint for analyze:** The blocks are given as
`(label, defined_vars, used_vars, successor_labels)` tuples. Build a
`StringMap` keyed by label. In each iteration, compute `OUT[B]` by unioning
the `IN` values of B's successors, then compute `IN[B]` via the transfer
function. Iterate until no `IN` set changes.

---

## 7. Exercise 5: Interprocedural Analysis (18 tests)

**Goal:** Build a call graph from a multi-function program and use it to answer
questions about function reachability and recursion detection.

**Time:** ~30 minutes

**Files to edit:**
- `exercises/interprocedural-analysis/starter/call_graph.ml` -- call graph construction + queries

**Also provided (read-only):**
- `exercises/interprocedural-analysis/starter/example_program.ml` -- the test program
- `exercises/interprocedural-analysis/starter/context_analysis.md` -- background reading

### The example program

```
def helper(param):               Call graph:
    return param + 1
                                    main
def process_data(x, y):              |
    temp = x * 2                     v
    result1 = helper(temp)       process_data
    result2 = helper(y)              |
    return result1 + result2         v
                                   helper
def main():
    a = 5
    b = 10
    output = process_data(a, b)
    print(output)
```

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `calls_in_expr expr` | Recursively walk the expression tree; collect function names from `Call(name, args)` nodes; do not forget to recurse into args |
| 2 | `calls_in_stmts stmts` | Walk each statement; recurse into `Assign`, `If` (cond + both branches), `While` (cond + body), `Return`, `Print`, `Block`. Use `let rec ... and ...` for mutual recursion |
| 3 | `build_call_graph program` | For each `func_def`, add its name to `nodes` and record `calls_in_stmts func.body` as its edge set in a `StringMap` |
| 4 | `reachable_from cg start` | BFS or DFS from `start` following call graph edges; return all reachable functions (not including `start` unless it is in a cycle) |
| 5 | `find_recursive cg` | A function `f` is recursive if `f` is in `reachable_from cg f`. Check every node and return a sorted list |

### Run tests

```bash
dune runtest modules/module3-static-analysis/exercises/interprocedural-analysis/
```

**Starter output:**

```
Fatal error: exception Failure("TODO: Build call graph from a program")
```

This fatal error occurs because the test file builds a call graph at the top
level (module load time) using `build_call_graph`. Since that function is
still a TODO, the test runner crashes immediately before showing per-test
results. You need to implement `calls_in_expr`, `calls_in_stmts`, and
`build_call_graph` first. Once those three are done, the test runner will
be able to start and you will see per-test output for the remaining functions.

**Hint for calls_in_expr:** You need `let rec` because `Call` arguments are
themselves expressions that may contain nested calls. Pattern match on each
expression variant:
- `IntLit`, `BoolLit`, `Var` -- return `[]`
- `Call(name, args)` -- `name :: List.concat_map calls_in_expr args`
- `BinOp(_, e1, e2)` -- recurse into both sub-expressions
- `UnaryOp(_, e)` -- recurse into the sub-expression

**Hint for reachable_from:** Use a `StringSet` as a "visited" set. Start with
the callees of `start`, add them to the visited set, and continue BFS/DFS
until the frontier is empty. Do not add `start` to the initial visited set --
it should only appear in the result if a cycle leads back to it.

---

## 8. Lab 3: Static Checker (5 tests)

After completing the exercises, tackle Lab 3. You will build a static analysis
checker that detects common code quality issues by walking the AST.

**Location:** `labs/lab3-static-checker/`

**Read the full spec:** `labs/lab3-static-checker/README.md`

### Files to edit

| File | What you implement |
|------|--------------------|
| `starter/rules.ml` | Three analysis rules: `check_unused_variables`, `check_unreachable_code`, `check_shadowed_variables` |
| `starter/checker.ml` | `check_program` -- aggregator that runs all rules on every function and collects issues |

### Already provided (read-only)

| File | Contents |
|------|----------|
| `starter/reporter.ml` | Issue type, severity, formatting, print_report |
| `starter/tests/test_checker.ml` | 5 test cases |

### The three rules

| Rule | What it detects | Approach |
|------|-----------------|----------|
| `check_unused_variables` | Variables assigned but never read | Walk stmts to collect assigned vars, walk exprs to collect used vars, report the difference |
| `check_unreachable_code` | Statements after a `Return` in the same list | Scan each statement list; once a `Return` is found, all subsequent statements are unreachable |
| `check_shadowed_variables` | Inner-scope assignment shadows outer-scope variable | Track defined vars at each scope level; when entering `If`/`While` bodies, check for re-assignment of outer vars |

### Build and test

```bash
# Build
dune build labs/lab3-static-checker/

# Run tests
dune runtest labs/lab3-static-checker/
```

**Starter output:** `EEEEE`

All 5 tests error because every function is a TODO. The tests check: unused
variables (1), unreachable code (1), shadowed variables (1), clean program
produces no issues (1), and aggregation across multiple rules (1).

### Tips

- Start with `check_unused_variables` -- it is the most straightforward rule.
- For `check_unreachable_code`, remember to recurse into nested `If`/`While`
  bodies to find unreachable code inside them.
- `check_program` should iterate over every `func_def` in the program and
  apply all three rules, concatenating the resulting issue lists.
- Look at `reporter.ml` to see the `issue` record type. Each rule returns a
  list of `Reporter.issue` values with appropriate `rule`, `message`,
  `severity`, and `location` fields.

---

## 9. Troubleshooting

### Build errors

| Error | Fix |
|-------|-----|
| `ocaml: command not found` | Run `eval $(opam env)` or add it to your `~/.bashrc`/`~/.zshrc` |
| `dune: command not found` | `opam install dune && eval $(opam env)` |
| `Error: Unbound module OUnit2` | `opam install ounit2` |
| `Error: Unbound module Shared_ast` | Run `dune build` from the repo root first (not from inside an exercise) |

### Test errors

| Symptom | Meaning |
|---------|---------|
| `Fatal error: exception Failure("TODO: ...")` | The first function called is still a TODO -- implement it first |
| `EEEEEEEEEE` | Every test errors -- functions still have `failwith "TODO"` |
| `.EEEEE.EEEEEEE` | Some tests pass (provided helpers work), rest are TODOs |
| `..EEEE` | First 2 tests pass, rest still TODO |
| `..F.EE` | 3rd test **fails** (wrong answer) -- read error message for expected vs actual |

### Common OCaml mistakes

| Mistake | Fix |
|---------|-----|
| `match` not exhaustive | Add all cases: `Assign`, `If`, `While`, `Return`, `Print`, `Block` |
| `StringSet` comparison with `=` | Use `StringSet.equal` -- polymorphic `=` compares AVL tree structure, not logical set equality |
| Infinite loop in fixpoint | Make sure your "changed" flag is correctly tracking whether any IN/OUT value actually changed |
| `Unbound module Cfg` | Your `exercises.ml` should `open` or qualify with `Cfg.` -- the library wraps modules |
| `Stack overflow` in reachable_from | Track visited nodes to avoid infinite recursion through cycles |
| `type t is abstract` | Use the module prefix: `Cfg.StringMap.find`, `StringSet.union`, etc. |

### Running tests from the right directory

Always run `dune` commands from the **repository root**, not from inside an
exercise directory:

```bash
# CORRECT -- from repo root:
dune runtest modules/module3-static-analysis/exercises/cfg-construction/

# WRONG -- from inside the exercise (will fail to find shared libraries):
cd modules/module3-static-analysis/exercises/cfg-construction/
dune runtest   # ERROR: can't find shared_ast
```

---

## 10. Exercise Progression Cheat Sheet

```
Exercise 1: CFG Construction          <- build the graph structure that all analyses use
     |
Exercise 2: Dataflow Framework        <- generic lattice + fixpoint solver
     |
Exercise 3: Reaching Definitions      <- forward may-analysis (gen/kill sets)
     |
Exercise 4: Live Variables            <- backward may-analysis (use/def sets)
     |
Exercise 5: Interprocedural Analysis  <- call graphs, reachability, recursion detection
     |
Lab 3: Static Checker                 <- apply AST walking to detect real code quality issues
```

**Recommended order:** Exercises 1 through 5 are designed to be done in
sequence. Each builds on concepts from the previous one:

- Exercise 1 teaches CFG structure (nodes, edges, blocks)
- Exercise 2 gives you the lattice and solver machinery
- Exercise 3 applies the framework as a forward analysis
- Exercise 4 applies the framework as a backward analysis (the dual)
- Exercise 5 extends analysis to multiple functions (interprocedural)

**Full path:** All 5 exercises + Lab 3 (72 exercise tests + 5 lab tests = 77 total)

Good luck!
