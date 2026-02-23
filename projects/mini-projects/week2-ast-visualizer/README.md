# Week 2 Mini-Project: AST Visualizer

## Overview

Build a tool that parses Python source code into an AST and renders it as a visual tree diagram, either as text output, an image, or an interactive web page.

**Duration:** 1 week (estimated 8-10 hours)
**Prerequisites:** Module 2 (Abstract Syntax Trees)

## Objectives

- Deepen understanding of AST structure by building a visualization tool
- Practice tree traversal algorithms in a real-world context
- Create a tool useful for studying and debugging code structure

## Requirements

### Core Requirements (70 points)

1. **AST Parsing (15 pts):** Parse any valid Python file into its AST using the `ast` module.

2. **Text Visualization (25 pts):** Generate a formatted text tree showing:
   - Node types and their hierarchy
   - Key attributes (variable names, operator types, literal values)
   - Line number annotations
   - Indentation reflecting depth

   Example output:
   ```
   Module
   └── FunctionDef: "add" (line 1)
       ├── arguments
       │   ├── arg: "a"
       │   └── arg: "b"
       └── Return (line 2)
           └── BinOp
               ├── Name: "a" (Load)
               ├── Add
               └── Name: "b" (Load)
   ```

3. **Filtering (15 pts):** Support filtering by:
   - Node type (e.g., show only function definitions)
   - Depth level (e.g., max depth 3)
   - Name pattern (e.g., functions matching `test_*`)

4. **CLI Interface (15 pts):** Accept a Python file path and output options via command line.

### Stretch Goals (30 points)

5. **Graphviz Output (10 pts):** Generate DOT format output for rendering with Graphviz.
6. **HTML Output (10 pts):** Generate an interactive collapsible tree in HTML/CSS/JS.
7. **Diff Mode (10 pts):** Compare ASTs of two files and highlight structural differences.

## Deliverables

1. `visualizer.py` -- Main entry point
2. `renderers/` -- Directory with text, graphviz, and/or HTML renderers
3. `filters.py` -- Node filtering logic
4. `test_visualizer.py` -- Tests for parsing, rendering, and filtering
5. `sample_code/` -- Example Python files for demo
6. `README.md` -- Usage instructions with example outputs

## Suggested Approach

1. Start by walking the AST and printing node types with indentation
2. Add box-drawing characters (└── ├── │) for tree structure
3. Add key attribute extraction for each node type
4. Implement filtering as a tree transformation step
5. Add alternative renderers (Graphviz DOT, HTML)

## Grading Rubric

| Criteria | Points |
|----------|--------|
| Correct AST parsing | 15 |
| Text tree visualization | 25 |
| Filtering support | 15 |
| CLI interface | 15 |
| Graphviz output | 10 |
| HTML interactive tree | 10 |
| Diff mode | 10 |
| **Total** | **100** |

## Resources

- Python `ast` module: [docs.python.org/3/library/ast.html](https://docs.python.org/3/library/ast.html)
- Graphviz DOT language: [graphviz.org/doc/info/lang.html](https://graphviz.org/doc/info/lang.html)
- Module 2 exercises on AST traversal
