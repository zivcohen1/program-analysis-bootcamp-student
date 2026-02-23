# Module 5: Security Analysis -- Student Guide

Welcome to Module 5! You'll apply abstract interpretation to security by building
a taint analysis pipeline -- from lattice foundations through vulnerability
detection of real OWASP patterns like SQL injection, XSS, and command injection.

```
                    TAINT ANALYSIS PIPELINE

 User Input          Taint            Security          Vulnerability
 (Sources)       Propagation           Sinks              Report
    |                 |                  |                   |
    v                 v                  v                   v
+----------+    +-----------+    +-------------+    +---------------+
| get_param| -> | x = input | -> | exec_query  | -> | [CRITICAL]    |
| read_    |    | y = x + 1 |    | send_resp   |    | SQL injection |
|   cookie |    | z = san(y)|    | exec_cmd    |    | in handler()  |
| read_    |    |           |    | open_file   |    |               |
|   input  |    | Forward   |    | redirect    |    | source: input |
+----------+    | dataflow  |    +------+------+    | sink: exec_   |
                +-----------+           |           |   query       |
                     ^                  |           +---------------+
                     |           Tainted data
               Sanitizers        reaches sink?
               clean taint        YES = vuln!
               (escape_sql,
                html_encode)
```

**Exercises:** 5 (95 tests) | **Lab:** Lab 5 -- Security Analyzer (10 tests)
**Estimated time:** 2--3 hours for exercises, 2--4 hours for the lab
**Slides:** `slides/security-analysis.html` (self-contained HTML)

---

## Table of Contents

