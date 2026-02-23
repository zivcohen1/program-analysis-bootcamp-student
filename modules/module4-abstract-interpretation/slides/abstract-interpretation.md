---
title: Abstract Interpretation
theme: white
highlightTheme: github
transition: slide
---

# Abstract Interpretation
## Module 4

**Instructor:** Weihao
**Office Hours:** By appointment, HH227

---

## Learning Objectives

- **Explain** abstract interpretation as a framework for sound program analysis
- **Implement** abstract domains (sign, constant, interval) satisfying the `ABSTRACT_DOMAIN` signature
- **Formalize** Galois connections and verify soundness properties
- **Apply** widening operators to guarantee termination on infinite-height lattices
- **Build** an abstract interpreter that detects division-by-zero and other safety violations
- **Compare** domains along precision/cost/termination axes

---

## Prerequisites Review

**From Module 3 -- Dataflow Analysis:**
- Lattices: bottom, top, join, meet, partial orders
- Transfer functions: how statements transform lattice values
- Fixpoint iteration: iterate until nothing changes
- Forward/backward analysis, may/must analysis

**The key insight from Module 3:**

```
Analysis = Lattice + Transfer Functions + Fixpoint Solver
```

Module 4 keeps the same solver but changes *what* the lattice tracks.

---

## The Leap from Module 3

Module 3 tracked **sets of names** (definitions, variables):

```
Reaching Defs:  {d1, d3, d5}     "which assignments reach here?"
Live Variables: {x, y, temp}     "which variables are used later?"
```

Module 4 tracks **abstract values** (signs, constants, intervals):

```
Sign Analysis:  x -> Pos, y -> Neg     "what sign does x have?"
Constant Prop:  x -> Const(42)         "is x always 42?"
Interval:       x -> [0, 100]          "what range is x in?"
```

Same framework, richer information, deeper questions.

---

## Motivating Example: Can This Crash?

```ocaml
let analyze x y =
  let a = x * x in         (* a = ? *)
  let b = a + 1 in         (* b = ? *)
  let c = y - y in         (* c = ? *)
  let result = b / c in    (* DIVISION BY ZERO? *)
  result
```

**Module 3 (reaching defs):** "The definition of c at line 3 reaches line 4."
That's true, but doesn't answer the safety question.

**Module 4 (sign analysis):** "c = Zero, so b/c is a division by zero."
Now we can detect the bug *before* running the program.

---

## Concrete vs. Abstract Semantics

```
Concrete World                    Abstract World
(exact values)                    (approximations)

  x = 42                           x -> Pos
  y = -7                           y -> Neg
  x + y = 35                       Pos + Neg = Top (don't know)
  x * x = 1764                     Pos * Pos = Pos (still positive)
```

**The deal:** We trade precision for decidability.
- Concrete: exact but undecidable (halting problem)
- Abstract: approximate but always terminates and is *sound*

**Sound** = if the analysis says "safe", the program truly is safe.
We may get false alarms, but we never miss real bugs.

---

## Galois Connections: The Formal Bridge

How do we relate concrete values to abstract values?

```
Concrete Domain (C)              Abstract Domain (A)
  (sets of integers)                 (signs)

     {1, 2, 3}    --- alpha --->     Pos
     {-1, 0, 5}   --- alpha --->     Top
     {0}           --- alpha --->     Zero
     Pos           --- gamma --->     {1, 2, 3, ...}
     Top           --- gamma --->     Z (all integers)
```

- **alpha (abstraction):** concrete set -> best abstract value
- **gamma (concretization):** abstract value -> set of concrete values it represents

---

## Galois Connections: Formal Definition

A **Galois connection** (C, alpha, gamma, A) requires:

```
For all c in C, a in A:
    alpha(c) <= a   iff   c <= gamma(a)
```

This adjunction property guarantees:
1. **alpha . gamma >= id** (abstracting then concretizing may lose info)
2. **gamma . alpha >= id** (every concrete value is captured)
3. **alpha** is monotone (bigger input -> bigger output)
4. **gamma** is monotone (bigger abstract value -> bigger concrete set)

```
        alpha
   C  ---------->  A
   |                |
   | gamma.alpha    | alpha.gamma
   |   >= id        |   >= id
   v                v
   C  <----------  A
        gamma
```

---

## Soundness via Over-Approximation

Abstract interpretation is **sound** because it over-approximates:

```
If the concrete computation produces value v,
then v is in gamma(abstract_result).
```

```
         Concrete:  {42}
              |
           subset of
              |
              v
     gamma(Pos) = {1, 2, 3, ...}     42 is in here -- SOUND
```

False positives are possible (we may warn about things that cannot happen).
False negatives are impossible (we never miss a real problem).

---

## Connecting to Module 3's Framework

