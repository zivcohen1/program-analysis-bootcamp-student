# Module 6: Tools Implementation and Integration -- Student Guide

Welcome to Module 6, the capstone! You will compose techniques from Modules 2-5
into a complete program analysis tool: unified finding types, dead code detection,
multi-pass analysis (sign + taint), a configurable pipeline, and structured
report generation -- all in OCaml.

```
Program (AST)
     |
     v
+---------+  +--------+  +-------+
|Dead Code|  | Safety |  | Taint |   <-- Analysis Passes
|Detector |  | (Sign) |  |(Taint)|
+----+----+  +---+----+  +---+---+
     |           |            |
     v           v            v
+----------------------------------+
|    finding list (unified type)   |
+----------------------------------+
     |
     v
+----------------------------------+
| Pipeline: config -> filter -> cap|
+----------------------------------+
     |
     v
+----------------------------------+
| Reporter: text / JSON / summary  |
+----------------------------------+
```

**Exercises:** 5 (96 tests) | **Lab:** Lab 6 -- Integrated Analyzer (10 tests)
**Estimated time:** 2-3 hours for exercises, 2-4 hours for the lab

---

## Table of Contents

1. [Background: Key Concepts](#1-background-key-concepts)
2. [Exercise 1: Analysis Finding](#2-exercise-1-analysis-finding-20-tests)
3. [Exercise 2: Dead Code Detector](#3-exercise-2-dead-code-detector-20-tests)
4. [Exercise 3: Multi-Pass Analyzer](#4-exercise-3-multi-pass-analyzer-20-tests)
5. [Exercise 4: Configurable Pipeline](#5-exercise-4-configurable-pipeline-18-tests)
6. [Exercise 5: Analysis Reporter](#6-exercise-5-analysis-reporter-18-tests)
7. [Lab 6: Integrated Analyzer](#7-lab-6-integrated-analyzer-10-tests)
8. [Troubleshooting](#8-troubleshooting)
9. [Exercise Progression Cheat Sheet](#9-exercise-progression-cheat-sheet)

---

## 1. Background: Key Concepts

Before starting, review these shared types and patterns that appear across all
exercises.

### The unified `finding` type

Every analysis pass produces findings in the same format. This is the record
type used throughout Module 6:

```ocaml
type severity = Critical | High | Medium | Low | Info

type category = Security | Safety | CodeQuality | Performance

type finding = {
  id : int;
  category : category;
  severity : severity;
  pass_name : string;      (* which analysis produced this *)
  location : string;       (* function name where it was found *)
  message : string;        (* human-readable description *)
  suggestion : string option;  (* optional fix suggestion *)
}
```

The `severity` values form an ordering: Critical (4) > High (3) > Medium (2) >
Low (1) > Info (0). This ordering drives sorting, filtering, and reporting.

### The `analysis_pass` record type

Exercises 3 and 4 use a record to represent a composable analysis pass:

```ocaml
type analysis_pass = {
  name : string;                                      (* "safety", "taint", etc. *)
  category : Finding_types.category;                  (* Safety, Security, etc. *)
  run : program -> Finding_types.finding list;        (* the analysis function *)
}
```

Each pass is a self-contained function that takes a program AST and returns
findings. Passes are composed by running them all and merging their results.

### The pipeline concept

The pipeline takes a configuration (which passes to enable, severity thresholds,
category filters, max finding count) and orchestrates the full analysis:

```
Config --> Build passes --> Run all --> Filter/sort --> Cap at max --> Report
```

This is the pattern used in real-world tools like ESLint, Clang-Tidy, and
Semgrep: configurable, composable analysis with structured output.

---

## 2. Exercise 1: Analysis Finding (20 tests)

**Goal:** Define utility functions on the unified finding type -- conversion,
comparison, filtering, deduplication, formatting, and counting.

**Time:** ~20 minutes

**File to edit:** `exercises/analysis-finding/starter/analysis_finding.ml`

**Dependencies:** None (self-contained)

### Types provided (not a TODO)

The `severity`, `category`, and `finding` types are already defined at the top
of the file. You implement the functions that operate on them.

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `severity_to_string s` | Pattern match: `Critical -> "Critical"`, etc. |
| 2 | `category_to_string c` | Pattern match: `Security -> "Security"`, `CodeQuality -> "CodeQuality"`, etc. |
| 3 | `severity_to_int s` | `Critical=4, High=3, Medium=2, Low=1, Info=0` |
| 4 | `compare_by_severity a b` | Higher severity first: compare `severity_to_int b - severity_to_int a` (negative means a is more severe) |
| 5 | `compare_by_location a b` | `String.compare a.location b.location` |
| 6 | `filter_by_severity threshold findings` | Keep findings where `severity_to_int f.severity >= severity_to_int threshold` |
| 7 | `filter_by_category cat findings` | Keep findings where `f.category = cat` |
| 8 | `deduplicate findings` | Remove duplicates with same `message` AND same `location`; preserve first occurrence |
| 9 | `format_finding f` | Format: `"[Severity] Category - message in location"`. If suggestion is `Some s`, append `"\n  Suggestion: s"` |
| 10 | `format_findings_list findings` | Return `"No findings."` for empty list; otherwise one formatted finding per line |
| 11 | `count_by_severity findings` | Return `(severity * int) list` ordered Critical..Info, excluding zero-count entries |
| 12 | `count_by_category findings` | Return `(category * int) list` ordered Security..Performance, excluding zero-count entries |

### Run tests

```bash
dune runtest modules/module6-tools-integration/exercises/analysis-finding/
```

**Starter output (all 20 tests error):**

```
EEEEEEEEEEEEEEEEEEEE
```

**Hints:**
- For `deduplicate`, fold through the list keeping a set of `(message, location)`
  pairs you have already seen. `List.rev` at the end to preserve order.
- For `count_by_severity`, iterate over `[Critical; High; Medium; Low; Info]`,
  count how many findings match each, and drop entries with count 0.

---

## 3. Exercise 2: Dead Code Detector (20 tests)

**Goal:** Detect dead code patterns using purely AST-level analysis: unreachable
code after `Return`, unused variables, and unused function parameters.

**Time:** ~25 minutes

**File to edit:** `exercises/dead-code-detector/starter/dead_code.ml`

**Also provided (do not edit):** `exercises/dead-code-detector/starter/finding_types.ml`

**Dependencies:** `shared_ast` (for AST types)

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `has_return stmts` | Check if any top-level stmt in the list is a `Return` |
| 2 | `stmts_after_return stmts` | Walk the list; once you hit a `Return`, return everything after it |
| 3 | `collect_used_vars_expr e` | Recursively collect `Var x` names into a `StringSet`. `IntLit`/`BoolLit` contribute nothing. `BinOp` unions both sides. `Call` unions all args. |
| 4 | `collect_used_vars_stmts stmts` | Union used vars from each statement. For `Assign(_, e)` collect from `e`. For `If`/`While` collect from condition + bodies. For `Return (Some e)` collect from `e`. |
| 5 | `collect_assigned_vars stmts` | Collect all `x` from `Assign(x, _)` statements, recursing into `If`/`While`/`Block` bodies |
| 6 | `find_unreachable_code func` | If `stmts_after_return func.body` is non-empty, emit a `CodeQuality`/`Medium` finding |
| 7 | `find_unused_variables func` | Assigned but never read variables get `CodeQuality`/`Low` findings. Variables starting with `_` are exempt. |
| 8 | `find_unused_parameters func` | Parameters never read in the body get `CodeQuality`/`Info` findings. Parameters starting with `_` are exempt. |
| 9 | `analyze_function func` | Concatenate results of all three detectors for one function |
| 10 | `analyze_program prog` | `List.concat_map analyze_function prog` |

### Run tests

```bash
dune runtest modules/module6-tools-integration/exercises/dead-code-detector/
```

**Starter output (all 20 tests error):**

```
EEEEEEEEEEEEEEEEEEEE
```

**Hints:**
- Use `StringSet.mem`, `StringSet.union`, `StringSet.singleton`, and
  `StringSet.diff` for variable tracking.
- The `_`-prefix exemption check: `String.length name > 0 && name.[0] = '_'`.
- Use `fresh_id ()` to generate unique IDs for each finding.
- Finding `location` should be the function name (`func.name`).

---

## 4. Exercise 3: Multi-Pass Analyzer (20 tests)

**Goal:** Compose safety (sign domain) and taint analysis into independent
passes, then run, merge, and partition their findings.

**Time:** ~30 minutes

**File to edit:** `exercises/multi-pass-analyzer/starter/multi_pass.ml`

**Also provided (do not edit):**
- `sign_domain.ml` -- complete sign abstract domain
- `taint_domain.ml` -- complete taint abstract domain
- `finding_types.ml` -- unified finding types with helpers
- `sample_programs.ml` -- test programs (div-by-zero, taint-to-sink, etc.)

**Dependencies:** `abstract_domains`, `shared_ast`

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `make_safety_pass ()` | Create an `analysis_pass` named `"safety"` with category `Safety`. Use `MakeEnv(Sign_domain)` for the environment. Evaluate expressions with sign arithmetic. Detect `BinOp(Div, _, denom)` where divisor is `Zero` (High severity) or `Top` (Medium severity). |
| 2 | `make_taint_pass ()` | Create an `analysis_pass` named `"taint"` with category `Security`. Use `MakeEnv(Taint_domain)` for the environment. Hardcode sources/sinks/sanitizers (listed in the docstring). Check sink calls for tainted arguments, emitting Critical severity findings. |
| 3 | `run_pass pass prog` | Simply call `pass.run prog` |
| 4 | `run_all_passes passes prog` | Run each pass and concatenate all findings |
| 5 | `merge_findings findings_list` | Flatten the list of lists, then sort by severity (highest first) |
| 6 | `partition_by_pass findings` | Group findings by `pass_name`, preserving first-seen order of pass names. Return `(pass_name, findings) list`. |
| 7 | `default_passes ()` | Return `[make_safety_pass (); make_taint_pass ()]` |

### Hardcoded sources, sinks, and sanitizers for the taint pass

```
Sources:    get_param, read_cookie, read_input, read_file, get_header
Sinks:      (exec_query, sql-injection), (send_response, xss),
            (exec_cmd, command-injection), (open_file, path-traversal)
Sanitizers: escape_sql, html_encode, shell_escape, validate_path
```

### Run tests

```bash
dune runtest modules/module6-tools-integration/exercises/multi-pass-analyzer/
```

**Starter output (all 20 tests error):**

```
EEEEEEEEEEEEEEEEEEEE
```

**Hints:**
- You need to create `SignEnv` and `TaintEnv` modules using the `MakeEnv`
  functor from `Abstract_domains.Abstract_env`. Wrap the domain in a struct
  that satisfies `ABSTRACT_DOMAIN`:
  ```ocaml
  module SignEnv = Abstract_domains.Abstract_env.MakeEnv (struct
    type t = Sign_domain.sign
    let bottom = Sign_domain.bottom
    let top = Sign_domain.top
    let join = Sign_domain.join
    (* ... etc ... *)
  end)
  ```
- For the safety pass, write a recursive `eval_sign` and `transfer_sign` inside
  `make_safety_pass`. Initialize function parameters to `Sign_domain.Top`.
- For the taint pass, write a recursive `eval_taint` and `transfer_taint`.
  Literal values are `Untainted`, source calls return `Tainted`, sanitizer
  calls return `Untainted`.
- While loops need a fixpoint with widening (same pattern as Module 4).

---

## 5. Exercise 4: Configurable Pipeline (18 tests)

**Goal:** Build a configuration-driven pipeline that selects analysis passes
and filters results by severity, category, and count.

**Time:** ~25 minutes

**File to edit:** `exercises/configurable-pipeline/starter/pipeline.ml`

**Also provided (do not edit):**
- `pass_registry.ml` -- complete working implementations of `safety_pass`,
  `taint_pass`, and `dead_code_pass`
- `sign_domain.ml`, `taint_domain.ml` -- abstract domains
- `finding_types.ml` -- unified finding types
- `sample_programs.ml` -- test programs

**Dependencies:** `abstract_domains`, `shared_ast`

### Important: `default_config` crashes immediately

Unlike other exercises where `failwith "TODO"` only triggers when tests call the
function, `default_config` is a **module-level value** (not a function). This
means it is evaluated when the module loads, which happens before any tests run.
As a result, the starter output is:

```
Fatal error: exception Failure("TODO: default_config")
```

**Implement `default_config` first** to unblock all 18 tests.

### Types provided (not a TODO)

```ocaml
type pass_id = DeadCode | Safety | Taint

type pipeline_config = {
  enabled_passes : pass_id list;
  min_severity : Finding_types.severity;
  max_findings : int option;           (* None = no cap *)
  target_categories : Finding_types.category list option;  (* None = all *)
}
```

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `default_config` | All passes enabled `[DeadCode; Safety; Taint]`, `min_severity = Info`, `max_findings = None`, `target_categories = None` |
| 2 | `config_with_passes passes` | Start from `default_config`, override `enabled_passes` |
| 3 | `config_with_severity sev config` | Return `{ config with min_severity = sev }` |
| 4 | `config_with_max n config` | Return `{ config with max_findings = Some n }` |
| 5 | `config_with_categories cats config` | Return `{ config with target_categories = Some cats }` |
| 6 | `create_pass pid` | Map `DeadCode -> Pass_registry.dead_code_pass`, `Safety -> Pass_registry.safety_pass`, `Taint -> Pass_registry.taint_pass` |
| 7 | `build_pipeline config` | `List.map create_pass config.enabled_passes` |
| 8 | `apply_filters config findings` | Four steps in order: (1) filter by `min_severity`, (2) filter by `target_categories` if `Some`, (3) sort by severity (highest first), (4) take first `max_findings` if `Some` |
| 9 | `run_pipeline config prog` | Build the pipeline, run all passes (concatenating findings), then apply filters |

### Run tests

```bash
dune runtest modules/module6-tools-integration/exercises/configurable-pipeline/
```

**Starter output (crashes before tests run):**

```
Fatal error: exception Failure("TODO: default_config")
```

**Hints:**
- For `apply_filters`, use `List.filteri` or a helper to take the first N
  elements when capping at `max_findings`.
- The severity filter keeps findings where
  `Finding_types.severity_to_int f.severity >= Finding_types.severity_to_int min_severity`.
- The sort puts the highest severity first (descending order).

---

## 6. Exercise 5: Analysis Reporter (18 tests)

**Goal:** Generate human-readable text reports, JSON output, summary lines,
and formatted tables from analysis findings.

**Time:** ~25 minutes

**File to edit:** `exercises/analysis-reporter/starter/reporter.ml`

**Also provided (do not edit):**
- `finding_types.ml` -- unified finding types with all helpers
- `sample_findings.ml` -- pre-built findings for testing

**Dependencies:** None (self-contained)

### Types provided (not a TODO)

```ocaml
type report = {
  program_name : string;
  total_findings : int;
  findings : Finding_types.finding list;
  severity_counts : (Finding_types.severity * int) list;
  category_counts : (Finding_types.category * int) list;
  pass_counts : (string * int) list;
}
```

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `build_report name findings` | Fill in all report fields. Count severities, categories, and pass names. |
| 2 | `format_text_report r` | Header with `"=== Analysis Report: name ==="`, total count, each formatted finding, severity breakdown |
| 3 | `format_json_finding f` | JSON object string with fields: `id`, `category`, `severity`, `pass_name`, `location`, `message`, `suggestion` (null if None) |
| 4 | `format_json_report r` | JSON object with fields: `program`, `total`, `findings` (array), `severity_counts`, `category_counts` |
| 5 | `format_summary r` | Empty: `"Analysis of 'name': No findings."` Non-empty: `"Analysis of 'name': N findings (X Critical, Y High, ...)"` -- only include non-zero severity counts |
| 6 | `format_findings_table findings` | Aligned text table with columns: Severity, Category, Pass, Location, Message |
| 7 | `top_n_findings n findings` | Sort by severity (highest first), take first `n` |
| 8 | `findings_above_severity threshold findings` | Keep findings where `severity_to_int f.severity >= severity_to_int threshold` |

### Run tests

```bash
dune runtest modules/module6-tools-integration/exercises/analysis-reporter/
```

**Starter output (all 18 tests error):**

```
EEEEEEEEEEEEEEEEEE
```

**Hints:**
- For `format_json_finding`, use `Printf.sprintf` to build the JSON string.
  Escape quotes in string values if needed, but the test data does not contain
  embedded quotes.
- For `format_summary`, iterate over `severity_counts` and build
  `"X Critical, Y High"` fragments, filtering out zero counts.
- For `format_findings_table`, compute the max width of each column first,
  then pad with `Printf.sprintf "%-*s"`.

---

## 7. Lab 6: Integrated Analyzer (10 tests)

After completing the exercises, tackle the lab. It integrates everything into a
single multi-pass analyzer with dead code detection, safety analysis, taint
analysis, a pipeline, and reporting.

**Location:** `labs/lab6-integrated-analyzer/`

**Read the full spec:** `labs/lab6-integrated-analyzer/README.md`

### Structure

| Part | Points | Files | What you build |
|------|--------|-------|----------------|
| A | 35 | `finding.ml`, `dead_code.ml` | Unified finding type + AST-level dead code detection |
| B | 40 | `safety_analysis.ml`, `taint_analysis.ml`, `pipeline.ml` | Multi-pass analysis + configurable pipeline |
| C | 25 | `reporter.ml`, `analysis_report.md` | Report generation + written analysis |

### Provided files (do not edit)

- `sign_domain.ml` -- Sign abstract domain (from Module 4)
- `taint_domain.ml` -- Taint abstract domain (from Module 5)
- `taint_config.ml` -- Security configuration (sources, sinks, sanitizers)

### Build and test

```bash
# Build
dune build labs/lab6-integrated-analyzer/

# Run tests (10 student-visible tests)
dune runtest labs/lab6-integrated-analyzer/starter/tests/
```

**Starter output (all 10 tests error):**

```
EEEEEEEEEE
```

### Tips

- **Start with Part A** -- `finding.ml` and `dead_code.ml` have no domain
  dependencies and mirror Exercises 1 and 2.
- **Part B** reuses patterns from Exercises 3 and 4 -- reference your sign domain
  (Module 4) and taint domain (Module 5) work.
- **Part C** mirrors Exercise 5 -- build reports, format text, generate summaries.
- Variables/parameters prefixed with `_` are exempt from unused warnings.
- Use `Finding.severity_to_int` for sorting (higher = more severe).

---

## 8. Troubleshooting

### Build errors

| Error | Fix |
|-------|-----|
| `Error: Unbound module Shared_ast` | Run `dune build` from the **repo root**, not from inside an exercise directory |
| `Error: Unbound module Abstract_domains` | Same -- `dune build` from the repo root |
| `Error: Unbound module Sign_domain` | The sign domain is a local file in your exercise's `starter/` directory, not a shared library. Make sure it exists and your dune file includes it. |
| `Error: Unbound module Pass_registry` | Same -- it is a local file in the `configurable-pipeline/starter/` directory |
| `Error: Unbound module Finding_types` | Local file in your exercise's `starter/` directory; make sure it is not deleted |

### Test errors

| Symptom | Meaning |
|---------|---------|
| `EEEEEEEEEEEEEEEEEEEE` | Every test errors -- functions still have `failwith "TODO"` |
| `..EEEEEE` | First 2 tests pass, rest still TODO |
| `..F.EEEE` | 3rd test **fails** (wrong answer) -- read the error message for expected vs actual |
| `Fatal error: exception Failure("TODO: default_config")` | Exercise 4 only: `default_config` is a module-level value that evaluates at load time. Implement it first to unblock all tests. |

### Common mistakes

| Mistake | Fix |
|---------|-----|
| `compare_by_severity` sorts ascending | Higher severity should come first (Critical before Info). Return `severity_to_int b.severity - severity_to_int a.severity`. |
| `deduplicate` loses order | Use a fold that accumulates a seen set and a reversed result list, then `List.rev` at the end |
| `filter_by_severity` uses `=` instead of `>=` | Use `severity_to_int` and compare with `>=` against the threshold |
| `_`-prefixed variables flagged as unused | Check `name.[0] = '_'` before reporting unused variables/parameters |
| `count_by_severity` includes zero-count entries | Filter the final list to exclude `(_, 0)` pairs |
| JSON output has wrong format | Read the test file carefully for the exact expected format -- field order, quoting, commas |

### Running tests from the right directory

Always run `dune` commands from the **repository root**, not from inside an
exercise directory:

```bash
# CORRECT -- from repo root:
dune runtest modules/module6-tools-integration/exercises/analysis-finding/

# WRONG -- from inside the exercise (may fail to find shared libraries):
cd modules/module6-tools-integration/exercises/analysis-finding/
dune runtest   # ERROR: can't find shared_ast or abstract_domains
```

---

## 9. Exercise Progression Cheat Sheet

```
Exercise 1: Analysis Finding         <-- unified types, no dependencies
     |
Exercise 2: Dead Code Detector       <-- AST-level analysis, uses shared_ast
     |
Exercise 3: Multi-Pass Analyzer      <-- compose sign + taint passes (heaviest exercise)
     |
Exercise 4: Configurable Pipeline    <-- config-driven pass selection + filtering
     |
Exercise 5: Analysis Reporter        <-- text + JSON output, no dependencies
     |
Lab 6: Integrated Analyzer           <-- everything combined into one tool
```

**Dependency note:** Each exercise is self-contained (exercises do not import
from each other). However, they build conceptually: Exercise 1 establishes the
finding type, Exercise 2 adds a new pass, Exercise 3 composes passes, Exercise 4
adds configuration, and Exercise 5 adds reporting. Work through them in order.

**Minimum path:** All 5 exercises are required (96 tests) + Lab 6 (10 tests)

Good luck -- this is where it all comes together!
