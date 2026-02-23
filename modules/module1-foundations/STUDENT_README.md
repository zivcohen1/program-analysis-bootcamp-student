# Module 1: Foundations of Program Analysis -- Student Guide

Welcome to Module 1! This module introduces the core ideas behind program
analysis: what it is, why it matters, and the fundamental distinction between
static and dynamic approaches. You will explore these concepts hands-on by
hunting bugs in a JavaScript calculator and classifying code snippets by
analysis technique.

```
                    Program Analysis
                          |
          +───────────────+───────────────+
          |                               |
    Static Analysis                 Dynamic Analysis
    (examine code                   (observe behavior
     without running)                during execution)
          |                               |
    +─────+─────+                   +─────+─────+
    |           |                   |           |
  Linting   Type       Testing   Profiling
  Rules     Checking   Suites    / Tracing
          |                               |
          v                               v
    Finds structural              Finds runtime
    issues (all paths,            issues (only
    may false-alarm)              tested paths,
                                  precise results)
```

**Exercises:** 2 (self-checked, no automated grading)
**Lab:** Lab 1 -- Tool Setup (environment verification checklist)
**Estimated time:** ~45 minutes for exercises, ~15 minutes for lab

> **Important:** This module uses **JavaScript / Node.js**, not OCaml. There
> are no `dune` builds, no OUnit tests, and no `.ml` files. Starting in
> Module 2, the bootcamp switches to OCaml for the remainder of the course.

---

## Table of Contents