The same fixpoint solver works -- we just swap the lattice:

```
Module 3:                              Module 4:
  Lattice = PowersetLattice              Lattice = ABSTRACT_DOMAIN
  Values  = sets of def names           Values  = abstract values (signs, etc.)
  Transfer = gen/kill                    Transfer = abstract eval of stmts
  Merge   = set union                   Merge   = pointwise join of envs
  Solver  = iterate until fixpoint      Solver  = iterate until fixpoint
```

```ocaml
(* Module 3 style: *)
module type LATTICE = sig
  type t
  val bottom : t
  val top : t
  val join : t -> t -> t
  val meet : t -> t -> t
  val equal : t -> t -> bool
end

(* Module 4 extends with: *)
module type ABSTRACT_DOMAIN = sig
  include LATTICE  (* inherits everything above *)
  val leq : t -> t -> bool    (* partial order *)
  val widen : t -> t -> t     (* termination guarantee *)
end
```

---

## The `ABSTRACT_DOMAIN` Module Type

```ocaml
module type ABSTRACT_DOMAIN = sig
  type t

  val bottom : t          (* least element: unreachable / no info *)
  val top    : t          (* greatest element: any value possible *)

  val join  : t -> t -> t  (* least upper bound *)
  val meet  : t -> t -> t  (* greatest lower bound *)
  val leq   : t -> t -> bool  (* partial order test *)
  val equal : t -> t -> bool  (* equality *)

  val widen : t -> t -> t  (* widening: guarantees termination *)

  val to_string : t -> string
end
```

Every domain in Module 4 (Sign, Constant, Interval) implements this signature.
The abstract interpreter is a **functor** parameterized by `ABSTRACT_DOMAIN`.

---

## Part 2: The Sign Domain

**Idea:** Track the sign of every integer variable.

```
         Top           "could be anything"
        / | \
     Neg Zero Pos      "definitely negative/zero/positive"
        \ | /
        Bot             "unreachable"
```

This is a **flat lattice** of height 3 with 5 elements.

**Finite height** means:
- No widening needed (ascending chains are bounded)
- Fixpoint always terminates
- Good first domain to implement

---

## Sign Lattice: Abstract Arithmetic

How does arithmetic work on signs?

**Addition:**
```
 +    | Bot  Neg  Zero  Pos  Top
------+----------------------------
 Bot  | Bot  Bot  Bot   Bot  Bot
 Neg  | Bot  Neg  Neg   Top  Top
 Zero | Bot  Neg  Zero  Pos  Top
 Pos  | Bot  Top  Pos   Pos  Top
 Top  | Bot  Top  Top   Top  Top
```

**Multiplication:**
```
 *    | Bot  Neg   Zero  Pos  Top
------+-----------------------------
 Bot  | Bot  Bot   Bot   Bot  Bot
 Neg  | Bot  Pos   Zero  Neg  Top
 Zero | Bot  Zero  Zero  Zero Zero
 Pos  | Bot  Neg   Zero  Pos  Top
 Top  | Bot  Top   Zero  Top  Top
```

Key: `Neg * Neg = Pos` (negative times negative is positive).

---

## Sign Domain: Transfer Functions

For each statement, compute the abstract effect:

```ocaml
(* Assignment: evaluate RHS in abstract environment *)
transfer (Assign (x, expr)) env =
  let v = abstract_eval expr env in
  update x v env

(* If: join environments from both branches *)
transfer (If (cond, then_body, else_body)) env =
  let env_then = transfer_stmts then_body env in
  let env_else = transfer_stmts else_body env in
  join_env env_then env_else
```

**abstract_eval** recursively evaluates expressions using abstract arithmetic:
```ocaml
abstract_eval (BinOp (Add, e1, e2)) env =
  abstract_add (abstract_eval e1 env) (abstract_eval e2 env)
```

---

## Sign Domain: Worked Example

```ocaml
let a = 5 in       (* a -> Pos *)
let b = -3 in      (* b -> Neg *)
let c = a + b in   (* c -> Pos + Neg = Top *)
let d = a * a in   (* d -> Pos * Pos = Pos *)
let e = b * b in   (* e -> Neg * Neg = Pos *)
let f = a * b in   (* f -> Pos * Neg = Neg *)
```

```
After each statement:
  a: Pos    b: Neg    c: Top    d: Pos    e: Pos    f: Neg
```

**Limitation:** `c = 5 + (-3) = 2` is actually `Pos`, but sign analysis says `Top` because it doesn't track magnitudes.

---

## Sign Domain: Precision Limits

```ocaml
let x = read_int () in    (* x -> Top *)
let y = x * x in          (* y -> Top * Top = Top *)
```

We know `x * x >= 0` for all integers, so `y` should be **non-negative**.
But the sign domain has no `NonNeg` element -- the best it can say is `Top`.

