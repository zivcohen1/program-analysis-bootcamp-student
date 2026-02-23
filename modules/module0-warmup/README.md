# Module 0: OCaml Warm-Up

## Overview

This module bridges the gap between Module 1 (JavaScript/ESLint) and Module 2 (OCaml AST manipulation). Students work through 5 guided exercises that introduce OCaml fundamentals while foreshadowing concepts from Modules 2-6.

**There are no OUnit2 tests.** Students complete exercises by filling in `(* EXERCISE: ... *)` markers, run with `dune exec`, and compare output against the STUDENT_README.

## Learning Objectives

By the end of this module, students will be able to:

1. Write OCaml functions using let bindings, type annotations, pattern matching, and recursion
2. Define and manipulate algebraic data types (ADTs) representing expression trees
3. Use List higher-order functions, records, StringMap, and StringSet
4. Build modules satisfying a signature and use functors to parameterize code
5. Read and extend ocamllex/Menhir grammar rules for a simple parser

## Prerequisites

- Basic programming experience (from Module 1)
- OCaml toolchain installed (opam, dune, menhir)

## Structure

| Exercise | Duration | Topic | Foreshadows |
|----------|----------|-------|-------------|
| 1. OCaml Basics | ~20 min | let, functions, tuples, Printf | Lexer helpers |
| 2. Types and Recursion | ~25 min | ADTs, pattern matching, Option | shared_ast expr type |
| 3. Collections and Records | ~25 min | List.map/fold, Map, Set, ref | Dataflow analysis |
| 4. Modules and Functors | ~25 min | Signatures, structs, functors | abstract_domains |
| 5. Calculator Parser | ~25 min | ocamllex, Menhir grammar | Lab 2 parser |

**Total: ~2 hours**

## Exercises

### 1. OCaml Basics -- "Token Classifier"

Functions: `square`, `is_empty`, `greet`, `is_digit`, `is_alpha`, `classify_char`, `format_token`, `make_token`, `format_pos`, `advance_pos`

```bash
dune exec modules/module0-warmup/exercises/ocaml-basics/starter/main.exe
```

### 2. Types and Recursion -- "Mini Expression Tree"

Defines `type op` and `type expr` (mini version of `Shared_ast.Ast_types.expr`).
Functions: `string_of_expr`, `count_nodes`, `depth`, `eval`, `substitute`, `vars_in`, `is_constant`, `simplify`

```bash
dune exec modules/module0-warmup/exercises/types-and-recursion/starter/main.exe
```

### 3. Collections and Records -- "Variable Tracker"

Uses `StringMap`, `StringSet`, and records. Mirrors Module 3's reaching-definitions data structures.
Functions: `double_all`, `keep_positive`, `sum`, `has_duplicates`, `make_assign`, `format_assign`, `increment_value`, `build_env`, `lookup_var`, `all_vars`, `assigned_vars`, `common_vars`, `make_counter`

```bash
dune exec modules/module0-warmup/exercises/collections-and-records/starter/main.exe
```

### 4. Modules and Functors -- "Analysis Domain Builder"

Defines `module type LATTICE`, `BoolLattice`, `ThreeValueLattice`, and `MakeEnv` functor.
Directly mirrors `lib/abstract_domains/`.

```bash
dune exec modules/module0-warmup/exercises/modules-and-functors/starter/main.exe
```

### 5. Calculator Parser

Lexer (provided), parser (partial TODO), main driver (TODO). Matches Lab 2's parser.mly structure.

```bash
dune exec modules/module0-warmup/exercises/calculator-parser/starter/main.exe
```

## Key Design Decisions

- **No tests** -- guided tutorials with expected output in STUDENT_README
- **Program-analysis themed** -- every exercise foreshadows a real Module 2-6 concept
- **Self-contained** -- no dependencies on shared_ast or other libs
- **Exercise 5 defines expr in parser.mly** -- avoids needing a separate library