1. [Environment Setup](#1-environment-setup)
2. [How This Module Works](#2-how-this-module-works)
3. [Exercise 1: Calculator Bugs](#3-exercise-1-calculator-bugs)
4. [Exercise 2: Analysis Comparison](#4-exercise-2-analysis-comparison)
5. [Lab 1: Tool Setup](#5-lab-1-tool-setup)
6. [Troubleshooting](#6-troubleshooting)
7. [What's Next](#7-whats-next)

---

## 1. Environment Setup

### For this module (Node.js)

You need **Node.js 16+** and **npm** (bundled with Node.js).

**macOS:**

```bash
# Install via Homebrew
brew install node

# Verify
node --version     # should print v16.x.x or higher
npm --version      # should print 8.x.x or higher
```

**Ubuntu / Debian (or WSL on Windows):**

```bash
# Install Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node --version
npm --version
```

**Windows (native):**

Download the LTS installer from [nodejs.org](https://nodejs.org/) or use
WSL2 (recommended) with the Ubuntu instructions above.

### For later modules (OCaml)

Modules 2--5 and Labs 2--5 use **OCaml**, **dune**, **ounit2**, and
**menhir**. You do not need these for Module 1, but it is a good idea to
install them now so you are ready.

See the full installation guide:
[`resources/tools/installation-guides/ocaml-setup.md`](../../resources/tools/installation-guides/ocaml-setup.md)

Quick summary:

```bash
# macOS
brew install opam
opam init -y && eval $(opam env)
opam switch create 5.1.0 && eval $(opam env)
opam install dune ounit2 menhir -y
```

---

## 2. How This Module Works

Module 1 is **conceptual and self-checked**. There is no automated test
runner that grades your work. Instead:

| What you do | How you check |
|-------------|---------------|
| Fix bugs in `calculator.js` | Run ESLint + the test suite; all issues should disappear |
| Fill out `analysis-report-template.md` | Compare your findings against the bugs listed in the source comments |
| Classify 15 code snippets | Review your answers against the lecture notes and slides |

**No dune. No OUnit.** Just Node.js, ESLint, and your own reasoning.

### Module materials

| Resource | Location |
|----------|----------|
| Slide deck (Reveal.js) | `slides/foundations.md` |
| Detailed lecture notes | `lecture-notes/detailed-notes.md` |
| Readings & references | `resources/readings.md` |

Read through the slides and/or lecture notes before starting the exercises.

---

## 3. Exercise 1: Calculator Bugs

**Goal:** Find 8 bugs in a JavaScript calculator using static analysis
(ESLint) and dynamic analysis (a test suite), then compare what each
approach catches.

**Time:** ~30 minutes

**Files:**

| File | Purpose |
|------|---------|
| `exercises/calculator-bugs/starter/calculator.js` | The buggy calculator -- **edit this** |
| `exercises/calculator-bugs/starter/test-calculator.js` | Test suite -- **read only** |
| `exercises/calculator-bugs/starter/.eslintrc.json` | ESLint configuration -- **read only** |
| `exercises/calculator-bugs/starter/analysis-report-template.md` | Your report -- **fill this out** |
| `exercises/calculator-bugs/starter/package.json` | npm project -- **do not edit** |

### Step-by-step

**Step 1: Install dependencies**

```bash
cd modules/module1-foundations/exercises/calculator-bugs/starter
npm install
```

This creates a `node_modules/` directory with ESLint.

**Step 2: Run static analysis (ESLint)**

```bash
npx eslint calculator.js
```

ESLint examines the source code **without executing it** and reports issues
based on the rules configured in `.eslintrc.json`. Record every finding
(line number, rule name, description) in Part 1 of the analysis report.

The enabled ESLint rules are:

| Rule | What it catches |
|------|-----------------|
| `no-undef` | References to undefined variables |
| `no-unreachable` | Code after `return` statements |
| `no-fallthrough` | Missing `break` in `switch` cases |
| `eqeqeq` | `==` instead of `===` (type coercion risk) |
| `no-unused-vars` | Declared but never-used variables |
| `no-constant-condition` | `if (true)` and similar always-true/false guards |

**Step 3: Run dynamic analysis (test suite)**

```bash
node test-calculator.js
```

The test suite runs 16 tests that exercise the calculator functions at
runtime. Some tests will PASS; others will FAIL. Record each failure (test
name, error message, root cause) in Part 2 of the analysis report.

**Step 4: Compare the two approaches**

Fill out Parts 3 and 4 of `analysis-report-template.md`:

- Which bugs did **only** static analysis catch?
- Which bugs did **only** dynamic analysis catch?
- Which bugs were found by **both** approaches?
- Why can't either approach catch everything on its own?

**Step 5: Fix all 8 bugs**

Go back to `calculator.js` and fix every bug. After fixing, re-run both
tools to confirm:

```bash
npx eslint calculator.js        # should report 0 errors, 0 warnings
node test-calculator.js          # all tests should PASS
```

### The 8 bugs at a glance

The source comments label each bug (Bug 1 through Bug 8). Do not read
these comments until you have tried to find them with the tools first.

```
Bug #   Function      Category
─────   ──────────    ────────────────────────
  1     add()         Undefined variable
  2     subtract()    Unreachable code
  3     calculate()   Switch fallthrough
  4     divide()      Division by zero
  5     factorial()   Infinite recursion
  6     multiply()    Type coercion (== vs ===)
  7     power()       Unused variable
  8     absolute()    Constant condition
```

### Self-check

When you are done:

- ESLint reports **no issues**
- The test suite reports **all tests passed**
- Your analysis report has all four parts filled out with concrete findings

---

## 4. Exercise 2: Analysis Comparison

**Goal:** Classify 15 code snippets (in Python, JavaScript, Java, and C)
by what kind of issue they contain and which analysis technique would
detect it.

**Time:** ~15 minutes

**Files:**

| File | Purpose |
|------|---------|
| `exercises/analysis-comparison/starter/code-samples.md` | 15 code snippets -- **read this** |
| `exercises/analysis-comparison/starter/classification-template.md` | Your answers -- **fill this out** |

### What to do

1. Open `code-samples.md` and read each snippet carefully.

2. For every snippet, fill in one row of the table in
   `classification-template.md`:

   | Column | What to write |
   |--------|---------------|
   | Issue Description | What is wrong or risky in this code |
   | Objective | **Correctness**, **Security**, or **Performance** |
   | Detection Method | **Static**, **Dynamic**, or **Both** |
   | Explanation | 1--2 sentences on why you chose that classification |

3. Answer the summary questions at the bottom of the template.

### Tips

- **SQL injection** and **command injection** are Security issues.
- **Unreachable code** and **off-by-one errors** are Correctness issues.
- **Unbounded caches** and **redundant loops** are Performance issues.
- Some issues can be detected statically (by examining source code), some
  require dynamic execution, and some can be found either way.

### Self-check

- All 15 rows should be filled in.
- The summary counts should add up to 15 total.
- Review your classifications against the lecture notes on static vs
  dynamic analysis to see if your reasoning holds up.

---

## 5. Lab 1: Tool Setup

Lab 1 is an environment verification checklist. It ensures your machine
has everything needed for the full bootcamp (not just Module 1).

**Location:** `labs/lab1-tool-setup/README.md`

**What to do:**

1. Open the checklist in `labs/lab1-tool-setup/README.md`.
2. Work through each item, installing anything that is missing.
3. Check off each item as you verify it.

Key items to verify:

| Tool | Needed for |
|------|------------|
| Node.js 16+ | Module 1 exercises |
| Git | All modules |
| OCaml / opam / dune / ounit2 | Modules 2--5, Labs 2--5 |
| menhir | Lab 2 (parser generator) |
| Code editor (VS Code recommended) | All modules |

If any check fails, refer to the installation guides in
`resources/tools/installation-guides/`.

---

## 6. Troubleshooting

### Node.js / npm issues

| Error | Fix |
|-------|-----|
| `node: command not found` | Install Node.js from [nodejs.org](https://nodejs.org/) or via your package manager |
| `npm: command not found` | npm ships with Node.js -- reinstall Node.js |
| `npx eslint: command not found` | Run `npm install` first (inside the `starter/` directory) to install ESLint locally |
| `Cannot find module './calculator'` | You are running `node test-calculator.js` from the wrong directory. `cd` into `exercises/calculator-bugs/starter/` first |

### ESLint issues

| Symptom | Fix |
|---------|-----|
| ESLint reports 0 issues on the buggy file | Make sure `.eslintrc.json` exists in the same directory and has the rules enabled. It should have been provided with the starter. |
| ESLint crashes with a parse error | Check that `calculator.js` has valid JavaScript syntax. If you introduced a syntax error while editing, undo and try again. |
| ESLint shows different rules than expected | Ensure you are running `npx eslint` (which uses the local install), not a globally installed version with different configuration. |

### Test suite issues

| Symptom | Fix |
|---------|-----|
| `RangeError: Maximum call stack size exceeded` | This is expected before you fix Bug 5 (factorial infinite recursion). The test catches it. |
| Tests pass but ESLint still warns | Some bugs are only visible to one approach. Fix the code so both tools are satisfied. |
| `SyntaxError: Unexpected token` | You introduced a syntax error in `calculator.js`. Check your recent edits. |

---

## 7. What's Next

After completing Module 1, you understand **why** program analysis matters
and the fundamental tradeoffs between static and dynamic approaches.

**Module 2: AST Representation and Traversal** shifts to **OCaml** and
introduces Abstract Syntax Trees (ASTs) -- the data structure that all
analysis tools operate on. You will build, traverse, and transform tree
representations of programs.

```
Module 1                       Module 2
(Foundations)                  (AST)
                                 |
  "What is program    -->   "How do we represent
   analysis?"                programs internally?"
                                 |
  JavaScript / Node.js       OCaml / dune / OUnit
  Conceptual exercises       Automated test suites
```

**Prep for Module 2:**

- Make sure OCaml, opam, dune, and ounit2 are installed (see
  [Lab 1](#5-lab-1-tool-setup) and the
  [OCaml setup guide](../../resources/tools/installation-guides/ocaml-setup.md)).
- Review basic tree data structures (nodes, children, traversal orders).
- From the repo root, run `dune build` to confirm everything compiles.

Good luck!