```
Concrete: x*x is in {0, 1, 4, 9, 16, ...}
Sign says: Top (could be anything)
Truth: always >= 0
```

This is a **precision loss** inherent to the sign abstraction.
More precise domains (intervals) can capture this.

---

## Part 3: Constant Propagation

**Idea:** Track whether a variable always holds the same constant.

```
              Top             "not a constant"
         /  |  |  |  \
  ... Const(-1) Const(0) Const(1) ...
         \  |  |  |  /
              Bot             "unreachable"
```

This is the **flat constant lattice** -- infinite width but height 3.

**Key operations:**
```
join(Const(3), Const(3)) = Const(3)    (same constant -- keep it)
join(Const(3), Const(5)) = Top         (different constants -- give up)
join(Const(n), Bot)      = Const(n)    (only one branch is reachable)
```

---

## Constant Propagation: Worked Example

```ocaml
let x = 5 in                 (* x -> Const(5) *)
let y = 3 in                 (* y -> Const(3) *)
let z = x + y in             (* z -> Const(5) + Const(3) = Const(8) *)
let w =
  if condition then
    z + 1                     (* w -> Const(9) on this path *)
  else
    z - 1                     (* w -> Const(7) on this path *)
in
(* After merge: w -> join(Const(9), Const(7)) = Top *)
(* But z is still Const(8) on both paths! *)
```

**Constant propagation vs. reaching definitions:**
- Reaching defs says: "d1 (z=x+y) reaches the use of z"
- Constant prop says: "z is always 8 -- you can replace Var(z) with IntLit(8)"

---

## Constant Propagation vs. Reaching Definitions

| Property | Reaching Definitions | Constant Propagation |
|----------|---------------------|---------------------|
| Tracks | Sets of definition labels | Actual values |
| Merge | Union (may analysis) | Join on flat lattice |
| Result | "Which assignments reach here?" | "Is this always the same constant?" |
| Use case | Dead code elimination | Constant folding |

Constant propagation is **strictly more informative** for optimization, but both answer different questions.

---

## Part 4: The Interval Domain

**Idea:** Track the range of possible values for each variable.

```
x -> [0, 100]      "x is between 0 and 100 inclusive"
y -> [-inf, 0]     "y is non-positive"
z -> [42, 42]      "z is exactly 42" (constant)
```

**Why intervals?**
- More precise than signs: `[0, +inf]` captures "non-negative"
- More flexible than constants: `[1, 10]` is useful but not a single constant
- Directly answers range queries: "Can x be negative?" "Can y be zero?"

---

## Interval Operations

```
[a, b] + [c, d] = [a+c, b+d]
[a, b] - [c, d] = [a-d, b-c]
[a, b] * [c, d] = [min(ac,ad,bc,bd), max(ac,ad,bc,bd)]

join([a,b], [c,d]) = [min(a,c), max(b,d)]
meet([a,b], [c,d]) = [max(a,c), min(b,d)]   (Bot if empty)
```

```
Example:
  [1, 5] + [2, 3] = [3, 8]
  [1, 5] * [-1, 2] = [min(-5,-1,2,10), max(-5,-1,2,10)]
                    = [-5, 10]

  join([1, 5], [8, 10]) = [1, 10]
  meet([1, 5], [3, 8])  = [3, 5]
```

---

## The Widening Problem

Intervals have **infinite height** -- ascending chains may never stabilize:

```
Iteration 1:  x -> [0, 0]
Iteration 2:  x -> [0, 1]     (joined with loop iteration)
Iteration 3:  x -> [0, 2]
Iteration 4:  x -> [0, 3]
...
Iteration n:  x -> [0, n-1]   (never converges!)
```

This happens in loops where a counter increments:
```ocaml
let i = ref 0 in
while !i < 100 do
  i := !i + 1
done
```

Without intervention, fixpoint iteration would run forever.

---

## The Widening Operator

**Widening** (`widen`) accelerates convergence by jumping to a stable value:

```
widen([a, b], [c, d]) =
  [ if c < a then -inf else a,
    if d > b then +inf else b ]
```

If the new bound exceeds the old bound, jump to infinity:

```
Iteration 1:  x -> [0, 0]
Iteration 2:  widen([0,0], [0,1]) = [0, +inf]   (upper bound grew -> jump to +inf)
Iteration 3:  [0, +inf] is stable -- fixpoint reached!
```

**Trade-off:** Widening may lose precision (we get `[0, +inf]` instead of `[0, 99]`),
but it guarantees termination in finitely many steps.

---

## Widening: Worked Example

```ocaml
let i = ref 0 in           (* i -> [0, 0] *)
while !i < 10 do           (* loop header *)
  i := !i + 1              (* i -> i + [1, 1] *)
done
```

