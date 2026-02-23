# Program Analysis Bootcamp

> Learn to build automated tools for understanding, analyzing, and improving code quality.

## Course Overview

This intensive bootcamp teaches practical program analysis techniques used in modern software development. You'll build static analyzers, AST-based tools, abstract interpreters, taint analyzers, and a fully integrated analysis pipeline — all in OCaml.

**Duration:** 6 weeks (Modules 1–6)
**Language:** OCaml (Module 1 uses JavaScript for introduction)
**Format:** Theory + Hands-on Exercises + Labs
**Total Tests:** ~510 automated tests across 24 exercises and 6 labs

## Quick Start

### Prerequisites

- OCaml 5.1.0+ and OPAM
- Dune 3.x build system
- Node.js 16+ (Module 1 only)
- Code editor (VS Code with OCaml Platform extension recommended)

### Setup

```bash
# Clone the repository
git clone https://github.com/weihaoqu/program-analysis-bootcamp-student.git
cd program-analysis-bootcamp-student

# Install OCaml dependencies
opam install ounit2 menhir

# Verify the build
dune build
```

### Running Tests

```bash
# Run tests for a specific exercise
dune runtest modules/module2-ast/exercises/traversal-algorithms/

# Run tests for a specific lab
dune runtest labs/lab2-ast-parser/

# Run all tests
dune runtest
```

### Test Output Patterns

| Output | Meaning |
|--------|---------|
| `Fatal error: exception Failure("TODO")` | A TODO stub was hit during initialization — implement that function first |
| `EEEEEE` | All tests error (many TODOs remain) |
| `..EEEE` | First 2 pass, rest still need work |
| `......` | All tests pass! |

## Learning Progression

```
Module 0: OCaml warm-up            (types, pattern matching, functors)
    │
Module 1: Why analyze code?        (static vs dynamic analysis)
    │
Module 2: How to represent code?   (abstract syntax trees)
    │
Module 3: How to find patterns?    (control flow graphs + dataflow)
    │
Module 4: How to approximate?      (abstract interpretation + widening)
    │
Module 5: How to find vulns?       (taint analysis + information flow)
    │
Module 6: How to build tools?      (composition + reporting pipeline)
```

## Modules

| Module | Topic | Exercises | Tests | Student Guide |
|--------|-------|-----------|-------|---------------|
| [0](modules/module0-warmup/) | OCaml Warm-Up | 5 | — (guided) | [Guide](modules/module0-warmup/STUDENT_README.md) |
| [1](modules/module1-foundations/) | Foundations of Program Analysis | 2 | self-check | [Guide](modules/module1-foundations/STUDENT_README.md) |
| [2](modules/module2-ast/) | Code Representation & ASTs | 4 | 63 | [Guide](modules/module2-ast/STUDENT_README.md) |
| [3](modules/module3-static-analysis/) | Static Analysis Fundamentals | 5 | 72 | [Guide](modules/module3-static-analysis/STUDENT_README.md) |
| [4](modules/module4-abstract-interpretation/) | Abstract Interpretation | 5 (3 req + 2 opt) | 110 | [Guide](modules/module4-abstract-interpretation/STUDENT_README.md) |
| [5](modules/module5-security-analysis/) | Security & Taint Analysis | 5 | 95 | [Guide](modules/module5-security-analysis/STUDENT_README.md) |
| [6](modules/module6-tools-integration/) | Tools Integration (Capstone) | 5 | 96 | [Guide](modules/module6-tools-integration/STUDENT_README.md) |

## Labs

| Lab | Topic | Tests |
|-----|-------|-------|
| [1](labs/lab1-tool-setup/) | Tool Setup & Verification | — |
| [2](labs/lab2-ast-parser/) | AST Parser & Analyzer | 9 |
| [3](labs/lab3-static-checker/) | Static Analysis Checker | 5 |
| [4](labs/lab4-abstract-interpreter/) | Abstract Interpreter | 10 |
| [5](labs/lab5-security-analyzer/) | Security Analyzer | 10 |
| [6](labs/lab6-integrated-analyzer/) | Integrated Analyzer | 10 |

## Module Details

### Module 1 — Foundations of Program Analysis

