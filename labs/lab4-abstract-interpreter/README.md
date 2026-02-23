# Lab 4: Abstract Interpreter

## Overview

In this lab you'll build a complete abstract interpreter that detects potential runtime errors (division by zero, unreachable code) using the abstract domain framework from Module 4. Your interpreter will be parameterized by domain -- the same code works with sign analysis, constant propagation, or interval analysis.

## Learning Objectives

- Build a functor-based analyzer parameterized by `ABSTRACT_DOMAIN`
- Implement abstract transfer functions for all statement types
- Wire widening into loop fixpoint computation
- Detect safety violations using abstract analysis results
- Compare domain precision on real programs

## Structure

| Part | Points | Description |
|------|--------|-------------|
| A | 40 | Multi-Domain Analyzer (analyzer.ml, environment.ml) |
| B | 35 | Safety Checker (safety_checker.ml, safety_reporter.ml) |
| C | 25 | Domain Comparison Report (analysis_report.md) |

## Getting Started

```bash
# Build
dune build

# Run your tests
dune runtest
```

## Part A: Multi-Domain Analyzer (40 points)

Implement the abstract interpreter in `analyzer.ml`:

1. **`eval_expr`**: Recursively evaluate AST expressions using abstract domain operations
2. **`transfer_stmt`**: Transfer each statement type through the abstract environment
3. **`analyze_function`**: Initialize parameters to Top, transfer the body
4. **`analyze_program`**: Analyze all functions in a program

Also implement environment helpers in `environment.ml`:
- `bound_vars`: list variables in the environment
- `restrict`: keep only specified variables
- `count_precise`: count variables with non-top, non-bottom values

## Part B: Safety Checker (35 points)

Implement safety checking in `safety_checker.ml`:

1. **`check_expr_safety`**: Flag divisions where the divisor's abstract value may include zero
2. **`check_stmt` / `check_stmts`**: Walk statements, threading environment and collecting issues
3. **`check_function` / `check_program`**: Entry points for checking

Implement reporting in `safety_reporter.ml`:
- `format_issue`: Format an issue as `[KIND] location: message (variable)`
- `print_report`: Print all issues with a header
- `summary`: Group issues by kind and count

## Part C: Domain Comparison Report (25 points)

Write `analysis_report.md` documenting:

1. Run 5 sample programs through all 3 domains (Sign, Constant, Interval)
2. For each program, record the abstract value of key variables in each domain
3. Compare: Which domain is most precise? Which has false positives?
4. Discuss trade-offs: precision vs. cost vs. termination

## Dependencies

This lab depends on:
- `abstract_domains` (the shared ABSTRACT_DOMAIN module type and MakeEnv functor)
- `shared_ast` (AST types, printer, sample programs)

## Tips

- Start with Part A -- the analyzer is the foundation for Part B
- Test with simple programs first (single assignment, then branches, then loops)
- For loops, use `Env.widen` to guarantee convergence
- The generic `eval_expr` maps literals to `D.top` -- this is correct for the generic interpreter
- For Part C, you may reference the domain-specific evaluators from Exercises 1-4
