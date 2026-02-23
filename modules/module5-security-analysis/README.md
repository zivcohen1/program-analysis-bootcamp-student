# Module 5: Security Analysis

## Overview

This module applies the abstract interpretation framework from Module 4 to **security properties**. Instead of tracking numeric information (signs, constants, intervals), you'll track **taint** -- whether data originates from an untrusted source and flows to a security-sensitive sink. The same `ABSTRACT_DOMAIN` + `MakeEnv` + functor infrastructure powers a security analyzer that detects SQL injection, XSS, command injection, and other OWASP Top 10 vulnerabilities.

## Learning Objectives

By the end of this module, you will be able to:

1. **Implement** a taint lattice satisfying the `ABSTRACT_DOMAIN` signature
2. **Define** security configurations mapping sources, sinks, and sanitizers
3. **Build** a forward taint propagation engine using abstract transfer functions
4. **Track** implicit information flows via program-counter taint
5. **Detect** OWASP vulnerability patterns (SQLi, XSS, command injection, path traversal)
6. **Evaluate** the precision and limitations of taint analysis

## Prerequisites

- Module 3: Static Analysis (lattices, transfer functions, fixpoint computation)
- Module 4: Abstract Interpretation (ABSTRACT_DOMAIN, MakeEnv, eval_expr/transfer_stmt)
- OCaml: functors, module types, pattern matching

## Structure

| Component | Duration | Description |
|-----------|----------|-------------|
| Part 1 | 20 min | Motivation: from numeric to security properties |
| Part 2 | 25 min | The taint lattice and propagation rules |
| Part 3 | 20 min | Security configuration: sources, sinks, sanitizers |
| Part 4 | 25 min | Information flow: explicit and implicit |
| Part 5 | 25 min | Vulnerability detection and OWASP patterns |
| Exercises | 120 min | 5 incremental exercises |

## Materials

### Slides and Lectures
- [Slide Deck](slides/security-analysis.md) (Reveal.js format)

### Tools Required
- OCaml 4.14+ with Dune 3.0+
- OUnit2 (`opam install ounit2`)

## Exercises

Complete in any order -- each is self-contained:

### 1. Taint Lattice (~20 min)
**Objective:** Implement the four-element taint lattice (Bot, Untainted, Tainted, Top) with lattice operations and taint-specific helpers.
**Difficulty:** Introductory

### 2. Security Configuration (~20 min)
**Objective:** Define and query security configurations -- sources, sinks, and sanitizers.
**Difficulty:** Introductory

### 3. Taint Propagation (~25 min)
**Objective:** Build a forward taint propagation engine using abstract transfer functions.
**Difficulty:** Intermediate

### 4. Information Flow (~25 min)
**Objective:** Track implicit information flows via program-counter taint (`pc_taint`).
**Difficulty:** Intermediate

### 5. Vulnerability Detection (~30 min)
**Objective:** Combine taint analysis with security configuration to detect OWASP vulnerability patterns.
**Difficulty:** Integration

## Key Concepts

### Taint Analysis
Taint analysis tracks whether data originates from an untrusted source (tainted) and propagates through computations until it reaches a security-sensitive sink. If tainted data reaches a sink without sanitization, a vulnerability is reported.

### Sources, Sinks, Sanitizers
- **Sources** introduce tainted data: `get_param()`, `read_cookie()`, `read_input()`
- **Sinks** consume data that must be clean: `exec_query()`, `exec_cmd()`, `send_response()`
- **Sanitizers** clean specific taint types: `escape_sql()` prevents SQL injection but not XSS

### Information Flow
- **Explicit flow**: direct data dependency (`x = tainted_y`)
- **Implicit flow**: control dependency (`if (secret) then x = 1`)

### Soundness
Like numeric abstract interpretation, taint analysis is sound: if no vulnerability is reported, there truly is no taint flow to a sink. False positives (spurious warnings) are possible; false negatives (missed vulnerabilities) are not.

## Next Steps

Lab 5 integrates everything from this module into a complete security analyzer that processes multi-function programs, detects vulnerabilities, and produces formatted reports.
