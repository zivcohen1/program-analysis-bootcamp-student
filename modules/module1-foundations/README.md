# Module 1: Foundations of Program Analysis

## Overview

This module introduces the core concepts of program analysis: what it is, why it matters, and the fundamental distinction between static and dynamic approaches. Through real-world failure case studies and hands-on exercises, students develop a practical understanding of how analysis techniques fit into modern software development.

## Learning Objectives

By the end of this module, you will be able to:

1. **Analyze** real-world software failures and identify which program analysis techniques could have prevented them
2. **Evaluate** the trade-offs between static and dynamic analysis approaches for different software quality objectives
3. **Apply** soundness and completeness concepts to categorize analysis tool results as true/false positives or negatives
4. **Design** an integration plan for program analysis techniques within a software development lifecycle
5. **Compare** different program analysis tools based on their scope, approach, and application domains
6. **Justify** the selection of appropriate program analysis techniques for specific software quality goals

## Prerequisites

- Basic programming experience in any language
- Familiarity with JavaScript (for calculator exercise)
- Understanding of basic software testing concepts

## Structure

| Component | Duration | Description |
|-----------|----------|-------------|
| Lesson 1 | 45 min | Software Quality Challenges |
| Lesson 2 | 30 min | What is Program Analysis? |
| Lesson 3 | 30 min | Static vs Dynamic Analysis |
| Lesson 4 | 45 min | Analysis Scope & Theoretical Foundations |
| Lesson 5 | 45 min | SDLC Integration |
| Exercises | 45 min | Calculator Bugs + Analysis Comparison |

## Materials

### Slides and Lectures
- [Slide Deck](slides/foundations.md) (Reveal.js format)
- [Detailed Lecture Notes](lecture-notes/detailed-notes.md)

### Tools Required
- Node.js 16+ with npm
- ESLint (`npm install eslint`)
- A code editor (VS Code recommended)

## Exercises

### Exercise 1: Calculator Bugs
**Objective:** Compare static vs dynamic analysis by finding bugs in a JavaScript calculator
**Duration:** 30 minutes
**Difficulty:** Beginner

```bash
cd exercises/calculator-bugs/starter
npm install
npx eslint calculator.js        # Static analysis
node test-calculator.js          # Dynamic analysis
```

**Tasks:**
1. Run ESLint to find static analysis issues
2. Run the test suite to discover runtime bugs
3. Fix all bugs and fill out the analysis report

**Deliverables:**
- Fixed `calculator.js`
- Completed `analysis-report.md`

### Exercise 2: Analysis Comparison
**Objective:** Classify code snippets by analysis objective and technique
**Duration:** 15 minutes
**Difficulty:** Beginner

**Tasks:**
1. Review 15 code snippets with various issues
2. Classify each by objective (correctness/security/performance)
3. Determine appropriate detection technique

**Deliverables:**
- Completed classification template

## Key Concepts

### Static vs Dynamic Analysis
- **Static:** Examines code without executing it. Finds all potential issues but may report false positives.
- **Dynamic:** Observes program behavior during execution. Precise results but limited to tested paths.

### Soundness and Completeness
- **Sound analysis:** Never misses real bugs (no false negatives), but may have false positives
- **Complete analysis:** Never reports non-bugs (no false positives), but may miss real issues

### Rice's Theorem
Perfect soundness AND completeness is impossible for non-trivial program properties. Tools must choose their trade-off.

## Common Issues and Solutions

### Issue: ESLint not finding all bugs
**Symptoms:** ESLint reports fewer issues than expected
**Solution:** Check `.eslintrc.json` rules are enabled. Some bugs are runtime-only.
**Prevention:** Understand that static analysis catches structural issues, not all runtime behavior.

### Issue: Confusion about false positives
**Symptoms:** Students unsure if a reported issue is real
**Solution:** Trace the code manually. A false positive means the tool flags safe code as buggy.

## Additional Resources

- [Readings & References](resources/readings.md)
- [Module Quiz](../../assessments/quizzes/module1-quiz.md)

## Next Steps

Module 2 dives into how programs are represented internally using Abstract Syntax Trees (ASTs). You'll learn to build, traverse, and transform tree representations of code -- the foundation for all analysis tools.

**Prep:** Review basic tree data structures (nodes, children, traversal).
