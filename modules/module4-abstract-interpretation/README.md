# Module 4: Abstract Interpretation

## Overview

This module introduces abstract interpretation -- a framework for computing sound approximations of program behavior. Building on Module 3's dataflow analysis, you'll replace "sets of facts" with "abstract values" (signs, constants, intervals) and learn how Galois connections formalize the link between concrete and abstract semantics. The capstone is an abstract interpreter that detects division-by-zero errors before the program runs.

## Learning Objectives

By the end of this module, you will be able to:

1. **Explain** abstract interpretation as a sound over-approximation of concrete semantics
2. **Implement** abstract domains (Sign, Constant, Interval) satisfying the `ABSTRACT_DOMAIN` signature
3. **Formalize** Galois connections and verify soundness properties (alpha/gamma adjunction)
4. **Apply** widening operators to guarantee termination on infinite-height lattices
5. **Build** an abstract interpreter parameterized by domain (functor-based)
6. **Compare** domains along precision, cost, and termination axes

## Prerequisites

- Module 3: Static Analysis (lattices, transfer functions, fixpoint computation)
- Set theory: union, intersection, partial orders
- OCaml: functors, module types, pattern matching

## Structure

| Component | Duration | Description |
|-----------|----------|-------------|
| Part 1 | 30 min | Motivation, Galois connections, soundness |
| Part 2 | 25 min | Sign domain: lattice + abstract arithmetic |
| Part 3 | 15 min | Constant propagation: flat lattice |
| Part 4 | 30 min | Interval domain: infinite height + widening |
| Part 5 | 15 min | Synthesis and practical applications |
| Exercises | 120 min | 5 incremental exercises |

## Materials

### Slides and Lectures
- [Slide Deck](slides/abstract-interpretation.md) (Reveal.js format)

### Tools Required
- OCaml 4.14+ with Dune 3.0+
- OUnit2 (`opam install ounit2`)

## Exercises

Complete in order -- each builds on the previous:

### 1. Sign Lattice (~20 min)
**Objective:** Implement a finite abstract domain (Bot, Neg, Zero, Pos, Top) with lattice operations and abstract arithmetic.
**Difficulty:** Introductory

### 2. Constant Propagation (~20 min)
**Objective:** Implement the flat constant lattice and an expression evaluator over abstract constants.
**Difficulty:** Intermediate

### 3. Galois Connections (~25 min)
**Objective:** Formalize alpha/gamma for the sign domain, verify adjunction and monotonicity properties.
**Difficulty:** Theory + Code

### 4. Interval Domain (~30 min)
**Objective:** Implement an infinite-height domain with widening for termination.
**Difficulty:** Advanced

### 5. Abstract Interpreter (~25 min)
**Objective:** Wire an abstract domain to statement-level transfer functions via a functor.
**Difficulty:** Integration

## Key Concepts

### Abstract Domains
An abstract domain approximates the set of concrete values a variable can take. The `ABSTRACT_DOMAIN` signature extends Module 3's `LATTICE` with `leq` (partial order) and `widen` (termination guarantee).

### Galois Connections
The formal bridge between concrete and abstract: alpha (abstraction) maps concrete sets to abstract values, gamma (concretization) maps abstract values back to concrete sets. The adjunction property guarantees soundness.

### Soundness
Abstract interpretation is sound: if the analysis says "safe", the program truly is safe. False positives (spurious warnings) are possible; false negatives (missed bugs) are not.

### Widening
For domains with infinite ascending chains (like intervals), widening accelerates convergence by jumping bounds to infinity when they grow. This trades precision for guaranteed termination.

## Next Steps

Lab 4 integrates everything from this module into a multi-domain abstract interpreter with safety checking and domain comparison.
