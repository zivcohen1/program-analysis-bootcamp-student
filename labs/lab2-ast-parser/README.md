# Lab 2: AST Parser and Analyzer

**Prerequisites:** Modules 1-2 completed
**Duration:** 3 hours | **Total Points:** 100

## Objectives

- Parse Python source files into ASTs using the `ast` module
- Implement AST traversal to extract program information
- Generate a structured analysis report

## Parts

### Part A: AST Generation (30 points)
- Parse provided Python sample programs into ASTs
- Generate visual representations of the ASTs
- Handle at least 3 different statement types (assignment, if, for, function def, etc.)

### Part B: Traversal Implementation (40 points)
- Implement depth-first traversal using the Visitor pattern
- Extract: all variable names, all function calls, all assignments
- Count node types and report statistics

### Part C: Analysis Report (30 points)
- Document findings from AST analysis of all sample programs
- Identify potential code issues (unused variables, unreachable code)
- Propose improvement suggestions

## Getting Started

```bash
cd labs/lab2-ast-parser/starter
pip install -r requirements.txt  # if present
python ast_parser.py sample_programs/fibonacci.py
pytest tests/test_parser.py -v
```

## Deliverables

1. Completed `ast_parser.py` with all TODO items implemented
2. Completed `analyzer.py` with analysis passes
3. Test suite passing: `pytest tests/test_parser.py`
4. (Solution only) Completed `analysis_report.md`

## Grading Rubric

| Criteria | Excellent (90-100%) | Good (80-89%) | Satisfactory (70-79%) | Needs Work (<70%) |
|----------|---------------------|---------------|----------------------|-------------------|
| Technical Implementation | Handles complex code, robust | Most cases work | Basic functionality | Significant issues |
| Code Quality | Clean, documented | Good structure | Functional | Poor structure |
| Analysis Depth | Insightful findings | Clear findings | Basic analysis | Shallow analysis |
| Problem Solving | Creative, handles edge cases | Solid approach | Meets requirements | Incomplete |
