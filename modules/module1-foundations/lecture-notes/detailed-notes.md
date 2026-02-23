# Module 1: Foundations of Program Analysis - Detailed Lecture Notes

## Lesson 1: Software Quality Challenges and the Need for Program Analysis

### Instructor Notes
Open with a compelling story: the Ariane 5 rocket explosion (1996). A $370 million rocket destroyed 37 seconds after launch because of an integer overflow converting a 64-bit float to a 16-bit integer. This code had worked perfectly in Ariane 4 -- the bug only manifested in the new rocket's flight parameters.

### Key Points to Emphasize

**Software failures are expensive and dangerous:**
- SolarWinds (2020): Supply chain attack affecting 18,000 organizations
- Equifax (2017): 147 million people's data exposed
- Knight Capital (2012): $440M lost in 45 minutes due to dead code reactivation
- Heartbleed (2014): OpenSSL buffer over-read, affected millions of servers
- Boeing 737 MAX (2018-2019): MCAS sensor logic errors, 346 deaths

**Why traditional testing is insufficient:**
- Dijkstra's principle: "Testing can only demonstrate the presence of bugs, never their absence"
- A function with 10 conditionals has 2^10 = 1024 paths; tests typically cover 50-100
- Manual code review doesn't scale to modern codebases (millions of LOC)

**SDLC Context:**
- Finding a bug in design costs 1x; in production costs 100x
- Program analysis integrates at every phase: design, development, testing, deployment, monitoring

### Teaching Tips
- Ask students about bugs they've encountered. Connect their experiences to analysis concepts.
- Use the "cost of bugs" framing to motivate why early detection matters.

---

## Lesson 2: What is Program Analysis - Definitions and Core Objectives

### Instructor Notes
Transition from "why" to "what." Define program analysis precisely and distinguish it from related activities.

### Key Points to Emphasize

**Formal definition:** Program analysis is the systematic, automated examination of program source code, bytecode, or execution traces to determine properties about program behavior, correctness, security, or performance.

**Three core objectives:**
1. **Correctness:** Does the program do what it should? (functional bugs, type errors, null dereferences)
2. **Security:** Is the program safe from attacks? (SQL injection, XSS, buffer overflow)
3. **Performance:** Does the program use resources efficiently? (memory leaks, algorithmic complexity)

**Distinction from related activities:**
| Activity | Input | Goal | Automation |
|----------|-------|------|------------|
| Testing | Test cases | Find specific failures | Semi-automated |
| Debugging | Bug report | Find root cause | Manual |
| Program Analysis | Source code | Find all potential issues | Fully automated |

**Concrete example:** ESLint detecting undefined variable access in JavaScript before execution:
```javascript
function calculate(x) {
    return x + y;  // ESLint: 'y' is not defined (no-undef)
}
```

### Teaching Tips
- Demo ESLint live on a small file with intentional bugs. Show the immediate feedback loop.
- Emphasize that analysis, testing, and debugging are complementary, not competing.

---

## Lesson 3: Static vs Dynamic Analysis - Two Fundamental Approaches

### Instructor Notes
This is the core conceptual distinction of the entire course. Spend time making the trade-offs concrete.

### Key Points to Emphasize

**Static Analysis characteristics:**
- Examines code without executing it
- Analyzes source code, bytecode, or binary
- Covers ALL possible execution paths
- May produce false positives (flags safe code as buggy)
- Tools: ESLint, SonarQube, Pylint, Clang Static Analyzer

**Dynamic Analysis characteristics:**
- Observes program during actual execution
- Requires test inputs and runtime environment
- Only covers EXECUTED paths
- Fewer false positives, but may miss bugs on untested paths
- Tools: Valgrind, gdb, profilers, fuzzing tools

**The complementary nature:**
- Static catches broad structural issues (all paths)
- Dynamic catches precise runtime behavior (tested paths only)
- Best practice: use both in tandem

**Example to walk through:**
```c
void process(char *input) {
    char buffer[10];
    strcpy(buffer, input);  // Static: potential buffer overflow
                            // Dynamic: actual overflow with input > 10 chars
}
```
- Static analysis flags the strcpy as potentially unsafe (all inputs)
- Dynamic analysis (e.g., AddressSanitizer) catches it only when a long input is provided