Introduction to static vs dynamic analysis using JavaScript/ESLint. No OCaml yet.

- **calculator-bugs/** — Find 8 bugs using ESLint and test suites
- **analysis-comparison/** — Classify 15 code snippets by analysis technique

### Module 2 — Code Representation & ASTs

Build and manipulate abstract syntax trees using the shared AST library.

- **ast-structure-mapping/** — Visualize AST structures (no tests, executable output)
- **traversal-algorithms/** (27 tests) — Pre/post-order, BFS, visitor pattern
- **symbol-table/** (6 tests) — Scoped symbol table with variable shadowing
- **ast-transformations/** (30 tests) — Constant folding, renaming, dead code elimination

### Module 3 — Static Analysis Fundamentals

Control flow graphs, dataflow analysis frameworks, and fixpoint iteration.

- **cfg-construction/** (14 tests) — Build control flow graphs from ASTs
- **dataflow-framework/** (11 tests) — Powerset lattice and generic solver
- **reaching-definitions/** (15 tests) — Forward may-analysis
- **live-variables/** (14 tests) — Backward may-analysis
- **interprocedural-analysis/** (18 tests) — Call graphs and recursion detection

### Module 4 — Abstract Interpretation

Abstract domains, Galois connections, and widening for termination.

- **sign-lattice/** (20 tests) — 5-element sign domain (Bot/Neg/Zero/Pos/Top)
- **constant-propagation/** (23 tests) — Flat constant lattice with evaluator
- **interval-domain/** (28 tests) — Infinite-height domain with widening
- **galois-connections/** (16 tests) — Alpha/gamma formalization *(optional)*
- **abstract-interpreter/** (13 tests) — Generic functor-based interpreter *(optional)*

### Module 5 — Security & Taint Analysis

Taint tracking, information flow, and OWASP vulnerability detection.

- **taint-lattice/** (18 tests) — 4-element taint domain
- **security-config/** (17 tests) — Sources, sinks, and sanitizers
- **taint-propagation/** (22 tests) — Forward taint analysis
- **information-flow/** (20 tests) — Implicit flow tracking with pc_taint
- **vulnerability-detection/** (18 tests) — Config-driven OWASP pattern detection

### Module 6 — Tools Integration (Capstone)

Compose everything into a production-style analysis pipeline.

- **analysis-finding/** (20 tests) — Unified finding types, filtering, deduplication
- **dead-code-detector/** (20 tests) — AST-level dead code detection
- **multi-pass-analyzer/** (20 tests) — Compose sign + taint passes
- **configurable-pipeline/** (18 tests) — Config-driven pass selection
- **analysis-reporter/** (18 tests) — Text/JSON output with summary tables

## Shared Libraries

The `lib/` directory provides shared infrastructure used across modules:

| Library | Access Pattern | Description |
|---------|---------------|-------------|
| `shared_ast` | `Shared_ast.Ast_types` | Core AST types (`expr`, `stmt`, `func_def`, `program`) |
| `abstract_domains` | `Abstract_domains.Abstract_domain` | `ABSTRACT_DOMAIN` module type + `MakeEnv` functor |
| `taint_domains` | `Taint_domains.Taint_types` | Taint lattice, config, vulnerability types |

> **Note:** Dune 3.0 wraps libraries by default. Use `Shared_ast.Ast_types`, not bare `Ast_types`.

## How Exercises Work

Each exercise follows the same structure:

```
exercises/exercise-name/
├── starter/           # Your working directory
│   ├── dune
│   ├── *.ml           # Files with failwith "TODO" stubs
│   └── *.mli          # Interface files (do not modify)
└── tests/
    ├── dune
    └── test_*.ml      # Automated tests
```

1. Read the exercise README and the STUDENT_README for your module
2. Open the `starter/*.ml` files and find the `TODO` stubs
3. Implement each function, replacing `failwith "TODO: ..."` with your code
4. Run `dune runtest` for the exercise to check your work
5. All dots (`......`) means you're done!

## Support

- **Issues:** Use GitHub Issues for technical problems
- **Discussions:** Course Slack/Discord channel
- **Office Hours:** See [syllabus](SYLLABUS.md) for schedule
