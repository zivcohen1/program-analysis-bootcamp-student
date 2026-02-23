# Lab 3: Static Analysis Checker

**Prerequisites:** Modules 1-3 completed
**Duration:** 4 hours | **Total Points:** 100

## Objectives

- Implement a static analysis tool for Python code quality checking
- Create a configurable rule engine with multiple analysis passes
- Generate structured analysis reports

## Parts

### Part A: Core Analysis Engine (40 points)
- Implement `StaticChecker` class that parses and analyzes Python files
- Detect: unused variables, unreachable code after return, undefined variable references
- Handle multiple files in a single analysis run

### Part B: Rule Engine (35 points)
- Create configurable analysis rules with enable/disable and severity levels
- Implement at least 3 rules: unused-variable, unreachable-code, shadowed-variable
- Generate structured reports (text and JSON)

### Part C: Integration Testing (25 points)
- Test tool on provided sample code files
- Document tool capabilities and limitations
- Measure and report analysis performance

## Getting Started

```bash
cd labs/lab3-static-checker/starter
pytest tests/test_checker.py -v
python checker.py sample_code/
```

## Deliverables

1. Completed `checker.py`, `rules.py`, `reporter.py`
2. Test suite passing
3. Analysis of all sample code files

## Grading Rubric

| Criteria | Excellent (90-100%) | Good (80-89%) | Satisfactory (70-79%) | Needs Work (<70%) |
|----------|---------------------|---------------|----------------------|-------------------|
| Analysis Accuracy | High precision, minimal false positives | Good accuracy | Acceptable accuracy | Many false positives/negatives |
| Tool Architecture | Modular, extensible design | Well-structured | Functional | Poorly structured |
| Performance | Efficient, scales well | Good performance | Adequate | Performance issues |
| Documentation | Comprehensive | Good coverage | Basic | Minimal |
