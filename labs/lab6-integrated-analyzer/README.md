# Lab 6: Integrated Analyzer

## Overview

Build a complete, multi-pass program analysis tool that detects safety violations (division by zero), security vulnerabilities (injection attacks), and code quality issues (dead code). This lab integrates techniques from Modules 2-6 into a unified pipeline with structured reporting.

## Learning Objectives

By completing this lab, you will:
1. Define a **unified finding type** that standardizes outputs across analysis passes
2. Implement **dead code detection** using purely AST-level analysis
3. Build a **safety analysis pass** using the sign abstract domain
4. Build a **taint analysis pass** using the taint abstract domain
5. Compose passes in a **pipeline** that collects and sorts findings
6. Generate **structured reports** from analysis results

## Prerequisites

- Module 4: Abstract Interpretation (sign domain, MakeEnv, eval_expr)
- Module 5: Security Analysis (taint domain, source/sink/sanitizer)
- Module 6: Tools Implementation (finding types, multi-pass composition)

## Structure

| Part | Points | Files | Description |
|------|--------|-------|-------------|
| A | 35 | `finding.ml`, `dead_code.ml` | Unified finding type + AST dead code detection |
| B | 40 | `safety_analysis.ml`, `taint_analysis.ml`, `pipeline.ml` | Multi-pass analysis + configurable pipeline |
| C | 25 | `reporter.ml`, `analysis_report.md` | Report generation + written analysis |

## Provided Files (Do Not Modify)

- `sign_domain.ml` — Sign abstract domain (from Module 4)
- `taint_domain.ml` — Taint abstract domain (from Module 5)
- `taint_config.ml` — Security configuration (sources, sinks, sanitizers)

## Part A: Finding Types + Dead Code (35 pts)

### finding.ml (15 pts)

Implement the unified finding type operations:
- `severity_to_string`, `category_to_string`, `severity_to_int`
- `sort_by_severity`, `filter_by_severity`, `filter_by_category`
- `format_finding`

### dead_code.ml (20 pts)

Implement purely AST-level dead code detection:
- `collect_used_vars_expr`, `collect_used_vars_stmts`, `collect_assigned_vars`
- `find_unreachable_code` — detect statements after Return
- `find_unused_variables` — detect assigned-but-never-read variables
- `find_unused_parameters` — detect parameters never read in the body
- Variables/parameters prefixed with `_` are exempt from unused warnings

## Part B: Multi-Pass Analysis (40 pts)

### safety_analysis.ml (15 pts)

Build a safety analysis pass using the sign domain:
- `eval_expr` — evaluate expressions in the sign domain
- `transfer_stmt` — process statements, detect division by zero
- `analyze_function`, `analyze_program`

Division by zero detection:
- Divisor is `Zero` → High severity finding
- Divisor is `Top` → Medium severity finding

### taint_analysis.ml (15 pts)

Build a taint analysis pass using the taint domain:
- `eval_expr` — evaluate expressions for taint status
- `transfer_stmt` — process statements, check sinks for tainted data
- `analyze_function`, `analyze_program`

Use `Taint_config.default_config` for sources, sinks, and sanitizers.

### pipeline.ml (10 pts)

Compose the analysis passes:
- `default_passes` — return dead_code, safety, and taint passes
- `run_all` — run all passes and return findings sorted by severity

## Part C: Reporter (25 pts)

### reporter.ml (15 pts)

Generate structured reports:
- `build_report` — compute severity/category counts from findings
- `format_text_report` — human-readable text report
- `format_summary` — one-line summary

### analysis_report.md (10 pts, manual grading)

Write a 1-2 page analysis report covering:
1. Your analysis pipeline architecture
2. A sample program and its findings
3. Strengths and limitations of your tool
4. How you would extend it for production use

## Building and Testing

```bash
# Build
dune build labs/lab6-integrated-analyzer/

# Run student tests
dune runtest labs/lab6-integrated-analyzer/starter/tests/

# Check for compilation errors
dune build @check
```

## Tips

- Start with Part A (finding.ml + dead_code.ml) — they have no domain dependencies
- For Part B, reference your Module 4 (sign domain) and Module 5 (taint domain) exercises
- The pipeline is simple once the individual passes work
- Use `Finding.severity_to_int` for sorting (higher = more severe)
- Exempt `_`-prefixed variables from unused warnings
