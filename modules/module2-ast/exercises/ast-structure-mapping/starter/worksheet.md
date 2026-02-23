# AST Structure Mapping Worksheet

## Instructions
For each snippet, first draw the AST by hand, then verify with the visualizer.

---

## Snippet 1: `result = (2 + 3) * 4`

### Hand-drawn AST
<!-- Draw or describe the tree structure here -->


### Visualizer output matches? (yes/no): ___

### Node types used:
<!-- List all node types: Assign, BinOp, Name, Constant, etc. -->


---

## Snippet 2: If-Else
```python
if x > 0:
    y = x + 1
else:
    y = 0
```

### Hand-drawn AST
<!-- Draw or describe the tree structure here -->


### Key observation about the If node's children:


---

## Snippet 3: Function Definition
```python
def greet(name):
    message = "Hello, " + name
    return message
```

### Hand-drawn AST
<!-- Draw or describe the tree structure here -->


### How is the function parameter represented?


---

## Snippet 4: For Loop
```python
total = 0
for i in range(10):
    if i % 2 == 0:
        total = total + i
```

### Hand-drawn AST
<!-- Draw or describe the tree structure here -->


### What is the nesting depth of the innermost node?


---

## Reflection Questions

### 1. How does operator precedence appear in the AST?


### 2. What syntactic elements (from the source code) are NOT in the AST?


### 3. How would you use the AST to find all variable assignments in a program?

