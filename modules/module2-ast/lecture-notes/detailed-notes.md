# Module 2: Code Representation and ASTs - Detailed Lecture Notes

## Lesson 1: AST Architecture: Nodes, Types, and Hierarchies

### Instructor Notes
Start with an analogy: just as linguists parse sentences into grammatical components (subject, verb, object), program analyzers parse code into structured components using ASTs. Show a simple English sentence parse tree alongside a code AST to build intuition.

### Key Points

**AST Node Categories:**
- **Expressions:** Evaluate to values (literals, binary ops, function calls, identifiers)
- **Statements:** Perform actions (assignment, if/else, loops, return)
- **Declarations:** Introduce names (variable declarations, function definitions, class definitions)

**Hierarchical Structure:**
- Parent-child relationships reflect containment and precedence
- Higher precedence operators appear lower in the tree
- The root operator is evaluated last

**Example walkthrough:** `int result = (2 + 3) * 4;`
```
Declaration(result, int)
    └── Assign
        └── BinOp(*)
            ├── BinOp(+)
            │   ├── Literal(2)
            │   └── Literal(3)
            └── Literal(4)
```

**AST vs Parse Tree:**
- Parse trees include ALL grammar derivation details (parentheses, semicolons, intermediate rules)
- ASTs remove syntactic noise, keeping only semantic structure
- ASTs are more compact and analysis-friendly

**Node Attributes:**
- Value/operation type
- Source location (line, column) for error reporting
- Type information (added during semantic analysis)
- Parent reference (for upward navigation)

### Teaching Tips
- Use Python's `ast.dump()` on live examples. Students see the real AST.
- Have students draw ASTs by hand first, then verify with the tool.
- Common mistake: incorrect precedence. `2 + 3 * 4` should have `+` at root, `*` as right child.

---

## Lesson 2: Navigating the Tree: AST Traversal Algorithms

### Instructor Notes
Traversal is the workhorse of all AST-based analysis. Every tool that processes code uses some form of tree traversal. Make the connection explicit: "Every time your IDE highlights an error, a traversal is happening."

### Key Points

**Three DFS variations:**

1. **Pre-order** (Visit, then children): Top-down analysis
   - Use: Scope entry, type propagation downward
   - For `(a+b)*(c-d)`: visits `*, +, a, b, -, c, d`

2. **Post-order** (Children, then visit): Bottom-up analysis
   - Use: Expression evaluation, code generation
   - For `(a+b)*(c-d)`: visits `a, b, +, c, d, -, *`

3. **In-order** (Left, visit, right): Only for binary trees
   - Use: Reconstructing infix expressions

**BFS / Level-order:**
- Uses a queue
- Visits all nodes at depth d before depth d+1
- Use: Level-based analysis, structural metrics

**Visitor Pattern:**
The key design pattern for extensible AST processing:
```python
class NodeVisitor:
    def visit(self, node):
        method_name = f'visit_{type(node).__name__}'
        visitor = getattr(self, method_name, self.generic_visit)
        return visitor(node)

    def generic_visit(self, node):
        for child in node.children:
            self.visit(child)
```

Why it matters: Separate traversal from analysis. Add new analyses (type checker, linter, code generator) without modifying AST node classes.

**State Management:**
- Simple traversals are stateless
- Real analyses maintain state: symbol tables, type contexts, error lists
- Use a stack for nested contexts (entering/exiting scopes)

### Teaching Tips
- Trace through a small AST with colored markers for each traversal order
- Implementation exercise: have students predict the output before running
- Key test: pre-order of `(a+b)*(c-d)` should give `['*', '+', 'a', 'b', '-', 'c', 'd']`

---

## Lesson 3: Names and Scopes: Symbol Tables and Resolution

### Instructor Notes
This lesson bridges data structures and language semantics. Students often underestimate the complexity of name resolution until they implement it.

### Key Points

**Lexical Scoping:**
- Scope is determined by where code appears in the source text
- Inner scopes can access identifiers from outer scopes
- Inner declarations can shadow outer ones

**Symbol Table Operations:**
| Operation | Description |
|-----------|-------------|
| `define(name, info)` | Add identifier to current scope |
| `lookup(name)` | Find identifier (searches up scope chain) |
| `enter_scope()` | Create new nested scope |
| `exit_scope()` | Return to parent scope |

**Scope Chain Resolution:**
When looking up a name, search from innermost to outermost:
1. Current scope
2. Enclosing scope
3. ... up to global scope
4. If not found → undefined identifier error

**Shadowing Example:**
```python
x = 10               # Global: x=10
def outer():
    x = 20           # Outer: x=20 (shadows global)
    def inner():
        print(x)     # Resolves to outer's x=20
    inner()
print(x)             # Resolves to global x=10
```

### Teaching Tips
- Draw scope boxes on the board, showing the parent chain
- Shadowing is a common source of bugs -- relate to real IDE warnings
- Test cases must cover: basic lookup, nested scopes, shadowing, undefined names

---

## Lesson 4: Transforming Code: AST Manipulation Techniques

### Instructor Notes
This is where theory meets practice. Students build transformations that are the core of refactoring tools and optimizing compilers.

### Key Points

**Constant Folding:**
- Replace expressions with only constant operands with their result
- `2 + 3` → `5`
- Must handle: `+`, `-`, `*`, `/` (watch for division by zero)
- Recursive: fold children first, then check if node can be folded

**Variable Renaming:**
- Update ALL occurrences: declarations AND references
- Must respect scope boundaries
- A name `x` in an inner scope is different from `x` in outer scope

**Dead Code Elimination:**
- Remove statements after `return`
- Remove branches of `if` with constant conditions (`if True:` → keep only then-branch)
- Careful: removing code can expose new dead code (iterate until stable)

**Transformation Pipeline:**
```python
def optimize(ast):
    ast = constant_fold(ast)
    ast = eliminate_dead_code(ast)
    return ast
```

Order matters: constant folding may create opportunities for dead code elimination.

### Teaching Tips
- Walk through the sample AST step by step, showing before/after for each transformation
- Emphasize safety: transformations must not change program behavior
- Common mistake: forgetting to update parent pointers after node replacement

---

## Module Summary

### Key Takeaways
1. ASTs represent code structure hierarchically, abstracting away syntactic noise
2. Different traversals serve different analysis needs (pre-order=top-down, post-order=bottom-up)
3. Symbol tables with scope chains handle identifier resolution across nested scopes
4. AST transformations enable automated refactoring and optimization
5. The Visitor pattern separates traversal logic from analysis logic

### Preparation for Module 3
Students should be comfortable with:
- Building and traversing tree structures
- Set operations (union, intersection, difference)
- Basic graph concepts (nodes, edges, directed graphs)
- The concept of iterative computation until convergence
