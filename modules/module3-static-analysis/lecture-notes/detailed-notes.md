# Module 3: Static Analysis Fundamentals - Detailed Lecture Notes

## Lesson 1: From Code to Flow: Understanding Control Flow Graphs

### Instructor Notes
Start with the motivation: "We have ASTs, but ASTs don't directly show us which statements can execute after which. For analysis, we need a representation that makes execution paths explicit."

### Key Points

**Basic Blocks:**
- A maximal sequence of consecutive statements with one entry, one exit
- No branching except at the end
- If any statement in the block executes, ALL statements execute
- Why: Simplifies analysis by grouping always-together statements

**CFG Construction Rules:**
| Source Construct | CFG Pattern |
|-----------------|-------------|
| Sequential code | Single block, single edge |
| if-else | Diamond shape: condition → then/else → merge |
| while loop | Back-edge from loop body to header |
| for loop | Similar to while, with init and update |
| return | Edge to exit node |
| break/continue | Edge to loop exit/header |

**Walk through four examples from the exercise:**

1. **Sequential:** One block, entry → block → exit
2. **If-else:** Entry → condition → then-block/else-block → merge → exit
3. **While:** Entry → init → header(condition) → body → back to header; header → exit
4. **Nested:** Combine patterns hierarchically

**Entry/Exit Nodes:**
- Every CFG has exactly one entry node and one exit node
- Multiple `return` statements each get an edge to the single exit
- Provides clean boundaries for analysis

### Teaching Tips
- Draw CFGs live on the board. Have students call out the basic blocks.
- Key insight: the CFG makes the back-edge visible in loops, which is why fixpoint is needed.
- Ask: "How many paths through this code?" to motivate systematic analysis.

---

## Lesson 2: The Dataflow Analysis Framework

### Instructor Notes
This is the most mathematically dense lesson. Lead with the intuition before the formalism: "We want to ask questions like 'which variable definitions can reach this point?' and we need a systematic way to compute the answer."

### Key Points

**Lattice Theory (intuitive):**
- A lattice is an ordered set where we can combine any two elements
- For reaching definitions: elements are sets of definitions
- Bottom (⊥) = no information = ∅
- Top (⊤) = all information = all definitions
- Join (⊔) = combine from multiple paths

**Transfer Functions:**
- Each basic block B has a transfer function: `f_B(IN) = OUT`
- For reaching definitions: `f_B(IN) = (IN - kill_B) ∪ gen_B`
- gen_B = definitions created in B
- kill_B = definitions overwritten in B

**Fixpoint Computation Algorithm:**
```
1. Initialize: all IN/OUT sets to ⊥ (bottom)
2. Repeat:
   a. For each block B:
      - IN[B] = JOIN(OUT[P] for P in predecessors(B))
      - OUT[B] = transfer(IN[B])
   b. If no IN/OUT set changed → DONE (fixpoint reached)
3. Return final IN/OUT sets
```

**Forward vs Backward:**
| Property | Forward | Backward |
|----------|---------|----------|
| Direction | Entry → Exit | Exit → Entry |
| IN computation | JOIN of predecessor OUTs | JOIN of successor INs |
| Example | Reaching definitions | Live variables |
| Question answered | "What happened before?" | "What will happen after?" |

**May vs Must:**
| Property | May Analysis | Must Analysis |
|----------|-------------|---------------|
| Join operation | Union (∪) | Intersection (∩) |
| Meaning | True on SOME path | True on ALL paths |
| Sound for | Over-approximation | Under-approximation |
| Example | Reaching defs | Available expressions |

### Teaching Tips
- The lattice concept is abstract. Use concrete example: powerset of {d1, d2, d3} with subset ordering.
- Draw the Hasse diagram of the powerset lattice on the board.
- Fixpoint always terminates because: lattice is finite, transfer functions are monotone, and information can only grow.

---

## Lesson 3: Reaching Definitions

### Instructor Notes
This is the "aha" lesson where the framework becomes concrete. Walk through the full example step by step. Use the iteration table.

### Key Points

**The Problem:** For each variable use, which assignments might have defined that variable's value?

**Full Walkthrough:**
```python
def example(x):
    a = 1        # d1 (defines a)
    b = 2        # d2 (defines b)
    if x > 0:
        a = 3    # d3 (defines a)
        c = a    # d4 (defines c)
    else:
        b = 4    # d5 (defines b)
        c = b    # d6 (defines c)
    print(a, b, c)
```

**Gen/Kill Sets:**
| Block | gen | kill |
|-------|-----|------|
| B1 (d1, d2) | {d1, d2} | {} |
| B2 (d3, d4) | {d3, d4} | {d1} |
| B3 (d5, d6) | {d5, d6} | {d2} |
| B4 (print) | {} | {} |

