# Module 4: Abstract Interpretation — Student Guide

Welcome to Module 4! You'll implement three abstract domains (Sign, Constant,
Interval), formalize Galois connections, and build a generic abstract interpreter
that detects division-by-zero bugs — all in OCaml.

```
Source Code  →  AST  →  Abstract Interpretation  →  Safety Proof
                               |
               +───────────────+───────────────+
               |               |               |
         Sign Domain    Constant Domain   Interval Domain
        (fast, coarse)  (good for opt)   (precise, needs widen)
```

**Required exercises:** 3 (71 tests) | **Optional exercises:** 2 (29 tests)
**Lab:** Lab 4 — Abstract Interpreter (10 tests)
**Estimated time:** 1.5–2 hours for required exercises, 2–4 hours for the lab

---

## Table of Contents

1. [Environment Setup](#1-environment-setup)
2. [Verify Your Setup](#2-verify-your-setup)
3. [How Exercises Work](#3-how-exercises-work)
4. [Background: Key Concepts](#4-background-key-concepts)
5. [Exercise 1: Sign Lattice](#5-exercise-1-sign-lattice-20-tests)
6. [Exercise 2: Constant Propagation](#6-exercise-2-constant-propagation-23-tests)
7. [Exercise 3: Galois Connections (Optional)](#7-exercise-3-galois-connections-optional-16-tests)
8. [Exercise 4: Interval Domain](#8-exercise-4-interval-domain-28-tests)
9. [Exercise 5: Abstract Interpreter (Optional)](#9-exercise-5-abstract-interpreter-optional-13-tests)
10. [Lab 4: Integrated Abstract Interpreter](#10-lab-4-integrated-abstract-interpreter-10-tests)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Environment Setup

You need **OCaml**, **opam** (package manager), **dune** (build system),
**ounit2** (test framework), and **menhir** (parser generator for Lab 2).

### macOS

```bash
# 1. Install opam via Homebrew
brew install opam

# 2. Initialize opam (first time only — say yes to all prompts)
opam init -y
eval $(opam env)

# 3. Create an OCaml 5.1.0 switch (compiler + standard library)
opam switch create 5.1.0
eval $(opam env)

# 4. Install required packages
opam install dune ounit2 menhir -y
```

### Ubuntu / Debian (or WSL on Windows)

```bash
# 1. Install opam
sudo apt update && sudo apt install -y opam

# 2. Initialize opam
opam init -y
eval $(opam env)

# 3. Create an OCaml 5.1.0 switch
opam switch create 5.1.0
eval $(opam env)

# 4. Install required packages
opam install dune ounit2 menhir -y
```

### Windows (native)

Use WSL2 (recommended). Install Ubuntu from the Microsoft Store, then follow
the Ubuntu instructions above inside the WSL terminal.

### Shell configuration (important!)

Add this to your `~/.bashrc` or `~/.zshrc` so opam is available in every
terminal session:

```bash
eval $(opam env)
```

Then restart your terminal or run `source ~/.bashrc` / `source ~/.zshrc`.

---

## 2. Verify Your Setup

After installing, run these commands to confirm everything works:

```bash
# Check versions (your numbers may differ slightly — that's fine)
ocaml -version          # should print "The OCaml toplevel, version 5.x.x"
dune --version           # should print "3.x.x"
opam list ounit2         # should show ounit2 installed
opam list menhir         # should show menhir installed
```

Now clone the repo (if you haven't already) and do a full build:

```bash
git clone <your-repo-url>
cd program-analysis-bootcamp-student

# Build everything — this compiles all libraries, exercises, and labs
dune build
```

You should see **no errors**. You may see some warnings from
`labs/lab2-ast-parser/starter/parser.mly` — those are expected (the parser
starter has unused tokens because you haven't implemented the grammar rules yet).

Finally, run one exercise's tests to confirm the test framework works:

```bash
dune runtest modules/module4-abstract-interpretation/exercises/sign-lattice/
```

You should see output like:

```
Fatal error: exception Failure("TODO: return the bottom element")
```

This is normal! The test tried to call your first function (`bottom`), which is
still a `failwith "TODO"` stub, so it crashed immediately. As you implement
functions one by one, you'll start seeing individual test results instead:

```
..EEEEEE          ← 2 passing, 6 errors (still have TODOs)
....F...EE        ← 4 passing, 1 wrong answer, 2 TODOs left
....................  ← all 20 passing — done!
```

Your goal is to turn that fatal error into all dots (`.`).

---

## 3. How Exercises Work

Each exercise has this structure:

```
exercises/sign-lattice/
├── dune                          ← tells dune which dirs to build
├── starter/
│   ├── dune                      ← library definition
│   └── sign_domain.ml            ← YOUR FILE — edit this
└── tests/
    ├── dune                      ← test configuration
    └── test_sign.ml              ← read-only test file
```

**The workflow:**

1. **Read the starter file** — types and docstrings are provided; every function
   body is `failwith "TODO: ..."` with a comment explaining what to implement.

2. **Implement one function at a time** — replace the `failwith` with real code.

3. **Run tests** — see your progress:
   ```bash
   dune runtest modules/module4-abstract-interpretation/exercises/sign-lattice/
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
   - `E` = error (your code threw an exception — likely a remaining TODO)
   - `F` = failure (your code ran but returned the wrong answer — check logic)

5. **Repeat** until all tests pass: `....................` (all dots!)

**Tips:**
- Implement functions **in the order they appear** in the file — later functions
  often depend on earlier ones.
- Read the test file (`tests/test_*.ml`) to understand exactly what's expected.
- Tests are read-only — don't modify them.

---

## 4. Background: Key Concepts

Before starting the exercises, make sure you understand these ideas from the
slides.

### The `ABSTRACT_DOMAIN` signature

Every domain you implement must satisfy this interface (defined in
`lib/abstract_domains/abstract_domain.ml`):

```ocaml
module type ABSTRACT_DOMAIN = sig
  type t                            (* the abstract value type *)
  val bottom : t                    (* least element: unreachable *)
  val top : t                       (* greatest element: unknown *)
  val join : t -> t -> t            (* least upper bound *)
  val meet : t -> t -> t            (* greatest lower bound *)
  val leq : t -> t -> bool          (* partial order: a ⊑ b *)
  val equal : t -> t -> bool        (* equality *)
  val widen : t -> t -> t           (* widening for termination *)
  val to_string : t -> string       (* pretty-print *)
end
```

### The `MakeEnv` functor

The environment maps variable names to abstract values. It's defined in
`lib/abstract_domains/abstract_env.ml` and used in Exercises 2, 4, 5, and Lab 4:

```ocaml
module MakeEnv (D : ABSTRACT_DOMAIN) : sig
  type t                                   (* string → D.t map *)
  val bottom : t                           (* empty environment *)
  val lookup : string -> t -> D.t          (* returns D.bottom if missing *)
  val update : string -> D.t -> t -> t     (* set variable *)
  val join : t -> t -> t                   (* pointwise join *)
  val leq : t -> t -> bool                (* pointwise leq *)
  val widen : t -> t -> t                  (* pointwise widen *)
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

## 5. Exercise 1: Sign Lattice (20 tests)

**Goal:** Implement the 5-element sign domain and abstract arithmetic.

**Time:** ~20 minutes

**File to edit:** `exercises/sign-lattice/starter/sign_domain.ml`

### The sign lattice

```
         Top           "could be anything"
        / | \
     Neg Zero Pos      "definitely negative / zero / positive"
        \ | /
        Bot             "unreachable"
```

### What to implement (in order)

| # | Function | Hint |
|---|----------|------|
| 1 | `bottom` | Return `Bot` |
| 2 | `top` | Return `Top` |
| 3 | `join a b` | Least upper bound — if `a = b` return it, otherwise `Top` (handle `Bot`/`Top` first) |
| 4 | `meet a b` | Greatest lower bound — dual of join |
| 5 | `leq a b` | `a ⊑ b` means `join a b = b` (or: Bot ⊑ everything, everything ⊑ Top) |
| 6 | `equal a b` | Structural equality |
| 7 | `widen a b` | For finite domains, widen = join |
| 8 | `to_string` | `"Bot"`, `"Neg"`, `"Zero"`, `"Pos"`, `"Top"` |
| 9 | `alpha_int n` | `n > 0 → Pos`, `n = 0 → Zero`, `n < 0 → Neg` |
| 10–14 | `abstract_neg`, `abstract_add`, `abstract_sub`, `abstract_mul`, `abstract_div` | See the arithmetic tables in the slides |

### Run tests

```bash
dune runtest modules/module4-abstract-interpretation/exercises/sign-lattice/
```

**Hint for arithmetic:** Handle `Bot` first (anything with `Bot` returns `Bot`),
then `Top` cases, then the 9 concrete combinations (Neg/Zero/Pos × Neg/Zero/Pos).

---

## 6. Exercise 2: Constant Propagation (23 tests)

**Goal:** Implement the flat constant lattice and an expression evaluator.

**Time:** ~20 minutes

**Files to edit:**
- `exercises/constant-propagation/starter/constant_domain.ml` — the lattice
- `exercises/constant-propagation/starter/constant_eval.ml` — expression evaluator

### The flat constant lattice

```
              Top             "not a constant"
         /  |  |  |  \
  ... Const(-1) Const(0) Const(1) ...
         \  |  |  |  /
              Bot             "unreachable"
```

### What to implement

**In `constant_domain.ml`:**

| # | Function | Hint |
|---|----------|------|
| 1–8 | `bottom`, `top`, `join`, `meet`, `leq`, `equal`, `widen`, `to_string` | Same pattern as sign, but values are `Bot \| Const of int \| Top` |
| 9 | `abstract_binop op a b` | If both are `Const`, compute the concrete result. Handle `Div` by zero → `Bot`. Any `Top` → `Top`, any `Bot` → `Bot` |
| 10 | `abstract_unaryop op a` | `Neg` negates the constant, `Not` inverts (treat nonzero as true) |

**In `constant_eval.ml`:**

| # | Function | Hint |
|---|----------|------|
| 1 | `eval_expr env expr` | Recursively evaluate: `IntLit n → Const n`, `Var x → lookup x in env`, `BinOp → abstract_binop`, `Call → Top` (unknown function) |

### Run tests

```bash
dune runtest modules/module4-abstract-interpretation/exercises/constant-propagation/
```

---

## 7. Exercise 3: Galois Connections (Optional, 16 tests)

> **This exercise is optional.** It covers the theoretical foundations of
> abstract interpretation (Galois connections, adjunction, monotonicity).
> Completing it will deepen your understanding but is not required for
> Exercise 4 or the lab. Skip to [Exercise 4](#8-exercise-4-interval-domain-28-tests) if you prefer.

**Goal:** Formalize the alpha/gamma pair for the sign domain and verify
soundness properties (adjunction, monotonicity).

**Time:** ~25 minutes

**File to edit:** `exercises/galois-connections/starter/galois.ml`

**Also read:** `exercises/galois-connections/starter/worksheet.md` (guided
questions — fill in on paper or in the file)

### Key ideas

- **alpha (abstraction):** maps a set of integers to the best sign
  - `alpha({1, 2, 3}) = Pos`
  - `alpha({-1, 0, 5}) = Top`
  - `alpha({}) = Bot`

- **gamma (concretization):** maps a sign to a representative set
  - `gamma(Zero) = {0}` (exact)
  - `gamma(Pos) = {1, 2, 3, ...}` (representative, not exhaustive)

- **Adjunction:** `alpha(c) ⊑ a` iff `c ⊆ gamma(a)`

### What to implement

| # | Function | Hint |
|---|----------|------|
| 1 | `sign_leq a b` | Same as Exercise 1's `leq` |
| 2 | `sign_equal a b` | Structural equality |
| 3 | `sign_to_string` | Same as Exercise 1 |
| 4 | `alpha_int n` | Single integer → sign |
| 5 | `alpha set` | Fold over the set, joining signs. Empty set → `Bot` |
| 6 | `gamma_repr sign` | Return `(representative_set, is_exact)`. Bot → `({}, true)`, Zero → `({0}, true)`, Pos → `({1,2,3}, false)` |
| 7 | `in_gamma n sign` | Is concrete value `n` in the concretization of `sign`? |
| 8 | `verify_adjunction set sign` | Check: `sign_leq (alpha set) sign` iff `IntSet.subset set (gamma_set sign)` — but gamma is infinite, so use `in_gamma` for each element |
| 9 | `verify_alpha_monotone s1 s2` | If `s1 ⊆ s2` then `alpha(s1) ⊑ alpha(s2)` |

### Run tests

```bash
dune runtest modules/module4-abstract-interpretation/exercises/galois-connections/
```

---

## 8. Exercise 4: Interval Domain (28 tests)

**Goal:** Implement an infinite-height domain with widening for guaranteed
termination.

**Time:** ~30 minutes

**Files to edit:**
- `exercises/interval-domain/starter/interval_domain.ml` — the domain
- `exercises/interval-domain/starter/interval_eval.ml` — expression evaluator

### The interval type

```ocaml
type bound = NegInf | Finite of int | PosInf
type interval = Bot | Interval of bound * bound
```

### What to implement

**In `interval_domain.ml`:**

| # | Function | Hint |
|---|----------|------|
| 1–4 | `add_bound`, `neg_bound`, `min_bound`, `max_bound` | Helper functions for bound arithmetic. Handle `NegInf`/`PosInf` cases carefully |
| 5 | `bottom`, `top` | `Bot` and `Interval(NegInf, PosInf)` |
| 6 | `join` | `[min(a,c), max(b,d)]` — the smallest interval containing both |
| 7 | `meet` | `[max(a,c), min(b,d)]` — the overlap; `Bot` if empty |
| 8 | `leq` | `[a,b] ⊑ [c,d]` iff `c ≤ a` and `b ≤ d` |
| 9 | `widen` | **Key function!** If the new bound exceeds the old, jump to ±∞ |
| 10 | `contains_zero`, `is_non_negative` | Range queries |
| 11–15 | `abstract_add`, `abstract_sub`, `abstract_neg`, `abstract_mul`, `abstract_div` | Interval arithmetic (mul needs all 4 corners) |

**In `interval_eval.ml`:**

| # | Function | Hint |
|---|----------|------|
| 1 | `eval_expr env expr` | Same pattern as constant_eval, but using interval operations |

### The widening rule (most important function!)

```
widen([a, b], [c, d]) =
  lower = if c < a then NegInf else a
  upper = if d > b then PosInf else b
```

If the bounds grow → jump to infinity. If they shrink or stay → keep.

### Run tests

```bash
dune runtest modules/module4-abstract-interpretation/exercises/interval-domain/
```

---

## 9. Exercise 5: Abstract Interpreter (Optional, 13 tests)

> **This exercise is optional.** It builds a full abstract interpreter using
> OCaml functors. It's the most advanced exercise in this module. The lab
> covers similar ground with more guidance, so you can go directly to
> [Lab 4](#10-lab-4-integrated-abstract-interpreter-10-tests) if you prefer.

**Goal:** Wire everything together — a generic interpreter parameterized by any
`ABSTRACT_DOMAIN`, with division-by-zero detection.

**Time:** ~25 minutes

**Files to edit:** `exercises/abstract-interpreter/starter/abstract_interp.ml`

**Also provided:** `exercises/abstract-interpreter/starter/sample_analysis.ml`
(test programs you can read to understand what the tests do)

### Architecture

```ocaml
module Make (D : ABSTRACT_DOMAIN) = struct
  module Env = MakeEnv(D)

  val eval_expr     : Env.t -> expr -> D.t
  val transfer_stmt : Env.t -> stmt -> Env.t
  val analyze_function : func_def -> Env.t
  val check_div_by_zero : func_def -> (string * string) list
end
```

The file provides three built-in domains (`SignDomain`, `ConstDomain`,
`IntervalDomain`) so the tests can instantiate the functor with different
domains.

### What to implement

| # | Function | Hint |
|---|----------|------|
| 1 | `eval_expr env expr` | Pattern match on `expr`: `IntLit n → D.alpha_int n` (or your domain's abstraction), `Var x → Env.lookup x env`, `BinOp → abstract_op`, `Call → D.top` |
| 2 | `transfer_stmt env stmt` | `Assign(x, e) → Env.update x (eval_expr env e) env`; `If → join both branches`; `While → fixpoint with widening` |
| 3 | `transfer_stmts env stmts` | Fold `transfer_stmt` over the list |
| 4 | `analyze_function func` | Initialize params to `D.top`, transfer the body |
| 5 | `check_div_by_zero func` | Walk expressions, find `BinOp(Div, _, denom)` where `denom` could be zero |

### The while loop fixpoint (hardest part)

```
1. Start with current env
2. Transfer the loop body to get env'
3. Widen: env'' = Env.widen env env'
4. If env'' = env (stable), stop — return env
5. Otherwise, repeat from step 2 with env''
```

### Run tests

```bash
dune runtest modules/module4-abstract-interpretation/exercises/abstract-interpreter/
```

---

## 10. Lab 4: Integrated Abstract Interpreter (10 tests)

After completing all 5 exercises, tackle the lab. It integrates everything into
a multi-domain analyzer with safety checking and reporting.

**Location:** `labs/lab4-abstract-interpreter/`

**Read the full spec:** `labs/lab4-abstract-interpreter/README.md`

| Part | Points | Files | What you build |
|------|--------|-------|----------------|
| A | 40 | `analyzer.ml`, `environment.ml` | Generic analyzer functor + env helpers |
| B | 35 | `safety_checker.ml`, `safety_reporter.ml` | Div-by-zero detection + reporting |
| C | 25 | `analysis_report.md` | Written comparison of Sign vs Constant vs Interval |

### Build and test

```bash
# Build
dune build labs/lab4-abstract-interpreter/

# Run your tests (10 student-visible tests)
dune runtest labs/lab4-abstract-interpreter/starter/tests/
```

### Tips

- **Start with Part A** — it's the foundation for Part B
- If you completed Exercise 5, reuse its functor patterns here; if not, the lab README walks you through the structure
- Part C is a written report — run programs through all 3 domains and compare

---

## 11. Troubleshooting

### Build errors

| Error | Fix |
|-------|-----|
| `ocaml: command not found` | Run `eval $(opam env)` or add it to your `~/.bashrc`/`~/.zshrc` |
| `dune: command not found` | `opam install dune && eval $(opam env)` |
| `Error: Unbound module OUnit2` | `opam install ounit2` |
| `Error: Unbound module Shared_ast` | Run `dune build` from the repo root first (not from inside an exercise) |
| `Error: Unbound module Abstract_domains` | Same — `dune build` from the repo root |

### Test errors

| Symptom | Meaning |
|---------|---------|
| `EEEEEE` | Every test errors — functions still have `failwith "TODO"` |
| `..EEEE` | First 2 tests pass, rest still TODO |
| `..F.EE` | 3rd test **fails** (wrong answer) — read the error message for expected vs actual |
| `Fatal error: exception Failure("TODO: ...")` | The first function called is still a TODO — implement it first |

### Common OCaml mistakes

| Mistake | Fix |
|---------|-----|
| `match` not exhaustive | Add all cases (`Bot`, `Top`, and the concrete variants) |
| `Stack overflow` in while fixpoint | Make sure widening makes progress — the env must eventually stabilize |
| `type t is abstract` | You're using a module's internal type without opening it. Use `D.t` or `Env.t` explicitly |
| `Unbound value abstract_add` | Check if the function is in another module: `Sign_domain.abstract_add` or `D.join` |

### Running tests from the right directory

Always run `dune` commands from the **repository root**, not from inside an
exercise directory:

```bash
# CORRECT — from repo root:
dune runtest modules/module4-abstract-interpretation/exercises/sign-lattice/

# WRONG — from inside the exercise (will fail to find shared libraries):
cd modules/module4-abstract-interpretation/exercises/sign-lattice/
dune runtest   # ERROR: can't find shared_ast or abstract_domains
```

---

## Exercise Progression Cheat Sheet

```
Exercise 1: Sign Lattice              ← finite domain, no widening needed
     ↓
Exercise 2: Constant Propagation      ← flat lattice + expression evaluator
     ↓
Exercise 3: Galois Connections        ← (optional) formalize alpha/gamma
     ↓
Exercise 4: Interval Domain           ← infinite domain, widening is critical
     ↓
Exercise 5: Abstract Interpreter      ← (optional) functor ties it all together
     ↓
Lab 4: Integrated Analyzer            ← multi-domain + safety checking + reporting
```

**Minimum path:** Exercises 1 → 2 → 4 → Lab 4 (71 exercise tests + 10 lab tests)
**Full path:** All 5 exercises → Lab 4 (110 exercise tests + 10 lab tests)

Good luck!
