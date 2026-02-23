---
title: Program Analysis for Beginners
theme: white
highlightTheme: github
transition: slide
---

# Program Analysis for Beginners
## Module 1: Foundations of Program Analysis

**Instructor:** Weihao
**Office Hours:** By appointment, HH227

---

## Learning Objectives

By the end of this module, you will be able to:

- **Define** program analysis and distinguish between static and dynamic approaches
- **Classify** different types of program analysis techniques by their goals
- **Evaluate** the trade-offs between soundness, completeness, and performance
- **Apply** basic analysis concepts to simple code examples

---

## What is Program Analysis?

**Program Analysis** is the process of automatically analyzing the behavior of computer programs.

- **Goal:** Understand what a program does without (necessarily) executing it
- **Purpose:** Find bugs, optimize performance, verify correctness
- **Scope:** From simple syntax checking to complex security analysis

---

## Why Do We Need Program Analysis?

**Problem:** Manual code review doesn't scale

- Modern software has millions of lines of code
- Human reviewers miss subtle bugs
- Security vulnerabilities can hide in complex logic

**Solution:** Automated analysis tools can systematically examine code

---

## Real-World Failures

| Incident | Year | Root Cause | Cost |
|----------|------|------------|------|
| Ariane 5 Explosion | 1996 | Integer overflow | $370M |
| Knight Capital | 2012 | Dead code activation | $440M |
| Heartbleed | 2014 | Buffer over-read | Billions |
| Boeing 737 MAX | 2018 | Sensor logic error | $20B+ |
| SolarWinds | 2020 | Supply chain attack | $100M+ |

Program analysis could have detected these issues.

---

## Real-World Impact

Program analysis powers tools you use daily:

- **IDEs:** IntelliSense, error highlighting, refactoring
- **Compilers:** Dead code elimination, optimization
- **Security:** Vulnerability scanners, malware detection
- **DevOps:** Static analysis in CI/CD pipelines

---

## Two Main Approaches

```
Program Analysis
├── Static Analysis
│   └── Analyzes code without running it
└── Dynamic Analysis
    └── Analyzes program during execution
```

Each approach has different strengths and limitations.

---

## Static Analysis Overview

**Examines code structure and syntax without execution**

- Analyzes source code, bytecode, or binary
- Can catch errors before runtime
- No need for test inputs or execution environment

**Example:** Checking for null pointer dereferences

---

## Static Analysis Example

```java
public void processUser(User user) {
    if (user.getName() != null) {
        System.out.println("Processing: " + user.getName());
    }

    // Static analysis can detect this potential issue
    int nameLength = user.getName().length(); // Possible NPE!
}
```

**Detection:** Tool identifies potential null pointer exception

---

## Dynamic Analysis Overview

**Observes program behavior during actual execution**

- Requires running the program with test inputs
- Can catch runtime-specific issues
- Sees actual execution paths and values

**Example:** Detecting memory leaks during program execution

---

## Dynamic Analysis Example

```ocaml
let rec fibonacci n =
  if n <= 1 then n
  else fibonacci (n - 1) + fibonacci (n - 2)

(* Dynamic analysis during execution *)
let result = fibonacci 40  (* Tool measures: 2.5 seconds, high CPU usage *)
```

**Detection:** Tool identifies performance bottleneck with real metrics

---

## Static vs Dynamic: Comparison

| Aspect | Static Analysis | Dynamic Analysis |
|--------|----------------|------------------|
| **Execution** | No execution needed | Requires running code |
| **Coverage** | All possible paths | Only executed paths |
| **Speed** | Generally faster | Depends on execution time |
| **False Positives** | More common | Fewer, but false negatives possible |

---

## Three Core Objectives

**By Purpose:**
- **Correctness:** Find bugs, verify specifications
- **Security:** Detect vulnerabilities, analyze threats
- **Performance:** Identify bottlenecks, optimize code

Each objective benefits from different analysis techniques.

---

## Core Concept: Soundness

**Sound Analysis:** Never misses real issues

