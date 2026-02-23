# Analysis Report Template

**Student Name:** _______________
**Date:** _______________
**Target Program:** _______________

## 1. Overview

Briefly describe the program you analyzed and what it does.

## 2. Methodology

Describe the analysis techniques you applied:

- [ ] Manual code review
- [ ] Static analysis tool(s): _______________
- [ ] Dynamic analysis / testing
- [ ] AST inspection
- [ ] Control flow analysis
- [ ] Dataflow analysis

## 3. Findings

### Finding 1

| Field | Details |
|-------|---------|
| **Category** | (e.g., Bug, Style, Performance, Security) |
| **Severity** | (Error / Warning / Info) |
| **Location** | File:Line |
| **Description** | |
| **Detection Method** | (Static / Dynamic / Manual) |

### Finding 2

| Field | Details |
|-------|---------|
| **Category** | |
| **Severity** | |
| **Location** | |
| **Description** | |
| **Detection Method** | |

_(Copy the table for additional findings)_

## 4. Summary

| Severity | Count |
|----------|-------|
| Error | |
| Warning | |
| Info | |
| **Total** | |

## 5. Static vs. Dynamic Analysis Comparison

Which issues were found by static analysis? Which required running the program? Were there false positives?

| Issue | Found by Static? | Found by Dynamic? | Notes |
|-------|:-:|:-:|-------|
| | | | |

## 6. Recommendations

List suggested fixes in priority order.

1.
2.
3.

## 7. Reflection

What did you learn from this analysis? What was surprising? What would you do differently next time?
