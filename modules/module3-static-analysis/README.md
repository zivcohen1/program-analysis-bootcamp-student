# Module 3: Static Analysis Fundamentals

## Overview

This module introduces the mathematical foundations of static analysis. You'll learn to construct control flow graphs (CFGs), apply the dataflow analysis framework, and implement classic analyses like reaching definitions and live variables. These techniques are the core of tools like SonarQube, Pylint, and compiler optimizers.

## Learning Objectives

By the end of this module, you will be able to:

1. **Construct** control flow graphs from source code, identifying basic blocks and control flow edges
2. **Apply** the dataflow analysis framework using lattices, transfer functions, and fixpoint computation
3. **Implement** reaching definitions analysis with gen/kill sets and iterative fixpoint
4. **Compare** forward and backward dataflow analyses on the same program
5. **Evaluate** interprocedural analysis challenges and scalability trade-offs
6. **Design** simple static analysis tools combining CFGs with dataflow analysis

## Prerequisites

- Module 2: ASTs (traversal algorithms, symbol tables)
- Set theory: union, intersection, difference
- Basic graph theory: nodes, edges, directed graphs, paths

## Structure

| Component | Duration | Description |
|-----------|----------|-------------|
| Lesson 1 | 45 min | Control Flow Graphs |
| Lesson 2 | 45 min | Dataflow Analysis Framework |
| Lesson 3 | 45 min | Reaching Definitions |
| Lesson 4 | 30 min | Live Variables & Available Expressions |
| Lesson 5 | 30 min | Interprocedural Analysis |
| Exercises | 45 min | 5 incremental exercises |

## Materials

### Slides and Lectures
- [Slide Deck](slides/static-analysis.md) (Reveal.js format)
- [Detailed Lecture Notes](lecture-notes/detailed-notes.md)

### Tools Required
- Python 3.8+
- pytest (`pip install pytest`)

## Exercises

Exercises build incrementally -- complete them in order:

### 1. CFG Construction
**Objective:** Build control flow graphs for 4 code patterns
**Duration:** 15 minutes | **Difficulty:** Intermediate

### 2. Dataflow Framework
**Objective:** Implement abstract lattice and iterative fixpoint solver
**Duration:** 15 minutes | **Difficulty:** Intermediate

### 3. Reaching Definitions
**Objective:** Manual iteration + implementation using the framework
**Duration:** 20 minutes | **Difficulty:** Intermediate

### 4. Live Variables
**Objective:** Backward analysis implementation, comparison with reaching defs
**Duration:** 15 minutes | **Difficulty:** Intermediate

### 5. Interprocedural Analysis
**Objective:** Call graph construction and context sensitivity analysis
**Duration:** 15 minutes | **Difficulty:** Advanced

## Key Concepts

### Control Flow Graphs
Directed graphs where nodes = basic blocks, edges = possible control flow. Every if/while/for creates branching edges.

### Dataflow Analysis Framework
- **Lattice:** Organizes the information we track (powerset of definitions, variables, etc.)
- **Transfer Functions:** Model how each statement changes the information
- **Fixpoint:** Iterate until no more changes occur

### Reaching Definitions
Forward, may analysis. Transfer function: `OUT = (IN - kill) ∪ gen`
At each merge point: `IN = ∪(OUT of predecessors)`

### Live Variables
Backward, may analysis. Transfer function: `IN = (OUT - def) ∪ use`
At each merge point: `OUT = ∪(IN of successors)`

## Next Steps

The lab (Lab 3: Static Checker) integrates everything from this module into a complete static analysis tool with configurable rules and reporting.
