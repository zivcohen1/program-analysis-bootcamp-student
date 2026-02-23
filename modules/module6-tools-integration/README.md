# Module 6: Tools Implementation & Integration

## Overview

This capstone module composes techniques from Modules 2-5 into a complete, configurable analysis tool. You'll learn to build modular, multi-pass analyzers with unified finding types, configurable pipelines, and structured reporting — the same architecture used by production tools like Semgrep, CodeQL, and SonarQube.

## Learning Objectives

By the end of this module, you will be able to:

1. **Define** unified finding types that standardize outputs across analysis passes
2. **Implement** dead code detection as a purely AST-level analysis
3. **Build** analysis passes using a record-based, composable architecture
4. **Compose** multiple analysis passes and merge results
5. **Design** configurable pipelines that select passes and filter findings
6. **Generate** structured reports in text and JSON formats

## Prerequisites

- Module 2: AST (types, traversal, pattern matching)
- Module 3: Static Analysis (lattices, transfer functions, fixpoint computation)
- Module 4: Abstract Interpretation (ABSTRACT_DOMAIN, MakeEnv, sign domain)
- Module 5: Security Analysis (taint domain, source/sink/sanitizer)

## Structure

| Component | Duration | Description |
|-----------|----------|-------------|
| Part 1 | 15 min | From individual analyses to integrated tools |
| Part 2 | 20 min | Unified finding types and operations |
| Part 3 | 20 min | Analysis pass architecture and dead code detection |
| Part 4 | 25 min | Multi-pass composition and merging |
| Part 5 | 20 min | Configurable pipelines and filtering |
| Part 6 | 20 min | Structured reporting (text, JSON, summary) |
| Exercises | 120 min | 5 incremental exercises |

## Materials

### Slides

- [Slide Deck](slides/tools-integration.html) (28 slides, self-contained HTML)
- [Slide Outline](slides/tools-integration.md)

### Tools Required

- OCaml 4.14+ with Dune 3.0+
- OUnit2 (`opam install ounit2`)

## Exercises

Complete in order — each builds conceptually on the previous:

### 1. Analysis Finding (~20 min) — Introductory

Define a unified finding type and implement operations for sorting, filtering, deduplication, and formatting. Self-contained, no external dependencies.

### 2. Dead Code Detector (~20 min) — Introductory

Implement purely AST-level analysis detecting unreachable code after return, unused variables, and unused parameters.

### 3. Multi-Pass Analyzer (~25 min) — Intermediate

Build analysis passes using the record-based pattern (safety + taint) and compose results across passes.

### 4. Configurable Pipeline (~25 min) — Intermediate

Design a configuration-driven pipeline that selects passes and filters results by severity, category, and count.

### 5. Analysis Reporter (~25 min) — Integration

Generate structured text and JSON reports with statistics from analysis findings.

## Key Concepts

### Unified Finding Types

All analysis passes produce findings with the same record type: severity, category, pass name, location, message, suggestion. This enables sorting, filtering, and deduplication across passes.

### Record-Based Analysis Passes

```ocaml
type analysis_pass = {
  name : string;
  category : category;
  run : program -> finding list;
}
```

Each pass is a value with a uniform interface, enabling composition.

### Pipeline Architecture

```
Config → build_pipeline → [passes]
Program → run_all_passes → [findings] → apply_filters → [filtered] → report
```

### Dead Code Detection

Purely AST-level (no abstract domains): collect used/assigned variables, compare sets, detect unreachable code after return.

### Multi-Pass Composition

Independent passes analyze the same AST, results are merged and sorted. Each pass can use different domains (sign, taint) or no domain at all (dead code).
