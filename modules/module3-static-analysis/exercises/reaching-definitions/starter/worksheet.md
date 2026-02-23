# Reaching Definitions Worksheet

## Program to Analyze

```python
def example(x):
    a = 1        # Block B1: d1 (defines a)
    b = 2        #           d2 (defines b)
    if x > 0:
        a = 3    # Block B2: d3 (defines a)
        c = a    #           d4 (defines c)
    else:
        b = 4    # Block B3: d5 (defines b)
        c = b    #           d6 (defines c)
    print(a, b, c)  # Block B4: uses a, b, c
    return a + b + c
```

## Step 1: Draw the CFG

<!-- Draw or describe the CFG here -->

ENTRY → B1 → B2 → B4 → EXIT
             └→ B3 ↗

## Step 2: Compute Gen/Kill Sets

| Block | gen | kill |
|-------|-----|------|
| B1 | {___, ___} | {___} |
| B2 | {___, ___} | {___} |
| B3 | {___, ___} | {___} |
| B4 | {___} | {___} |

## Step 3: Iteration Table

### Iteration 0 (Initialization)

| Block | IN | OUT |
|-------|----|----|
| B1 | ∅ | ∅ |
| B2 | ∅ | ∅ |
| B3 | ∅ | ∅ |
| B4 | ∅ | ∅ |

### Iteration 1

| Block | IN | OUT | Changed? |
|-------|----|-----|----------|
| B1 | | | |
| B2 | | | |
| B3 | | | |
| B4 | | | |

### Iteration 2

| Block | IN | OUT | Changed? |
|-------|----|-----|----------|
| B1 | | | |
| B2 | | | |
| B3 | | | |
| B4 | | | |

## Step 4: Result Interpretation

At Block B4 entry, which definitions reach for each variable?

- Variable `a`: definitions ___ reach (values: ___)
- Variable `b`: definitions ___ reach (values: ___)
- Variable `c`: definitions ___ reach (values: ___)

## Step 5: Reflection

Why do multiple definitions of each variable reach the print statement?