**Iteration Table:**
| Iteration | Block | IN | OUT | Changed? |
|-----------|-------|----|-----|----------|
| Init | All | ∅ | ∅ | -- |
| 1 | B1 | ∅ | {d1,d2} | Yes |
| 1 | B2 | {d1,d2} | {d2,d3,d4} | Yes |
| 1 | B3 | {d1,d2} | {d1,d5,d6} | Yes |
| 1 | B4 | {d1,d2,d3,d4,d5,d6} | {d1,d2,d3,d4,d5,d6} | Yes |
| 2 | B1-B4 | (same) | (same) | No → Fixpoint! |

**Interpretation:**
At B4 (print statement):
- Variable `a`: d1 and d3 both reach → either 1 or 3
- Variable `b`: d2 and d5 both reach → either 2 or 4
- Variable `c`: d4 and d6 both reach → depends on branch taken

### Teaching Tips
- Have students fill in the iteration table themselves before showing the answer.
- Key question: "Why does it converge in 2 iterations for this example?"
- Mention that loops may require more iterations (the back-edge brings new information).

---

## Lesson 4: Live Variables and Available Expressions

### Instructor Notes
Now show the same framework with different parameters. The contrast between forward/backward and may/must is the key learning outcome.

### Key Points

**Live Variables (Backward, May):**
- A variable is "live" at a point if it MIGHT be used before being redefined
- Work backwards from uses to definitions
- Transfer: `IN = (OUT - def) ∪ use`
- Join: `OUT[B] = ∪(IN[S] for S in successors(B))`

**Available Expressions (Forward, Must):**
- An expression is "available" if it has been computed on ALL paths and operands haven't changed
- Join: `IN[B] = ∩(OUT[P] for P in predecessors(P))` -- intersection!
- Transfer: `OUT = (IN - killed_exprs) ∪ generated_exprs`

**Comparison Table:**
| Analysis | Direction | Join | Transfer | Application |
|----------|-----------|------|----------|-------------|
| Reaching Defs | Forward | ∪ | OUT = (IN-kill)∪gen | Dead code elimination |
| Live Variables | Backward | ∪ | IN = (OUT-def)∪use | Register allocation |
| Available Exprs | Forward | ∩ | OUT = (IN-kill)∪gen | Common subexpr elimination |

### Teaching Tips
- Run all three analyses on the SAME program side by side. This is the most effective way to show how the framework parameters change.
- Emphasize: same algorithm, different lattice and direction → different analysis.

---

## Lesson 5: Interprocedural Analysis

### Instructor Notes
This lesson is more conceptual -- it shows the frontier between what we can easily analyze and what becomes hard. Don't go too deep into the math; focus on trade-offs.

### Key Points

**Call Graphs:**
- Nodes = functions, Edges = possible calls
- Foundation for interprocedural analysis
- Static approximation of runtime call relationships

**Context Sensitivity:**
- Context-insensitive: merge all call sites → less precise
- Context-sensitive: distinguish call sites → more precise but exponential
- k-CFA: limit context depth to k levels

**Scalability:**
| Approach | Precision | Scalability |
|----------|-----------|-------------|
| Context-insensitive | Low | High (linear) |
| 1-context-sensitive | Medium | Medium |
| Full context-sensitive | High | Poor (exponential) |
| Summary-based | Medium-High | Good |

**Real-world trade-offs:**
- Google's Tricorder: mostly intraprocedural, fast, runs on every commit
- Facebook's Infer: interprocedural, more precise, runs on diffs
- Academic tools: whole-program, most precise, too slow for CI/CD

### Teaching Tips
- Use the exercise program with `helper()` called twice to demonstrate context sensitivity.
- Ask: "What would happen if helper() was called from 100 different places?"
- This naturally motivates the capstone and advanced modules.

---

## Module Summary

### Key Takeaways
1. CFGs transform code into graphs that make all execution paths explicit
2. The dataflow framework is remarkably general: same algorithm, different parameters → different analyses
3. Reaching definitions is a forward, may analysis (union at joins)
4. Live variables is a backward, may analysis
5. Available expressions is a forward, must analysis (intersection at joins)
6. Interprocedural analysis faces exponential blowup from context sensitivity

### Preparation for Labs
Students should be able to:
- Draw CFGs for code with if/else, while, for, nested structures
- Compute gen/kill sets and run the fixpoint algorithm by hand
- Implement the framework components in Python
- Explain why different analyses use union vs intersection at merge points