- If analysis says "no bugs found," there truly are no bugs
- May report false positives (issues that aren't real)
- Conservative approach: "better safe than sorry"

```
Sound: All real bugs are reported
       (but some reports may be false alarms)
```

---

## Core Concept: Completeness

**Complete Analysis:** Never reports false positives

- If analysis reports a bug, it's definitely a real bug
- May miss some actual issues (false negatives)
- Precise approach: "only report what's certain"

```
Complete: All reported bugs are real
          (but some real bugs may be missed)
```

---

## The Fundamental Trade-off

```
         Soundness
             ↑
             |
   False ←───┼───→ Accurate
Positives    |     Analysis
             |
             ↓
        Completeness
```

**Rice's Theorem:** You cannot have perfect soundness AND completeness for non-trivial program properties.

---

## Analysis Scope Levels

```
Program Analysis Scope
├── Intraprocedural
│   └── Within single functions/methods
├── Interprocedural
│   └── Across function calls
└── Whole-Program
    └── Entire application analysis
```

Broader scope = more accurate but more expensive

---

## Intraprocedural Analysis

**Analyzes individual functions in isolation**

- Fast and scalable
- Detects local issues: uninitialized variables, dead code, basic logic errors
- Cannot track data across function boundaries

```ocaml
let example x =
  let y = 10 in           (* Definition *)
  if x > 0 then y
  else begin
    print_int y;           (* Is y always defined here? Yes *)
    0                      (* Can detect: not all paths return same type *)
  end
```

---

## Interprocedural Analysis

**Tracks information across function calls**

- More precise for security and resource analysis
- Higher computational cost
- Essential for taint tracking and vulnerability detection

```ocaml
let sanitize input =
  String.concat "''" (String.split_on_char '\'' input)

let query user_input =
  let safe = sanitize user_input in
  Db.execute (Printf.sprintf "SELECT * FROM users WHERE name = '%s'" safe)
  (* Interprocedural: tracks sanitize() effect *)
```

---

## Modern Analysis Ecosystem

**Integration Points:**
- **Development:** IDE plugins, linters
- **Build Process:** Compiler warnings, static checkers
- **CI/CD:** Automated security scans, quality gates
- **Production:** Runtime monitoring, profiling

```
Code → IDE Check → Build → CI/CD Gate → Deploy → Monitor
         ↑           ↑        ↑                     ↑
       Static     Static   Static+Dynamic        Dynamic
```

---

## SDLC Integration (Early Phases)

| Phase | Analysis Type | Example Tools |
|-------|--------------|---------------|
| Design | Threat modeling | STRIDE, Attack trees |
| Development | Linting, type checking | ESLint, mypy, TypeScript |
| Testing | Coverage, fuzzing | pytest-cov, AFL |

**Key insight:** Earlier detection = cheaper fixes

---

## SDLC Integration (Late Phases)

| Phase | Analysis Type | Example Tools |
|-------|--------------|---------------|
| Deployment | Security scanning | SonarQube, Semgrep |
| Production | Monitoring, profiling | APM tools, Valgrind |

Analysis should be applied at **every stage** of development.

---

## Analysis Goals Taxonomy

- **Correctness** -- Type errors, null dereferences, logic errors
- **Security** -- SQL injection, XSS, buffer overflow
- **Performance** -- Memory leaks, algorithmic complexity, resource contention

---

## Program Analysis vs. Testing vs. Debugging

- **Testing:** Runs selected paths with test cases to find failures
- **Debugging:** Traces a single failure path to find the root cause
- **Program Analysis:** Examines all paths from source code to find all issues

They are **complementary**, not competing approaches.

---

## Hands-On Exercise (25 minutes)

**Objective:** Compare static vs dynamic analysis on the same code

**Task:** Analyze the provided buggy calculator program using:
1. Static analysis tool (ESLint)
2. Dynamic analysis (running tests)

**Repository:** `exercises/calculator-bugs/`

**Deliverable:** Report comparing findings from both approaches

---

## Exercise: Setup & Static Analysis

1. **Setup:** `cd exercises/calculator-bugs/starter && npm install`
2. **Static Analysis:**
   - Run `npx eslint calculator.js`
   - Document all warnings/errors found

---

## Exercise: Dynamic Analysis & Comparison

3. **Dynamic Analysis:**
   - Run `node test-calculator.js`
   - Document runtime issues discovered
4. **Compare:** Which issues did each approach catch?

---

## Solution Review

**Static Analysis Findings:**
- Undefined variable usage
- Unreachable code after return
- Switch statement fallthrough

**Dynamic Analysis Findings:**
- Division by zero runtime error
- Infinite recursion with specific inputs
- Type coercion producing wrong results

**Key Insight:** Complementary approaches catch different issue types

---

## Key Takeaways

- **Program analysis automates** code understanding and bug detection
- **Static analysis** examines code structure; **dynamic analysis** observes execution
- **Perfect analysis is impossible** due to theoretical limitations
- **Trade-offs exist** between soundness, completeness, and performance
- **Modern development relies** on analysis tools at every stage

---

## Next Session Preview

**Module 2: Code Representation and Abstract Syntax Trees**

- How programs are represented internally
- Building and traversing ASTs
- Hands-on: Writing your first code transformer

**Prep:** Review basic tree data structures

---

## Questions & Discussion

**Discussion Prompts:**
- When would you prefer static vs dynamic analysis?
- What program analysis tools have you used?
- What types of bugs are hardest for humans to find?

**Office Hours:** By appointment, HH227
**Resources:** Course GitHub repository
