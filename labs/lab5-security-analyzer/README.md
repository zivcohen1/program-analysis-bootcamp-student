# Lab 5: Security Analyzer

## Overview

In this lab you'll build a complete security analyzer that detects OWASP vulnerability patterns (SQL injection, XSS, command injection, path traversal) using taint analysis. Your analyzer propagates taint from untrusted sources through computations, checks for tainted data at security-sensitive sinks, and produces formatted vulnerability reports.

## Learning Objectives

- Define security configurations mapping sources, sinks, and sanitizers
- Build a forward taint propagation engine using abstract transfer functions
- Detect vulnerabilities where tainted data reaches sinks without sanitization
- Format and report detected vulnerabilities with severity ratings
- Analyze the precision and limitations of taint-based security analysis

## Structure

| Part | Points | Description |
|------|--------|-------------|
| A | 35 | Taint Analyzer (security_config.ml, taint_analyzer.ml) |
| B | 40 | Vuln Checker + Reporter (vuln_checker.ml, vuln_reporter.ml) |
| C | 25 | Security Audit Report (analysis_report.md) |

## Getting Started

```bash
# Build
dune build

# Run your tests
dune runtest
```

## Part A: Taint Analyzer (35 points)

### security_config.ml (10 points)

Define the security configuration:

1. **`default_config`**: A web security configuration with:
   - Sources: `get_param`, `read_cookie`, `read_input`, `read_file`, `get_header`
   - Sinks: `exec_query` (sql-injection), `send_response` (xss), `exec_cmd` (command-injection), `open_file` (path-traversal), `redirect` (open-redirect)
   - Sanitizers: `escape_sql`, `html_encode`, `shell_escape`, `validate_path`, `validate_url`

2. **`is_source`**, **`find_sink`**, **`find_sanitizer`**: Lookup helpers

### taint_analyzer.ml (25 points)

Implement the taint propagation engine:

1. **`eval_expr`**: Evaluate expressions using taint rules:
   - Literals → Untainted
   - Variables → lookup in env
   - BinOp → propagate taint from both operands
   - Source calls → Tainted
   - Sanitizer calls → Untainted
   - Unknown calls → Top

2. **`transfer_stmt`**: Transfer statements through taint environment:
   - Assign: evaluate RHS, update env
   - If: transfer both branches, join
   - While: fixpoint with widening
   - Return/Print: env unchanged

3. **`analyze_function`**: Initialize params to Top, transfer body

## Part B: Vuln Checker + Reporter (40 points)

### vuln_checker.ml (25 points)

Detect vulnerabilities at sink calls:

1. **`check_call`**: Check if a call is a sink with tainted arguments
2. **`check_stmt`** / **`check_stmts`**: Walk statements, threading env and collecting vulnerabilities
3. **`check_function`** / **`check_program`**: Entry points

### vuln_reporter.ml (15 points)

Format vulnerability reports:

1. **`severity_of_vuln_type`**: Map vulnerability types to severity levels
2. **`format_vulnerability`**: Format as `[SEVERITY] type in location: message (var, sink)`
3. **`format_summary`**: Summary with count or "No vulnerabilities found."
4. **`group_by_type`**: Count vulnerabilities by type

## Part C: Security Audit Report (25 points)

Write `analysis_report.md` documenting:

1. Analyze 5 programs showing taint flow step-by-step
2. For each program, show whether vulnerabilities are detected or the program is safe
3. Discuss the precision, limitations, and trade-offs of your analyzer
4. Compare with real-world tools (Semgrep, CodeQL, etc.)

## Dependencies

- `abstract_domains` (ABSTRACT_DOMAIN module type and MakeEnv functor)
- `shared_ast` (AST types)

## Tips

- Start with Part A -- the analyzer is the foundation for Part B
- Test with simple programs first (source → sink, then add sanitizers, then branches)
- The `taint_domain.ml` file is provided -- focus on the analyzer logic
- For Part C, trace through programs by hand to verify your analyzer's output