1. [How Exercises Work](#1-how-exercises-work)
2. [Background: Key Concepts](#2-background-key-concepts)
3. [Exercise 1: Taint Lattice (18 tests)](#3-exercise-1-taint-lattice-18-tests)
4. [Exercise 2: Security Config (17 tests)](#4-exercise-2-security-config-17-tests)
5. [Exercise 3: Taint Propagation (22 tests)](#5-exercise-3-taint-propagation-22-tests)
6. [Exercise 4: Information Flow (20 tests)](#6-exercise-4-information-flow-20-tests)
7. [Exercise 5: Vulnerability Detection (18 tests)](#7-exercise-5-vulnerability-detection-18-tests)
8. [Lab 5: Security Analyzer (10 tests)](#8-lab-5-security-analyzer-10-tests)
9. [Troubleshooting](#9-troubleshooting)
10. [Exercise Progression Cheat Sheet](#10-exercise-progression-cheat-sheet)

---

## 1. How Exercises Work

Each exercise has this structure:

```
exercises/taint-lattice/
+-- dune                          <-- tells dune which dirs to build
+-- starter/
|   +-- dune                      <-- library definition
|   +-- taint_domain.ml           <-- YOUR FILE -- edit this
+-- tests/
    +-- dune                      <-- test configuration
    +-- test_taint_lattice.ml     <-- read-only test file
```

**The workflow:**

1. **Read the starter file** -- types and docstrings are provided; every function
   body is `failwith "TODO: ..."` with a comment explaining what to implement.

2. **Implement one function at a time** -- replace the `failwith` with real code.

3. **Run tests** -- see your progress:
   ```bash
   dune runtest modules/module5-security-analysis/exercises/taint-lattice/
   ```

4. **Interpret the output:**

   **Early on** (many TODOs remaining), you'll often see:
   ```
   Fatal error: exception Failure("TODO: ...")
   ```
   This means the tests hit a `failwith "TODO"` stub and crashed before they
   could run individually. Keep implementing functions from the top of the file.

   **Once enough functions are implemented**, you'll see per-test results:
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
- Read the test file (`tests/test_*.ml`) to understand exactly what's expected.
- Tests are read-only -- don't modify them.
- **Exercises 3-5 include a provided `taint_domain.ml`** that is already
  implemented for you (not a TODO). Only the main file in each exercise needs
  your work.

---

## 2. Background: Key Concepts

Before starting the exercises, make sure you understand these ideas from the
slides.

### The taint lattice

Taint analysis tracks whether data may carry untrusted user input. The lattice
has four elements:

```
        Top              "may be tainted or untainted -- no info"
       / \
  Tainted  Untainted     "definitely tainted / definitely clean"
       \ /
        Bot              "unreachable"
```

Key properties:
- `Bot` is below everything (identity for join)
- `Top` is above everything (identity for meet)
- `Tainted` and `Untainted` are **incomparable** -- their join is `Top`, their
  meet is `Bot`
- This is a finite lattice, so **widen = join** (no infinite chains)

### Sources, sinks, and sanitizers

```
SOURCES (introduce taint)        SINKS (must be clean)         SANITIZERS (clean taint)
+-----------------------+        +---------------------+       +---------------------+
| get_param             |        | exec_query (SQLi)   |       | escape_sql          |
| read_cookie           |  --->  | send_response (XSS) |  <--  | html_encode         |
| read_input            |  data  | exec_cmd (CMDi)     |  data | shell_escape        |
| read_file             |  flow  | open_file (path)    |  flow | validate_path       |
| get_header            |        | redirect (redirect) |       | validate_url        |
+-----------------------+        +---------------------+       +---------------------+
```

- **Sources** return user-controlled data -- the result is `Tainted`
- **Sinks** are security-sensitive functions -- if tainted data reaches a sink
  without sanitization, it is a vulnerability
- **Sanitizers** clean tainted data -- the result is `Untainted`

### OWASP vulnerability patterns

| Vulnerability | Source | Sink | Sanitizer |
|---------------|--------|------|-----------|
| SQL Injection | `get_param` | `exec_query` | `escape_sql` |
| XSS (Cross-Site Scripting) | `get_param` | `send_response` | `html_encode` |
| Command Injection | `get_param` | `exec_cmd` | `shell_escape` |
| Path Traversal | `get_param` | `open_file` | `validate_path` |
| Open Redirect | `get_param` | `redirect` | `validate_url` |

### Explicit vs. implicit information flow

**Explicit flow:** Data moves directly via assignment.
```
secret = get_param(0)    -- secret is Tainted
x = secret               -- x is Tainted (direct data flow)
```

**Implicit flow:** Information leaks through control flow.
```
secret = get_param(0)    -- secret is Tainted
if secret:               -- branch depends on tainted data
    x = 1                -- x reveals info about secret!
else:
    x = 0                -- x reveals info about secret!
```
Even though `x` is assigned a literal, its value depends on `secret`. The
**pc_taint** (program counter taint) tracks this: when execution enters a
branch guarded by tainted data, all assignments inside are considered tainted.

### The `ABSTRACT_DOMAIN` signature

Every domain must satisfy this interface (defined in
`lib/abstract_domains/abstract_domain.ml`):

```ocaml
module type ABSTRACT_DOMAIN = sig
  type t
  val bottom : t                  (* least element: unreachable *)
  val top : t                     (* greatest element: unknown *)
  val join : t -> t -> t          (* least upper bound *)
  val meet : t -> t -> t          (* greatest lower bound *)
  val leq : t -> t -> bool        (* partial order: a <= b *)
  val equal : t -> t -> bool      (* equality *)
  val widen : t -> t -> t         (* widening for termination *)
  val to_string : t -> string     (* pretty-print *)
end
```

### The `MakeEnv` functor

The environment maps variable names to abstract values. It's defined in
`lib/abstract_domains/abstract_env.ml` and used in Exercises 3, 4, 5, and Lab 5:

```ocaml
module MakeEnv (D : ABSTRACT_DOMAIN) : sig
  type t                                  (* string -> D.t map *)
  val bottom : t                          (* empty environment *)
  val lookup : string -> t -> D.t         (* returns D.bottom if missing *)
  val update : string -> D.t -> t -> t    (* set variable *)
  val join : t -> t -> t                  (* pointwise join *)
  val leq : t -> t -> bool               (* pointwise leq *)
  val widen : t -> t -> t                 (* pointwise widen *)
  val to_string : t -> string
end
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

## 3. Exercise 1: Taint Lattice (18 tests)

**Goal:** Implement the 4-element taint lattice and taint-specific operations.

**Time:** ~20 minutes

**File to edit:** `exercises/taint-lattice/starter/taint_domain.ml`

**Dependencies:** `abstract_domains`

### The taint type

The type is pre-defined for you:

```ocaml
type taint = Bot | Untainted | Tainted | Top
```

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `bottom` | Return `Bot` |
| 2 | `top` | Return `Top` |
| 3 | `join a b` | LUB -- if `a = b` return it; `Bot` is identity; `Tainted`/`Untainted` join to `Top` |
| 4 | `meet a b` | GLB -- dual of join; `Top` is identity; `Tainted`/`Untainted` meet to `Bot` |
| 5 | `leq a b` | `Bot <= everything`, `everything <= Top`, otherwise `a = b` |
| 6 | `equal a b` | Structural equality -- just `a = b` in OCaml |
| 7 | `widen a b` | Finite lattice, so widen = join |
| 8 | `to_string t` | Return `"Bot"`, `"Untainted"`, `"Tainted"`, or `"Top"` |
| 9 | `is_potentially_tainted t` | `true` if `t` is `Tainted` or `Top` |
| 10 | `propagate a b` | Combine taint from two operands -- `Bot` propagates as `Bot`; if either is `Tainted`, result is `Tainted`; if either is `Top`, result is `Top`; both `Untainted` stays `Untainted` |

### Run tests

```bash
dune runtest modules/module5-security-analysis/exercises/taint-lattice/
```

**Starter output** (before any implementation):

```
Fatal error: exception Failure("TODO: return the bottom element")
```

The first test calls `bottom`, which is still a TODO. Once you implement
`bottom` and `top`, the tests will get further. Implement all functions
top-to-bottom to see per-test results.

**Hint for propagate:** Think of propagation as: "if any input is tainted, the
output should be tainted." Handle `Bot` first (anything with `Bot` is `Bot`),
then check for `Tainted`, then `Top`, then the `Untainted`/`Untainted` case.

---

## 4. Exercise 2: Security Config (17 tests)

**Goal:** Define a security configuration with sources, sinks, sanitizers, and
lookup/mutation helpers.

**Time:** ~20 minutes

**File to edit:** `exercises/security-config/starter/config.ml`

**Dependencies:** `shared_ast`

### The configuration types

These record types are pre-defined:

```ocaml
type source = { source_name: string; source_description: string }
type sink = { sink_name: string; sink_param_index: int;
              sink_vuln_type: string; sink_description: string }
type sanitizer = { sanitizer_name: string; sanitizer_cleans: string list;
                   sanitizer_description: string }
type security_config = { sources: source list; sinks: sink list;
                         sanitizers: sanitizer list }
```

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `empty_config` | All three lists empty |
| 2 | `default_web_config` | Build the full config with 5 sources, 5 sinks, 5 sanitizers (see table below) |
| 3 | `is_source config name` | `List.exists` checking `source_name` |
| 4 | `find_sink config name` | `List.find_opt` checking `sink_name` |
| 5 | `find_sanitizer config name` | `List.find_opt` checking `sanitizer_name` |
| 6 | `sink_checks_param sink idx` | Compare `sink.sink_param_index` to `idx` |
| 7 | `sanitizer_cleans san vuln_type` | `List.mem vuln_type san.sanitizer_cleans` |
| 8 | `add_source config source` | Prepend to `config.sources` |
| 9 | `add_sink config sink` | Prepend to `config.sinks` |
| 10 | `add_sanitizer config san` | Prepend to `config.sanitizers` |

### The default web config

| Sources | Sinks (param 0) | Sanitizers |
|---------|------------------|------------|
| `get_param` | `exec_query` (sql-injection) | `escape_sql` (cleans: sql-injection) |
| `read_cookie` | `send_response` (xss) | `html_encode` (cleans: xss) |
| `read_input` | `exec_cmd` (command-injection) | `shell_escape` (cleans: command-injection) |
| `read_file` | `open_file` (path-traversal) | `validate_path` (cleans: path-traversal) |
| `get_header` | `redirect` (open-redirect) | `validate_url` (cleans: open-redirect) |

All sinks check parameter index 0. Each sanitizer cleans exactly one vulnerability type.

### Run tests

```bash
dune runtest modules/module5-security-analysis/exercises/security-config/
```

**Starter output** (before any implementation):

```
Fatal error: exception Failure("TODO: return empty config")
```

The test framework calls `empty_config` first. Once you implement it and
`default_web_config`, the lookup tests will start running. Build up the config
step by step.

**Hint:** The tests check exact string values for `sink_vuln_type` (e.g.
`"sql-injection"`, not `"SQLi"`). Match the strings in the table above exactly.

---

## 5. Exercise 3: Taint Propagation (22 tests)

**Goal:** Build a forward taint propagation engine that evaluates expressions
and transfers statements using an abstract taint environment.

**Time:** ~30 minutes

**File to edit:** `exercises/taint-propagation/starter/taint_propagator.ml`

**Also provided (read-only):**
- `exercises/taint-propagation/starter/taint_domain.ml` -- fully implemented
  taint lattice (same as Exercise 1's solution)
- `exercises/taint-propagation/starter/sample_programs.ml` -- test programs

**Dependencies:** `abstract_domains`, `shared_ast`

### Architecture

```
taint_domain.ml (provided)     taint_propagator.ml (YOUR CODE)
+--------------------------+   +---------------------------------+
| type taint = Bot | ...   |   | module Env = MakeEnv(...)       |
| join, meet, leq, ...    |   |                                 |
| is_potentially_tainted   |   | eval_expr : Env.t -> expr       |
| propagate                |   |           -> taint              |
+--------------------------+   |                                 |
                               | transfer_stmt : Env.t -> stmt   |
hardcoded source/sanitizer     |              -> Env.t           |
lists in taint_propagator.ml   |                                 |
                               | analyze_function : func_def     |
                               |                 -> Env.t        |
                               +---------------------------------+
```

The `Env` module is created for you at the top of the file using
`MakeEnv`. The source and sanitizer lists are hardcoded:
- Sources: `"get_param"`, `"read_cookie"`, `"read_input"`
- Sanitizers: `"escape_sql"`, `"html_encode"`, `"shell_escape"`

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `eval_expr env e` | Pattern match on `e`: `IntLit`/`BoolLit` -> `Untainted`; `Var x` -> `Env.lookup x env`; `BinOp(_, e1, e2)` -> `Taint_domain.propagate` both; `UnaryOp(_, e1)` -> eval and return; `Call(name, _)` -> check source/sanitizer/unknown |
| 2 | `transfer_stmt env s` | `Assign(x, e)` -> `Env.update x (eval_expr env e) env`; `If(_, t, f)` -> transfer both branches, `Env.join`; `While(_, body)` -> fixpoint with widening (max 100 iterations); `Return`/`Print` -> return env; `Block(stmts)` -> fold |
| 3 | `transfer_stmts env stmts` | `List.fold_left transfer_stmt env stmts` |
| 4 | `analyze_function func` | Initialize each param to `Taint_domain.top`, then `transfer_stmts` the body |

### Run tests

```bash
dune runtest modules/module5-security-analysis/exercises/taint-propagation/
```

**Starter output** (before any implementation):

```
EEEEEEEEEEEEEEEEEEEEEE
```

All 22 tests error because `eval_expr` throws an exception. Unlike Exercises 1
and 2, this exercise does not hit a fatal error because the test harness catches
exceptions per-test. You will see `E`s turn to `.`s as you implement functions.

### The while loop fixpoint

```
1. Start with current env
2. Transfer the loop body to get env'
3. Join: env'' = Env.join env env'    (or Env.widen env env')
4. If Env.leq env'' env (stable), stop -- return env''
5. Otherwise, repeat from step 2 with env''
6. Safety: cap at 100 iterations to prevent infinite loops
```

**Hint for eval_expr Call:** For a `Call(name, args)`:
- If `is_source name` -> `Tainted`
- If `is_sanitizer name` -> `Untainted`
- Otherwise -> `Top` (unknown function, conservative)

---

## 6. Exercise 4: Information Flow (20 tests)

**Goal:** Extend taint propagation with **implicit flow tracking** using a
`pc_taint` parameter that records whether execution is inside a branch
controlled by tainted data.

**Time:** ~30 minutes

**File to edit:** `exercises/information-flow/starter/flow_analyzer.ml`

**Also provided (read-only):**
- `exercises/information-flow/starter/taint_domain.ml` -- fully implemented
- `exercises/information-flow/starter/sample_programs.ml` -- test programs

**Dependencies:** `abstract_domains`, `shared_ast`

### Key idea: the `pc_taint` parameter

The critical difference from Exercise 3 is the labeled argument `~pc_taint` on
`transfer_stmt`. When you process an `Assign(x, e)`, the final taint of `x` is:

```ocaml
Taint_domain.propagate (eval_expr env e) pc_taint
```

If `pc_taint` is `Tainted` (we're inside a tainted branch), even assigning a
literal to `x` makes `x` tainted -- that's the implicit flow.

```
                        pc_taint = Untainted (top level)
secret = get_param(0)                     -- secret = Tainted
                        |
                        v
if secret:              pc_taint = propagate(Untainted, eval_expr(secret))
    |                              = propagate(Untainted, Tainted) = Tainted
    v
    x = 1               result = propagate(Untainted, Tainted) = Tainted
else:                                                              ^^^^^^^^
    x = 0               result = propagate(Untainted, Tainted) = Tainted
```

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `eval_expr env e` | Same as Exercise 3 -- no pc_taint needed here |
| 2 | `transfer_stmt ~pc_taint env s` | `Assign(x, e)` -> combine `eval_expr` result with `pc_taint` using `propagate`; `If(cond, t, f)` -> compute branch pc_taint as `propagate(pc_taint, eval_expr cond)`, transfer both branches with new pc_taint, join results; `While` -> same idea, fixpoint with updated pc_taint |
| 3 | `transfer_stmts ~pc_taint env stmts` | Fold `transfer_stmt` with `~pc_taint` |
| 4 | `detect_flows ~pc_taint env func_name stmts` | Walk statements, for each `Assign(x, e)` where the combined taint is potentially tainted, record a flow. Classify as `Implicit` if `pc_taint` is potentially tainted, else `Explicit` |
| 5 | `analyze_function func` | Initialize params to `Top`, transfer body with `~pc_taint:Untainted`, detect flows |

### Run tests

```bash
dune runtest modules/module5-security-analysis/exercises/information-flow/
```

**Starter output** (before any implementation):

```
EEEEEEEEEEEEEEEEEEEE
```

All 20 tests error. Implement `eval_expr` first (same as Exercise 3), then
tackle `transfer_stmt` with the pc_taint logic.

### Hints

- **If with tainted condition:** The new pc_taint for both branches is
  `Taint_domain.propagate pc_taint (eval_expr env cond)`. This means if either
  the current pc_taint OR the condition is tainted, the branch body is under
  tainted control.

- **While with tainted condition:** Same idea -- the loop body's pc_taint
  includes the condition's taint.

- **detect_flows needs to walk the AST recursively.** For `If` and `While`,
  update pc_taint before recursing into the body (same logic as transfer_stmt).

---

## 7. Exercise 5: Vulnerability Detection (18 tests)

**Goal:** Combine taint propagation with a security configuration to detect
OWASP vulnerability patterns -- SQL injection, XSS, command injection, path
traversal, and open redirect.

**Time:** ~30 minutes

**File to edit:** `exercises/vulnerability-detection/starter/vuln_detector.ml`

**Also provided (read-only):**
- `exercises/vulnerability-detection/starter/taint_domain.ml` -- fully implemented
- `exercises/vulnerability-detection/starter/vuln_config.ml` -- security config
  with `default_config`, `is_source`, `find_sink`, `find_sanitizer`
- `exercises/vulnerability-detection/starter/sample_programs.ml` -- test programs

**Dependencies:** `abstract_domains`, `shared_ast`

### Architecture

```
vuln_config.ml (provided)       vuln_detector.ml (YOUR CODE)
+---------------------------+   +------------------------------------+
| default_config            |   | eval_expr : config -> Env.t        |
| is_source, find_sink,     |   |           -> expr -> taint         |
| find_sanitizer            |   |                                    |
+---------------------------+   | check_call : config -> Env.t       |
                                |            -> ... -> vulnerability  |
taint_domain.ml (provided)      |              list                  |
+---------------------------+   |                                    |
| Bot/Untainted/Tainted/Top |   | transfer_and_check : config -> ... |
| join, propagate, ...      |   |   -> Env.t * vulnerability list    |
+---------------------------+   |                                    |
                                | analyze_function, analyze_program  |
sample_programs.ml (provided)   | format_vulnerability               |
+---------------------------+   | severity_of_vuln_type              |
| sql_injection, xss_       |   +------------------------------------+
| reflected, command_        |
| injection, ...            |
+---------------------------+
```

### The vulnerability record

```ocaml
type vulnerability = {
  vuln_type : string;      (* e.g. "sql-injection" *)
  location : string;       (* function name *)
  source_var : string;     (* the tainted variable *)
  sink_name : string;      (* the sink function called *)
  message : string;        (* human-readable description *)
}
```

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `severity_of_vuln_type vt` | `"sql-injection"`, `"command-injection"` -> `Critical`; `"xss"`, `"path-traversal"` -> `High`; `"open-redirect"` -> `Medium`; other -> `Low` |
| 2 | `string_of_severity s` | `Critical` -> `"CRITICAL"`, `High` -> `"HIGH"`, `Medium` -> `"MEDIUM"`, `Low` -> `"LOW"` |
| 3 | `eval_expr config env e` | Like Exercise 3, but use `Vuln_config.is_source config`, `Vuln_config.find_sanitizer config`, etc. instead of hardcoded lists |
| 4 | `check_call config env func_name call_name args` | If `call_name` is a sink, evaluate the argument at `sink_param_index` -- if potentially tainted, create a vulnerability record |
| 5 | `transfer_and_check config func_name env s` | Transfer the statement (updating env) AND check any `Call` expressions for vulnerabilities. Return `(updated_env, vulnerabilities)` |
| 6 | `analyze_function config func` | Initialize params to `Top`, fold `transfer_and_check` over body, collect all vulnerabilities |
| 7 | `analyze_program config prog` | Map `analyze_function` over all functions, concatenate vulnerabilities |
| 8 | `format_vulnerability v` | Must include the severity string (e.g. `"CRITICAL"`) -- the test checks for it |

### Run tests

```bash
dune runtest modules/module5-security-analysis/exercises/vulnerability-detection/
```

**Starter output** (before any implementation):

```
EEEEEEEEEEEEEEEEEE
```

All 18 tests error. Start with the simple helper functions (`severity_of_vuln_type`,
`string_of_severity`), then `eval_expr`, then build up from there.

### Hints

- **check_call:** Use `Vuln_config.find_sink config call_name`. If it returns
  `Some sink`, evaluate the argument at index `sink.sink_param_index`. If the
  taint is potentially tainted (`Taint_domain.is_potentially_tainted`), return a
  vulnerability. If the argument index is out of range or the call is not a sink,
  return `[]`.

- **transfer_and_check:** For an `Assign(x, e)` where `e` is
  `Call(name, args)`, you need to both update the environment AND check the call.
  For `If` and `While`, recurse into branches and collect vulnerabilities from
  both.

- **format_vulnerability:** The test checks that the output `contains_substring`
  `"CRITICAL"` for a sql-injection vulnerability. Make sure `severity_of_vuln_type`
  and `string_of_severity` work correctly first.

---

## 8. Lab 5: Security Analyzer (10 tests)

After completing the exercises, tackle the lab. It integrates everything into
a complete security analyzer with taint propagation, vulnerability checking,
and report formatting.

**Location:** `labs/lab5-security-analyzer/`

**Read the full spec:** `labs/lab5-security-analyzer/README.md`

| Part | Points | Files | What you build |
|------|--------|-------|----------------|
| A | 35 | `security_config.ml`, `taint_analyzer.ml` | Config + taint propagation engine |
| B | 40 | `vuln_checker.ml`, `vuln_reporter.ml` | Vulnerability detection + reporting |
| C | 25 | `analysis_report.md` | Written analysis of 5 programs |

### Build and test

```bash
# Build
dune build labs/lab5-security-analyzer/

# Run your tests (10 student-visible tests)
dune runtest labs/lab5-security-analyzer/starter/tests/
```

**Starter output** (before any implementation):

```
Fatal error: exception Failure("TODO: define default web security config")
```

The tests call `default_config` from `security_config.ml` first. Implement Part
A (config + analyzer) before moving to Part B (checker + reporter).

### Tips

- **Start with Part A** -- the analyzer is the foundation for Part B
- If you completed the exercises, reuse the same patterns (eval_expr,
  transfer_stmt, fixpoint) -- the lab versions add the config parameter
- The `taint_domain.ml` file is provided in the lab (not a TODO)
- Part C is a written report -- run programs through your analyzer and document
  the taint flow step by step

---

## 9. Troubleshooting

### Build errors

| Error | Fix |
|-------|-----|
| `ocaml: command not found` | Run `eval $(opam env)` or add it to your `~/.bashrc`/`~/.zshrc` |
| `dune: command not found` | `opam install dune && eval $(opam env)` |
| `Error: Unbound module OUnit2` | `opam install ounit2` |
| `Error: Unbound module Shared_ast` | Run `dune build` from the repo root first (not from inside an exercise) |
| `Error: Unbound module Abstract_domains` | Same -- `dune build` from the repo root |

### Test errors

| Symptom | Meaning |
|---------|---------|
| `EEEEEEEEEE` | Every test errors -- functions still have `failwith "TODO"` |
| `..EEEE` | First 2 tests pass, rest still TODO |
| `..F.EE` | 3rd test **fails** (wrong answer) -- read the error message for expected vs actual |
| `Fatal error: exception Failure("TODO: ...")` | The first function called is still a TODO -- implement it first |

### Common OCaml mistakes

| Mistake | Fix |
|---------|-----|
| `match` not exhaustive | Add all cases (`Bot`, `Top`, `Tainted`, `Untainted`) |
| `Stack overflow` in while fixpoint | Make sure widening makes progress and cap iterations at 100 |
| `type t is abstract` | You're using a module's internal type without qualifying it. Use `Taint_domain.taint` or `Env.t` explicitly |
| `Unbound value is_source` | In Exercise 3: `is_source` is defined in the same file. In Exercise 5: use `Vuln_config.is_source config name` |
| `This expression has type ... but was expected of type ...` | Check you're using the right module's types. Exercises 3-5 each have their own `Taint_domain` module -- don't accidentally reference the shared library's version |
| Pattern match on `Call` missing | Remember `Call(name, args)` -- you need both the function name and argument list |
| `Env.lookup` returns `Bot` for unknown variables | This is correct behavior -- `Bot` means "not yet assigned" |

### Running tests from the right directory

Always run `dune` commands from the **repository root**, not from inside an
exercise directory:

```bash
# CORRECT -- from repo root:
dune runtest modules/module5-security-analysis/exercises/taint-lattice/

# WRONG -- from inside the exercise (will fail to find shared libraries):
cd modules/module5-security-analysis/exercises/taint-lattice/
dune runtest   # ERROR: can't find shared_ast or abstract_domains
```

### Exercise-specific gotchas

- **Exercise 1:** The `propagate` function is NOT the same as `join`. `propagate
  Tainted Untainted = Tainted` (taint dominates), but `join Tainted Untainted =
  Top` (least upper bound).

- **Exercise 2:** String values must match exactly: `"sql-injection"` not
  `"SQL injection"`. The tests compare with `=`.

- **Exercise 3:** The `taint_domain.ml` in this directory is provided and
  complete. Do NOT modify it. Only edit `taint_propagator.ml`.

- **Exercise 4:** The `~pc_taint` is a labeled argument. Call it as
  `transfer_stmt ~pc_taint env s`, not `transfer_stmt pc_taint env s`.

- **Exercise 5:** The `vuln_config.ml` uses simpler record types than Exercise
  2's `config.ml` (no `_description` fields). Read `vuln_config.ml` to see the
  exact types.

---

## 10. Exercise Progression Cheat Sheet

```
Exercise 1: Taint Lattice             <-- 4-element domain, no widening needed
     |
Exercise 2: Security Config           <-- standalone: define source/sink/sanitizer data
     |
Exercise 3: Taint Propagation         <-- forward analysis with MakeEnv functor
     |
Exercise 4: Information Flow          <-- adds pc_taint for implicit flows
     |
Exercise 5: Vulnerability Detection   <-- config-driven, detects OWASP patterns
     |
Lab 5: Security Analyzer              <-- full pipeline: config + analysis + reporting
```

**Exercises 1 and 2** are independent of each other (one builds a domain, the
other builds a config). **Exercises 3-5** each embed their own provided
`taint_domain.ml`, so they don't depend on your Exercise 1 solution. However,
the concepts build on each other:

- Exercise 3 teaches the core eval_expr/transfer_stmt pattern
- Exercise 4 adds the pc_taint dimension
- Exercise 5 adds config-driven source/sink/sanitizer detection

**All exercises path:** 1 -> 2 -> 3 -> 4 -> 5 -> Lab 5 (95 exercise tests + 10 lab tests)

Good luck!