```
                    Without widening        With widening
Iteration 1:       i -> [0, 0]             i -> [0, 0]
Iteration 2:       i -> [0, 1]             i -> widen([0,0],[0,1]) = [0, +inf]
Iteration 3:       i -> [0, 2]             i -> [0, +inf] (stable!)
...                ...
Iteration 11:      i -> [0, 10]            (already done)
Iteration 12:      (stable)

Steps to converge:  11                      2
```

After the loop: `i -> [0, +inf]` (with widening) vs `i -> [0, 10]` (without).
Widening is less precise but always terminates.

---

## Division-by-Zero Detection with Intervals

```ocaml
let a = read_int () in          (* a -> [-inf, +inf] *)
let b = a - a in                (* b -> [-inf,+inf] - [-inf,+inf] = [-inf,+inf] *)
let c = 10 / b in              (* b might be 0 -- WARNING! *)

let x = 5 in                    (* x -> [5, 5] *)
let y = x + 1 in                (* y -> [6, 6] *)
let z = 10 / y in              (* y is [6,6], 0 not in range -- SAFE *)
```

**Rule:** Division `a / b` is safe iff `0` is not in `gamma(abstract_b)`.
For intervals: safe iff the interval does not contain 0.

```
contains_zero([a, b]) = (a <= 0) && (0 <= b)
```

---

## Part 5: Domain Comparison

| Property | Sign | Constant | Interval |
|----------|------|----------|----------|
| **Height** | 3 (finite) | 3 (finite) | infinite |
| **Width** | 5 elements | infinite | infinite |
| **Widening needed?** | No | No | Yes |
| **Detects div-by-zero?** | Yes (Zero) | Yes (Const 0) | Yes (contains 0) |
| **x*x >= 0?** | No (says Top) | Only if x is const | Yes ([0, +inf]) |
| **Typical use** | Quick safety | Constant folding | Range analysis |

**More precise domains are more expensive:**
```
Sign < Interval < Concrete
 (fast)  (medium)   (undecidable)
```

---

## The Hierarchy of Abstractions

```
                      Concrete Semantics
                     (all possible values)
                           |
                    gamma  |  alpha
                           v
                    Interval Domain
                  ([lo, hi] ranges)
                           |
                    gamma  |  alpha
                           v
                      Sign Domain
                  (Neg, Zero, Pos, Top)
                           |
                    gamma  |  alpha
                           v
                   Trivial Domain
                      (just Top)
```

Each step up the chain:
- **Loses precision** (more abstract)
- **Gains efficiency** (smaller lattice, faster convergence)
- **Maintains soundness** (Galois connections compose)

---

## Abstract Interpretation in Practice

Real-world tools built on abstract interpretation:

| Tool | Domain | What it finds |
|------|--------|---------------|
| **Astree** | Relational intervals | Buffer overflows, div-by-zero in avionics (Airbus A380) |
| **Infer** | Separation logic | Memory leaks, null pointer derefs (Facebook) |
| **SLAM** | Predicate abstraction | API protocol violations (Windows drivers) |
| **Polyspace** | Intervals + octagons | Runtime errors in embedded C/C++ |
| **Frama-C** | Multiple domains | Value analysis for safety-critical C |

**Astree** proved the absence of all runtime errors in the A380 flight control software -- 132,000 lines of C, zero false alarms.

---

## Summary and Key Takeaways

```
Source Code  ->  AST  ->  CFG  ->  Abstract Interpretation  ->  Safety Proof
                                          |
                          +---------------+---------------+
                          |               |               |
                      Sign Domain   Constant Domain  Interval Domain
                      (fast, coarse) (good for opt)  (precise, needs widen)
```

**Key ideas:**
1. Abstract interpretation replaces concrete values with abstract summaries
2. Galois connections formalize the concrete-abstract relationship
3. Soundness = the analysis never misses a real error
4. Widening guarantees termination for infinite-height domains
5. The abstract interpreter is a functor -- same code, different domains

**From Module 3 to Module 4:**
Same solver + richer lattice = deeper analysis.

---

## Additional Resources

**Primary Reading:**
- Cousot & Cousot, *Abstract Interpretation: A Unified Lattice Model* (1977)
- [Static Program Analysis](https://cs.au.dk/~amoeller/spa/) -- Moeller & Schwartzbach, Chapters 5-7
- Rival & Yi, *Introduction to Static Analysis* (MIT Press)

**Practice:**
- Implement all three domains (sign, constant, interval)
- Verify Galois connection properties on paper and in code
- Run your abstract interpreter on sample programs and compare domain precision

**Deep dive:**
- Widening strategies: delayed widening, widening with thresholds
- Reduced product of domains (combine sign + interval)
- Relational domains: octagons, polyhedra
