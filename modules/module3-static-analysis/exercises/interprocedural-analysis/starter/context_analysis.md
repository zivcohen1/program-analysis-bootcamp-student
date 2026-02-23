# Context Sensitivity Analysis Worksheet

## Program

```python
def helper(param):
    local_var = param + 1
    return local_var

def process_data(x, y):
    temp = x * 2
    result1 = helper(temp)    # call site 1
    result2 = helper(y)       # call site 2
    final = result1 + result2
    return final

def main():
    a = 5
    b = 10
    output = process_data(a, b)
    print(output)
```

---

## Part 1: Context-Insensitive Analysis

When we analyze `helper()` without distinguishing call sites:

**What values can `param` take?**
<!-- Answer: param can be temp (= a*2 = 10) OR y (= b = 10) -->


**What is the merged analysis result for `local_var`?**
<!-- Answer: local_var = param + 1, but we don't know which param -->


**What precision do we lose?**
<!-- Answer: We can't distinguish result1 from result2 -->


---

## Part 2: 1-Level Context-Sensitive Analysis

Now distinguish by calling context:

**Context 1:** `helper` called from `process_data:line_8` with `temp`

- `param` = ___
- `local_var` = ___
- return value = ___

**Context 2:** `helper` called from `process_data:line_9` with `y`

- `param` = ___
- `local_var` = ___
- return value = ___

**How does this improve precision?**


---

## Part 3: Scalability

**If `helper()` were called from 100 different functions:**

- How many contexts would 1-level sensitivity create? ___
- How many would full context sensitivity create? ___
- What is the trade-off?


**If the program had recursive calls:**

- How would context sensitivity handle `f() → g() → f() → g() → ...`?
- What is k-limiting and how does it help?


---

## Part 4: Summary-Based Analysis

**Write a summary for `helper(param)`:**

- Input: ___
- Output: ___
- Side effects: ___
- Key property: ___

**How would you use this summary at each call site instead of reanalyzing the function body?**

