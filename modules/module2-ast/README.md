# Module 2: Code Representation and Abstract Syntax Trees

## Overview

This module teaches how programs are represented internally using Abstract Syntax Trees (ASTs). You'll learn to build, traverse, and transform tree representations of code -- the foundational data structure for all program analysis tools.

## Learning Objectives

By the end of this module, you will be able to:

1. **Analyze** source code and construct corresponding AST representations
2. **Design** and implement traversal algorithms (DFS, BFS, Visitor pattern)
3. **Create** symbol tables to track variable declarations and resolve identifiers across scopes
4. **Evaluate** different code representations and select appropriate structures for analysis tasks
5. **Apply** AST manipulation techniques to transform and optimize code programmatically
6. **Construct** a simple parser that converts expressions into AST form

## Prerequisites

- Module 1: Foundations of Program Analysis
- Basic understanding of tree data structures
- Python 3.8+ (all exercises use Python)

## Structure

| Component | Duration | Description |
|-----------|----------|-------------|
| Lesson 1 | 45 min | AST Architecture: Nodes, Types, Hierarchies |
| Lesson 2 | 45 min | AST Traversal Algorithms |
| Lesson 3 | 45 min | Symbol Tables and Scoping |
| Lesson 4 | 45 min | AST Transformations |
| Exercises | 60 min | 4 hands-on exercises |

## Materials

### Slides and Lectures
- [Slide Deck](slides/ast.md) (Reveal.js format)
- [Detailed Lecture Notes](lecture-notes/detailed-notes.md)

### Tools Required
- Python 3.8+ with `ast` module (built-in)
- pytest (`pip install pytest`)

## Exercises

### Exercise 1: AST Structure Mapping
**Objective:** Visualize ASTs using Python's `ast` module
**Duration:** 15 minutes | **Difficulty:** Beginner

### Exercise 2: Traversal Algorithms
**Objective:** Implement pre-order, post-order, and BFS traversals + Visitor pattern
**Duration:** 20 minutes | **Difficulty:** Intermediate

### Exercise 3: Symbol Table
**Objective:** Build a scoped symbol table with nested scope resolution
**Duration:** 15 minutes | **Difficulty:** Intermediate

### Exercise 4: AST Transformations
**Objective:** Implement constant folding, variable renaming, and dead code elimination
**Duration:** 20 minutes | **Difficulty:** Intermediate

## Key Concepts

### Abstract Syntax Trees
Trees that represent the hierarchical structure of source code, abstracting away syntactic details (parentheses, semicolons) to focus on semantic meaning.

### Traversal Orders
- **Pre-order:** Visit node, then children (top-down analysis)
- **Post-order:** Visit children, then node (bottom-up evaluation)
- **BFS:** Visit all nodes at depth d before depth d+1

### Visitor Pattern
Separates traversal logic from analysis logic. Add new analyses without modifying AST node classes.

## Next Steps

Module 3 builds on ASTs to construct Control Flow Graphs (CFGs) and implement dataflow analysis algorithms. The traversal and symbol table skills from this module are essential prerequisites.
