# Week 3 Mini-Project: Static Bug Finder

## Overview

Build a static bug finder that combines control flow graphs with dataflow analysis to detect potential bugs in Python programs.

**Duration:** 1 week (estimated 10-12 hours)
**Prerequisites:** Module 3 (Static Analysis Fundamentals)

## Objectives

- Integrate CFG construction with dataflow analysis into a practical tool
- Implement at least one dataflow-based bug detection pass
- Understand how industrial bug-finding tools (Infer, Coverity) work at a conceptual level

## Requirements

### Core Requirements (70 points)

1. **CFG Construction (20 pts):** Build control flow graphs from Python functions that handle:
   - Sequential statements
   - If/elif/else branches
   - While and for loops
   - Try/except blocks (basic handling)

2. **Dataflow Analysis (25 pts):** Implement at least one dataflow analysis:
   - **Uninitialized variable detection** (reaching definitions based): find variables used before any definition reaches them
   - **Dead store detection** (live variable based): find assignments whose values are never subsequently read
   - **Null/None dereference** (forward analysis): track variables that may be `None` and flag attribute access on them

3. **Bug Reporting (10 pts):** Generate clear reports with:
   - File path and line number
   - Bug category and severity
   - Description of the issue
   - The offending code snippet

4. **CLI Interface (15 pts):** Accept files or directories, with options to select which analyses to run.

### Stretch Goals (30 points)

5. **Multiple Analyses (10 pts):** Implement 2 or more of the analyses listed above.
6. **CFG Visualization (10 pts):** Output CFG as DOT/Graphviz with dataflow annotations on each block.
7. **Interprocedural (10 pts):** Build a call graph and propagate analysis results across function boundaries.

## Deliverables

1. `bug_finder.py` -- Main entry point with CLI
2. `cfg.py` -- CFG construction
3. `analyses/` -- Directory with dataflow analysis implementations
4. `reporter.py` -- Bug report formatting
5. `test_bug_finder.py` -- Tests with known-buggy sample files
6. `sample_code/` -- Python files with intentional bugs for each analysis
7. `README.md` -- Usage instructions and analysis descriptions

## Suggested Approach

1. Reuse and extend your CFG builder from Module 3 exercises
2. Implement the dataflow framework (lattice + solver) generically
3. Build your first analysis (uninitialized variables is recommended -- it maps directly to reaching definitions)
4. Create test cases with known bugs to validate detection
5. Add the reporter and CLI last

## Example Bugs to Detect

```python
# Uninitialized variable
def example1(flag):
    if flag:
        x = 10
    print(x)  # BUG: x may be uninitialized if flag is False

# Dead store
def example2():
    result = compute()  # BUG: dead store -- overwritten below
    result = other_compute()
    return result

# Possible None dereference
def example3(data):
    item = data.get("key")  # item may be None
    return item.strip()     # BUG: possible None dereference
```

## Grading Rubric

| Criteria | Points |
|----------|--------|
| CFG construction (sequential, branches, loops) | 20 |
| At least one dataflow analysis | 25 |
| Clear bug reports with locations | 10 |
| CLI interface | 15 |
| Multiple analyses | 10 |
| CFG visualization with annotations | 10 |
| Interprocedural analysis | 10 |
| **Total** | **100** |

## Resources

- Module 3 exercises (CFG construction, dataflow framework, reaching definitions)
- [Facebook Infer](https://fbinfer.com/) -- industrial static analyzer for inspiration
- [Pyflakes source code](https://github.com/PyCQA/pyflakes) -- Python bug finder