### Teaching Tips
- Create a 2-column board: Static | Dynamic. Have students place concepts in the right column.
- Key question: "Which approach would you use for a medical device? A web startup?"

---

## Lesson 4: Analysis Scope and Theoretical Foundations

### Instructor Notes
This lesson introduces the mathematical constraints on program analysis. Students often find Rice's theorem abstract -- anchor it with concrete examples.

### Key Points to Emphasize

**Scope levels:**
1. **Intraprocedural:** Within a single function. Fast, scalable, catches local issues.
2. **Interprocedural:** Across function calls. Tracks data through call chains. Higher cost.
3. **Whole-program:** Entire application. Most precise, most expensive.

**Soundness:**
- "If I say it's safe, it IS safe" (no false negatives)
- Sound analysis over-approximates: reports everything that MIGHT be a bug
- Result: some false positives, but no real bugs slip through

**Completeness:**
- "If I report a bug, it IS a bug" (no false positives)
- Complete analysis under-approximates: only reports definite bugs
- Result: every report is actionable, but some real bugs may be missed

**Rice's Theorem (intuitive explanation):**
- For any non-trivial property of programs, no algorithm can perfectly decide that property for all programs
- "Non-trivial" = the property isn't true for ALL programs or false for ALL programs
- Consequence: perfect analysis is impossible; we must choose our trade-offs

**Connecting to practice:**
- Safety-critical systems (aviation, medical): prioritize soundness (catch everything, tolerate false alarms)
- Developer tools (linters): prioritize completeness (only actionable reports, may miss some issues)

### Teaching Tips
- Avoid deep mathematical formalism. Use the halting problem as an intuitive anchor: "Can you write a program that decides if any program will halt?"
- Show that real tools make explicit choices. SonarQube has configurable rules with different soundness/completeness profiles.

---

## Lesson 5: Program Analysis in Practice - SDLC Integration and Applications

### Instructor Notes
Bring everything together with practical integration strategies. This lesson bridges theory and real-world workflows.

### Key Points to Emphasize

**Design phase:**
- Threat modeling before code is written
- Architectural analysis for security and performance
- Cost: issues found here are 10-100x cheaper to fix

**Development phase:**
- IDE plugins for real-time feedback (ESLint, Pylint in VS Code)
- Pre-commit hooks to prevent bad code from entering the repository
- Key principle: fast feedback loop, minimal developer friction

**Testing and deployment:**
- CI/CD integration: automated analysis on every commit
- Quality gates: block deployment if critical issues are found
- Security scanning before production deployment

**Production monitoring:**
- Runtime application security protection (RASP)
- Performance monitoring (APM)
- Error tracking and crash reporting

**Integration workflow:**
```
Developer writes code
    ↓
IDE plugin catches issues immediately
    ↓
Pre-commit hook runs linter
    ↓
CI/CD pipeline runs full static analysis
    ↓
Deployment gate checks security scan
    ↓
Production monitoring tracks runtime behavior
```

### Teaching Tips
- If possible, demo a GitHub Actions workflow that runs ESLint on push.
- Discussion exercise: Have teams design an analysis strategy for a healthcare web application. What tools at which stages? What are the quality gates?
- Emphasize that the best analysis tool is useless if developers ignore its output. Developer experience matters.

---

## Module Summary

### Key Takeaways for Students
1. Program analysis automates code understanding and bug detection
2. Static analysis examines code structure without execution; dynamic analysis observes runtime behavior
3. Perfect analysis is theoretically impossible (Rice's theorem)
4. Trade-offs between soundness and completeness drive tool design
5. Effective analysis integrates into every SDLC phase

### Common Misconceptions to Address
- "Static analysis catches all bugs" -- No, it trades precision for coverage
- "Dynamic analysis is just testing" -- Testing validates expected behavior; dynamic analysis observes runtime properties
- "We don't need analysis if we have good tests" -- Analysis and testing are complementary
- "More analysis is always better" -- There are diminishing returns and developer fatigue with too many tools/alerts

### Preparation for Module 2
Students should review:
- Basic tree data structures (nodes, children, leaves)
- Tree traversal algorithms (DFS, BFS conceptually)
- How compilers process source code (lexing → parsing → AST, at a high level)
