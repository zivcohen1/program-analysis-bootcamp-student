---
title: Static Analysis Fundamentals
theme: white
highlightTheme: github
transition: slide
---

# Static Analysis Fundamentals
## Module 3

**Instructor:** Weihao
**Office Hours:** By appointment, HH227

---

## Learning Objectives

- **Construct** control flow graphs (CFGs) from source code, identifying basic blocks and control structures
- **Apply** the dataflow analysis framework using lattices, transfer functions, and fixpoint computation
- **Implement** reaching definitions analysis by hand and through code
- **Compare** forward and backward dataflow analyses on the same program
- **Evaluate** limitations and scalability challenges of interprocedural analysis
- **Design** simple static analysis tools combining CFGs with dataflow analysis

---

## Prerequisites Review

**From Module 2 -- AST Knowledge:**
- ASTs provide structured representation of program syntax
- Tree traversal techniques (pre-order, post-order)
- Node types and their semantic meaning

**Mathematical Foundations:**
- **Set Theory:** Union (U), intersection (n), difference (\\)
- **Graph Theory:** Directed graphs, nodes, edges, paths, cycles
- **Functions:** Domain, range, composition

---

## Lesson 1: Control Flow Graphs

From code to flow -- how programs *actually* execute.

```
Source Code  --->  AST  --->  CFG  --->  Dataflow Analysis
  (text)        (tree)      (graph)      (properties)
```

ASTs tell us the **structure** of code.
CFGs tell us the **execution paths** through code.

---

## Why Control Flow Graphs?

Consider this code -- how many paths exist?

```ocaml
let example x y =
  let a =
    if x > 0 then 1
    else 2
  in
  let b =
    if y > 0 then a
    else -a
  in
  b
```

**Answer:** 4 paths (2 x 2 branches). CFGs make all paths explicit.

---

## Basic Blocks

**A maximal sequence of statements with:**
- Exactly **one entry point** and **one exit point**
- **No branching** except at the end

```ocaml
(* This is ONE basic block: *)
let x = 5
let y = x + 3
let z = y * 2
```

If the first statement runs, they all run.

---

## Identifying Basic Block Boundaries

A new basic block starts at:
1. The **first statement** of a function
2. Any **branch target** (after if/else/loop headers)
3. Any statement **immediately after** a branch or jump

```ocaml
let example x =
  let a = 1 in          (* --- Block 1 starts (function entry) *)
  let b = 2 in          (*     still Block 1                   *)
  let c =               (*     Block 1 ends (branch)           *)
    if a > b then
      a + b             (* --- Block 2 starts (branch target)  *)
    else
      a - b             (* --- Block 3 starts (branch target)  *)
  in
  print_int c           (* --- Block 4 starts (merge point)    *)
```

---

## Control Flow Graph (CFG) Definition

**A directed graph G = (N, E) where:**
- **N** = set of basic blocks (nodes)
- **E** = set of control flow edges between blocks
- **Entry node** = first block executed
- **Exit node(s)** = blocks that end with return/program end

```
An edge (A, B) means: after block A executes,
control *may* transfer to block B.
```

---

## CFG: Sequential Code

```ocaml
let simple () =
  let a = 1 in       (* Block 1 *)
  let b = 2 in
  let c = a + b in
  c
```

```
  ENTRY -> [B1: a=1; b=2; c=a+b; return c] -> EXIT
```

One block, one path -- the simplest possible CFG.

---

## CFG: If-Else Statement

```ocaml
let conditional x =
  let result =               (* Block 1 *)
    if x > 0 then
      x * 2                  (* Block 2 *)
    else
      x * (-1)               (* Block 3 *)
  in
  print_int result;           (* Block 4 *)
  result
```

```
        +-------+
        | ENTRY |
        +-------+
            |
            v
      +----------+
      | B1:      |
      | x > 0 ? |
      +----------+
       /        \
   True        False
     /            \
+--------+   +----------+
| B2:    |   | B3:      |
| r=x*2  |   | r=x*(-1) |
+--------+   +----------+
     \            /
      \          /
       v        v
      +----------+
      | B4:      |
      | print(r) |
      | return r |
      +----------+
           |
           v
        +------+
        | EXIT |
        +------+
```

---

## CFG: While Loop (Code)

```ocaml
let loop n =
  let i = ref 0 in             (* Block 1 *)
  while !i < n do              (* Block 2 (loop header) *)
    print_int !i;              (* Block 3 (loop body) *)
    i := !i + 1
  done;
  !i                           (* Block 4 *)
```

The `while` creates 4 blocks: init, header, body, exit.

---

## CFG: While Loop (Diagram)

```
  ENTRY -> [B1: i=0] -> [B2: i<n?] -True-> [B3: print(i); i=i+1]
                              |                      |
                            False                back edge
                              v                      |
                         [B4: return i]     B3 -------> B2
                              |
                             EXIT
```

The **back edge** from B3 to B2 creates a cycle -- this is the loop.

---

## Predecessors and Successors

- **pred(B)** = blocks that transfer control TO B
- **succ(B)** = blocks B transfers control TO

From the while-loop: `B1:{pred=ENTRY, succ=B2}`, `B2:{pred=B1/B3, succ=B3/B4}`, `B3:{pred=B2, succ=B2}`, `B4:{pred=B2, succ=EXIT}`

Predecessors and successors drive dataflow analysis.

---

## CFG: Nested Structures

```ocaml
let complex x y =
  let result =
    if x > 0 then begin                (* B1 *)
      for i = 0 to y - 1 do           (* B2 (loop header) *)
        if i mod 2 = 0 then           (* B3 *)
          print_int i                  (* B4 *)
        (* else: continue *)           (* B5 *)
      done;
      x + y                            (* B6 *)
    end else
      0                                (* B7 *)
  in
  result                               (* B8 *)
```

```
       +-------+
       | ENTRY |
       +-------+
           |
           v
       +--------+
       |B1:x>0? |
       +--------+
       /        \
      T          F
     /            \
  +--------+   +--------+
  |B2:loop |   |B7:     |
  |header  |<--+r = 0   |--+
  +--------+   +--------+  |
   /     \                  |
  T       F                 |
 /         \                |
+-------+ +------+         |
|B3:    | |B6:   |         |
|i%2==0?| |r=x+y |         |
+-------+ +------+         |
 /    \       \             |
T      F       \            |
|      |        \           |
+--+ +--+       |          |
|B4| |B5|       |          |
+--+ +--+       |          |
 \    /         |          |
  v  v          v          |
  [B2]       +--------+   |
             |B8:     |<--+
             |return r|
             +--------+
```

---

## Building CFGs from OCaml Code

Systematic algorithm for CFG construction:

```ocaml
type basic_block = {
  label : string;
  mutable statements : stmt list;
  mutable successors : basic_block list;
  mutable predecessors : basic_block list;
}

let make_block label =
  { label; statements = []; successors = []; predecessors = [] }

let add_statement block stmt =
  block.statements <- block.statements @ [stmt]

let add_edge source target =
  source.successors <- target :: source.successors;
  target.predecessors <- source :: target.predecessors
```

---

## CFG Construction Algorithm

```ocaml
let build_cfg ast_node =
  (** Build a CFG from an AST. *)
  let entry = make_block "ENTRY" in
  let exit_block = make_block "EXIT" in
  let blocks = ref [] in

  let rec process_stmts stmts current_block =
    List.fold_left (fun block stmt ->
      if is_branch stmt then           (* if/while/for *)
        handle_branch stmt block blocks
      else if is_return stmt then begin
        add_statement block stmt;
        add_edge block exit_block;
        make_block (new_label ())
      end else begin
        add_statement block stmt;
        block
      end
    ) current_block stmts
  in

  let last = process_stmts ast_node.body entry in
  add_edge last exit_block;
  (entry, exit_block, !blocks)
```

---

## Lesson 2: The Dataflow Analysis Framework

How do we compute program properties over CFGs?

```
Control Flow Graph   +   Dataflow Framework
   (structure)           (reasoning engine)
                    =
         Program Properties
     (reaching defs, live vars, ...)
```

The framework is **general** -- swap the lattice and transfer functions to get different analyses.

---

## The Three Pillars of Dataflow Analysis

```
+------------------+     +--------------------+     +-------------------+
|    LATTICE       |     | TRANSFER FUNCTIONS |     | FIXPOINT          |
|                  |     |                    |     | COMPUTATION       |
| What info do we  |     | How does each      |     | How do we find    |
| track?           |     | statement change   |     | the stable        |
|                  |     | the info?          |     | solution?         |
| (sets, values,   |     |                    |     |                   |
|  properties)     |     | f: L -> L          |     | Iterate until     |
|                  |     |                    |     | nothing changes   |
+------------------+     +--------------------+     +-------------------+
```

Together, these guarantee:
- **Correctness** -- results account for all paths
- **Termination** -- algorithm always finishes
- **Uniqueness** -- one well-defined solution

---

## Lattice Theory for Dataflow

A **lattice** (L, <=) is a partially ordered set where every pair has:
- A **join** (least upper bound): a V b
- A **meet** (greatest lower bound): a ^ b

```
For Reaching Definitions, L = powerset of definitions:

         {d1, d2, d3}        <- TOP (all definitions)
        /     |      \
   {d1,d2} {d1,d3} {d2,d3}
      |    \  |  /    |
     {d1}  {d2}  {d3}
        \    |    /
           { }                <- BOTTOM (no definitions)
```

- **Join (V)** = set union (U) -- "may" analysis
- **Meet (^)** = set intersection (n) -- "must" analysis

---

## Partial Orders

A **partial order** on a set S is a relation <= that is:

- **Reflexive:** a <= a for all a
- **Antisymmetric:** if a <= b and b <= a, then a = b
- **Transitive:** if a <= b and b <= c, then a <= c

**Example:** Set inclusion (subset-of) on powerset of {a, b}:
`{} <= {a} <= {a,b}` and `{} <= {b} <= {a,b}`, but `{a}` and `{b}` are **incomparable**.

---

## Hasse Diagrams

A Hasse diagram visualizes a partial order (draw edges only for immediate successors):

```
Powerset of {a,b}:        Divisors of 12:

     {a,b}                      12
     /   \                     /   \
   {a}   {b}                 4     6
     \   /                   |  X  |
      {}                     2     3
                              \   /
                                1
```

Read bottom-to-top: higher = "larger" in the ordering.

---

## Fixed-Point Theorems

**Knaster-Tarski Theorem:** If f is a monotone function on a complete lattice L, then f has a least fixed point.

**Why this matters for dataflow analysis:**
- Our transfer functions are monotone (adding facts never removes facts)
- The powerset lattice is complete
- Therefore iterative analysis **always converges** to a unique solution

**Monotone:** if x <= y, then f(x) <= f(y)

---

## Ascending Chain Condition

**Definition:** A lattice satisfies the ACC if every ascending chain eventually stabilizes:

```
a0 <= a1 <= a2 <= ... <= ak = ak+1 = ...
```

**Termination guarantee:** If the lattice has ACC and transfer functions are monotone, fixpoint iteration terminates in at most **height(L)** steps.

**Powerset lattice** P(S): height = |S|, so reaching definitions converges in at most |defs| iterations.

---

## Transfer Functions

Each basic block B has a transfer function: **f_B : L -> L**

For reaching definitions, the transfer function is:

```
OUT[B] = gen[B] U (IN[B] - kill[B])
```

Where:
- **gen[B]** = definitions created in block B
- **kill[B]** = definitions overwritten by block B
- **IN[B]** = definitions reaching block B's entry
- **OUT[B]** = definitions surviving past block B

```
         IN[B]
           |
           v
    +-------------+
    | Block B     |
    |             |
    | - kill[B]   |  Remove overwritten defs
    | + gen[B]    |  Add new defs
    |             |
    +-------------+
           |
           v
         OUT[B]
```

---

## Combining Information at Merge Points

When control flow merges, we must combine dataflow facts:

```
  OUT[B1]     OUT[B2]
      \         /
       v       v
    +-----------+
    | MERGE     |
    | IN[B3] =  |
    |  combine( |
    |  OUT[B1], |
    |  OUT[B2]) |
    +-----------+
```

**May analysis** (reaching defs): IN[B] = U { OUT[P] | P in pred(B) }
- Union: a definition reaches if it comes from ANY predecessor

**Must analysis** (available exprs): IN[B] = n { OUT[P] | P in pred(B) }
- Intersection: expression available only if from ALL predecessors

---

## Fixpoint Computation Algorithm

```ocaml
let fixpoint_analysis cfg ~direction:_ =
  (** Generic iterative dataflow analysis. *)
  (* Step 1: Initialize all blocks *)
  let in_  = Hashtbl.create 16 in
  let out_ = Hashtbl.create 16 in
  List.iter (fun block ->
    Hashtbl.replace in_  block.label (initial_value ());
    Hashtbl.replace out_ block.label (initial_value ())
  ) cfg.blocks;

  (* Step 2: Iterate until stable *)
  let changed = ref true in
  let iteration = ref 0 in
  while !changed do
    changed := false;
    incr iteration;
    List.iter (fun block ->
      let old_out = Hashtbl.find out_ block.label in

      (* Combine from predecessors *)
      let new_in = combine
        (List.map (fun p -> Hashtbl.find out_ p.label)
           block.predecessors)
      in
      Hashtbl.replace in_ block.label new_in;

      (* Apply transfer function *)
      let new_out = transfer block new_in in
      Hashtbl.replace out_ block.label new_out;

      if not (DefSet.equal new_out old_out) then
        changed := true
    ) cfg.blocks
  done;

  Printf.printf "Fixpoint reached after %d iterations\n"
    !iteration
```

---

## Forward vs Backward Analysis

```
FORWARD (entry -> exit)             BACKWARD (exit -> entry)
========================            =========================

Direction of information:           Direction of information:
    -------->                           <--------

IN[B] = U OUT[pred(B)]             OUT[B] = U IN[succ(B)]
OUT[B] = f(IN[B])                  IN[B] = f(OUT[B])

Answers: "What happened                Answers: "What will
 before this point?"                 happen after this point?"

Examples:                           Examples:
- Reaching Definitions              - Live Variables
- Available Expressions             - Very Busy Expressions
- Constant Propagation              - Anticipable Expressions
```

---

## May vs Must Analysis

| Property | May Analysis | Must Analysis |
|----------|-------------|---------------|
| **Question** | "Could this be true on SOME path?" | "Is this true on ALL paths?" |
| **Merge operator** | Union (U) | Intersection (n) |
| **Soundness** | Over-approximates (safe) | Under-approximates (safe) |
| **False results** | May report too much | May miss some things |
| **Initial value** | Empty set (bottom) | Universal set (top) |
| **Example** | Reaching Definitions | Available Expressions |

**May analysis** is pessimistic: assumes anything *could* happen.
**Must analysis** is optimistic: only reports what *definitely* happens.

---

## Lesson 3: Reaching Definitions Analysis

**The fundamental question:** For each variable use, which assignments *might* have provided that value?

```ocaml
let x = 1 in        (* d1: definition of x *)
let y = 2 in        (* d2: definition of y *)
let x =
  if cond then 3     (* d3: definition of x *)
  else x
in
let z = x + y in    (* Which definition of x reaches here? *)
                    (* Answer: d1 OR d3 (depends on cond) *)
```

This is the "Hello World" of dataflow analysis.

---

## Gen and Kill Sets

For each basic block, we compute:

- **gen[B]** = definitions generated (created) in B
- **kill[B]** = definitions killed (overwritten) by B

```ocaml
(* Block B: *)
let x = a + b in  (* d1: generates def of x, kills all other defs of x *)
let y = c * d in  (* d2: generates def of y, kills all other defs of y *)
```

```
gen[B]  = {d1, d2}
kill[B] = {all other definitions of x} U {all other definitions of y}
```

Key insight: the **last** definition of a variable in a block is the one that survives in gen[B].

---

## Gen/Kill: Step-by-Step Construction

Walk through a block line-by-line, maintaining running gen and kill sets:

```
Block B:               running gen    running kill
  x = a + b   (d1)    {d1}           {other defs of x}
  y = x * 2   (d2)    {d1, d2}       {other defs of x, y}
  x = y + 1   (d3)    {d2, d3}       {other defs of x, y}
  z = x       (d4)    {d2, d3, d4}   {other defs of x, y, z}
```

Note: d3 **replaces** d1 in gen (both define x, last one wins).

---

## Gen/Kill: Multiple Definitions

When a variable is defined more than once in a block:

```
x = 1       (d1)    gen so far: {d1}
y = x       (d2)    gen so far: {d1, d2}
x = y + 1   (d3)    gen so far: {d2, d3}  <- d1 removed!
```

Only d3 (the **last** def of x) survives in gen[B].
Both d1 and d3 contribute to kill[B] (kill all *other* defs of x in the program).

---

## Gen/Kill: LHS vs RHS

**LHS** (left-hand side) = **defines** a variable:
```
x = expr    <- x is defined (goes into gen, contributes to kill)
```

**RHS** (right-hand side) = **uses** variables:
```
x = a + b   <- a and b are used (relevant for live variables)
```

Extracting defined/used variables from each statement is the foundation for all gen/kill-style analyses.

---

## Reaching Definitions: Dataflow Equations

**Forward may-analysis:**

```
IN[B]  = U { OUT[P] | P is a predecessor of B }

OUT[B] = gen[B] U (IN[B] - kill[B])
```

Initialization:
```
IN[ENTRY] = {} (no definitions reach the entry)
OUT[B] = {} for all blocks initially
```

Termination guaranteed because:
- The lattice (powerset of definitions) is finite
- Transfer functions are monotone
- Sets can only grow, and the lattice has a finite top

---

## Reaching Definitions: Worked Example

```ocaml
let example x =
  let a = 1 in           (* Block 1: d1 (def of a) *)
  let b = 2 in           (*          d2 (def of b) *)
  let a, b, c =
    if x > 0 then
      let a = 3 in       (* Block 2: d3 (def of a) *)
      let c = a in       (*          d4 (def of c) *)
      (a, b, c)
    else
      let b = 4 in       (* Block 3: d5 (def of b) *)
      let c = b in       (*          d6 (def of c) *)
      (a, b, c)
  in
  Printf.printf "%d %d %d\n" a b c;  (* Block 4: uses a, b, c *)
  a + b + c
```

```
         +------+
         |ENTRY |
         +------+
             |
             v
        +---------+
        | B1:     |
        | a=1 (d1)|
        | b=2 (d2)|
        +---------+
         /       \
        v         v
  +----------+ +----------+
  | B2:      | | B3:      |
  | a=3 (d3) | | b=4 (d5) |
  | c=a (d4) | | c=b (d6) |
  +----------+ +----------+
        \       /
         v     v
      +-------------+
      | B4:         |
      | print(a,b,c)|
      | return ...  |
      +-------------+
```

---

## Step 1: Compute Gen/Kill Sets

| Block | gen | kill |
|-------|-----|------|
| B1 | {d1, d2} | {} |
| B2 | {d3, d4} | {d1} (d3 kills d1: both define a) |
| B3 | {d5, d6} | {d2} (d5 kills d2: both define b) |
| B4 | {} | {} |

**Why kill[B1] = {}?**
B1 is the first block. There are no prior definitions of `a` or `b` to kill.

**Why kill[B2] includes d1?**
d3 (`a = 3`) overwrites d1 (`a = 1`). Any definition of `a` that enters B2 is killed.

---

## Step 2: Iteration 0 (Initialize)

| Block | IN | OUT |
|-------|-----|------|
| B1 | {} | {} |
| B2 | {} | {} |
| B3 | {} | {} |
| B4 | {} | {} |

All sets start empty. Now we iterate.

---

## Step 3: Iteration 1

**B1:** IN = {} (entry block, no predecessors)
```
OUT[B1] = gen[B1] U (IN[B1] - kill[B1])
        = {d1,d2} U ({} - {})
        = {d1, d2}                          ** CHANGED **
```

**B2:** IN = OUT[B1] = {d1, d2}
```
OUT[B2] = gen[B2] U (IN[B2] - kill[B2])
        = {d3,d4} U ({d1,d2} - {d1})
        = {d3,d4} U {d2}
        = {d2, d3, d4}                     ** CHANGED **
```

**B3:** IN = OUT[B1] = {d1, d2}
```
OUT[B3] = gen[B3] U (IN[B3] - kill[B3])
        = {d5,d6} U ({d1,d2} - {d2})
        = {d5,d6} U {d1}
        = {d1, d5, d6}                     ** CHANGED **
```

**B4:** IN = OUT[B2] U OUT[B3] = {d2,d3,d4} U {d1,d5,d6}
```
IN[B4]  = {d1, d2, d3, d4, d5, d6}        ** CHANGED **
OUT[B4] = {} U ({d1,d2,d3,d4,d5,d6} - {})
        = {d1, d2, d3, d4, d5, d6}        ** CHANGED **
```

---

## Step 4: Iteration 2

Recompute all blocks with the new values:

| Block | IN | OUT | Changed? |
|-------|-----|------|----------|
| B1 | {} | {d1, d2} | No |
| B2 | {d1, d2} | {d2, d3, d4} | No |
| B3 | {d1, d2} | {d1, d5, d6} | No |
| B4 | {d1,d2,d3,d4,d5,d6} | {d1,d2,d3,d4,d5,d6} | No |

**No changes!** Fixpoint reached after 2 iterations.

---

## Step 5: Interpret the Results

At Block 4 entry, all six definitions reach: {d1, d2, d3, d4, d5, d6}

What does this mean for each variable?

| Variable | Reaching definitions | Interpretation |
|----------|---------------------|----------------|
| `a` | d1 (`a=1`) and d3 (`a=3`) | Value is 1 or 3 depending on branch |
| `b` | d2 (`b=2`) and d5 (`b=4`) | Value is 2 or 4 depending on branch |
| `c` | d4 (`c=a`) and d6 (`c=b`) | Value depends on branch taken |

**Application:** A compiler cannot constant-fold `a + b + c` because multiple definitions reach the use site.

---

## Reaching Definitions: Complete Iteration Table

```
+-------+-----+---+---+---+-----+-----+-----+-----+-----+
| Iter  |     | B1     | B2     | B3     | B4              |
|       |     | IN OUT | IN OUT | IN OUT | IN         OUT  |
+-------+-----+--------+--------+--------+-----------------+
| Init  |     | {} {}  | {} {}  | {} {}  | {}          {}  |
+-------+-----+--------+--------+--------+-----------------+
|   1   | IN  | {}     |{d1,d2} |{d1,d2} |{d1,d2,d3,      |
|       |     |        |        |        | d4,d5,d6}       |
|       | OUT |{d1,d2} |{d2,d3, |{d1,d5, |{d1,d2,d3,      |
|       |     |        | d4}    | d6}    | d4,d5,d6}       |
+-------+-----+--------+--------+--------+-----------------+
|   2   |     | (no changes -- fixpoint reached)            |
+-------+-----+--------+--------+--------+-----------------+
```

---

## Worked Example: Reaching Defs with Loop

```ocaml
let x = ref 1 in          (* B1: d1 *)
while !x < 10 do          (* B2: loop header *)
  x := !x + 1             (* B3: d2 *)
done;
print_int !x               (* B4 *)
```

| Iter | B1 OUT | B2 IN | B3 OUT | B4 IN |
|------|--------|-------|--------|-------|
| Init | {} | {} | {} | {} |
| 1 | {d1} | {d1} | {d2} | {d1} |
| 2 | {d1} | {d1,d2} | {d2} | {d1,d2} |
| 3 | no changes -- fixpoint |

The **back edge** B3->B2 causes iteration 2 to add d2 to B2's IN.

---

## Worked Example: Live Variables with Loop

```ocaml
let x = ref 1 in          (* B1: def={x} *)
while !x < 10 do          (* B2: use={x} *)
  x := !x + 1             (* B3: def={x}, use={x} *)
done;
print_int !x               (* B4: use={x} *)
```

Working **backward** (OUT[B] = U IN[succ(B)]):

| Iter | B4 IN | B3 IN | B2 IN | B1 IN |
|------|-------|-------|-------|-------|
| Init | {x} | {} | {} | {} |
| 1 | {x} | {x} | {x} | {} |
| 2 | no changes -- fixpoint |

x is live at every point because it is always used before the program ends.

---

## Worked Example: Available Expressions

```ocaml
let t = a + b in     (* B1: e_gen={a+b} *)
let c, a =           (* B2 header *)
  if cond then
    (a + b, a)        (* B3: e_gen={a+b} *)
  else
    (c, 5)            (* B4: e_kill={a+b} *)
in
let d = a + b in     (* B5 *)
```

| Iter | B1 OUT | B3 OUT | B4 OUT | B5 IN |
|------|--------|--------|--------|-------|
| Init | U | U | U | U |
| 1 | {a+b} | {a+b} | {} | {a+b} n {} = {} |

At B5, `a+b` is **not** available (killed on the else path). Must recompute.

---

## Lesson 4: Live Variables Analysis

**The question:** Which variables might be **used in the future** before being redefined?

```ocaml
let a = 1 in        (* Is 'a' live here? YES (used at line 4) *)
let _ = 2 in        (* Is 'b' live here? NO  (redefined at line 3) *)
let b = a + 3 in    (* Is 'a' live here? YES (used here) *)
Printf.printf "%d %d\n" a b
                    (* 'a' and 'b' are live (used here) *)
                    (* After this: nothing is live *)
```

A variable is **live** at a point if its current value might be read before being overwritten. A variable is **dead** if it will definitely be overwritten before any future use.

---

## Live Variables: Backward Analysis

Live variables flows **backward** -- from uses to definitions.

```
FORWARD (Reaching Defs):        BACKWARD (Live Variables):
  Information flows ------>       Information flows <------
  IN[B] = U OUT[pred(B)]         OUT[B] = U IN[succ(B)]
  OUT[B] = gen U (IN - kill)     IN[B] = use U (OUT - def)
```

Transfer function for live variables:
```
IN[B] = use[B] U (OUT[B] - def[B])
```

Where:
- **use[B]** = variables used in B before being defined in B
- **def[B]** = variables defined in B

---

## Live Variables: Worked Example

```ocaml
(* Using the same CFG structure: *)
let example x =
  let a = 1 in           (* B1: def={a,b}, use={} *)
  let b = 2 in
  let a, b, c =
    if x > 0 then
      let a = 3 in       (* B2: def={a,c}, use={a} (c=a uses a) *)
      let c = a in
      (a, b, c)
    else
      let b = 4 in       (* B3: def={b,c}, use={b} (c=b uses b) *)
      let c = b in
      (a, b, c)
  in
  Printf.printf "%d %d %d\n" a b c  (* B4: def={}, use={a,b,c} *)
```

Working **backward** from B4:

| Block | OUT | IN | Reasoning |
|-------|-----|-----|-----------|
| B4 | {} | {a, b, c} | Uses a, b, c; defines nothing |
| B2 | {a, b, c} | {a, b} | use={a} U ({a,b,c} - {a,c}) = {a} U {b} |
| B3 | {a, b, c} | {a, b} | use={b} U ({a,b,c} - {b,c}) = {b} U {a} |
| B1 | {a, b} | {} | use={} U ({a,b} - {a,b}) = {} |

At B1 entry: no variables need to be live (a and b are both defined here).

---

## Reaching Defs vs Live Variables

| Property | Reaching Definitions | Live Variables |
|----------|---------------------|----------------|
| Direction | Forward | Backward |
| Question | "Where did this value come from?" | "Will this value be used later?" |
| Lattice | Sets of definitions | Sets of variables |
| Transfer | OUT = gen U (IN - kill) | IN = use U (OUT - def) |
| Merge | Union (may) | Union (may) |
| Initialization | IN[entry] = {} | OUT[exit] = {} |
| Application | Dead code, constant prop. | Register allocation |

Both are **may analyses** using union at merge points: they track what *might* happen on some path.

---

## Lesson 5: Available Expressions Analysis

**The question:** Has an expression been computed on **all** paths reaching this point, with its operands unchanged?

```ocaml
let a = x + y in      (* x+y is now available *)
let b = a * 2 in
let x =
  if cond then
    let _ = x + y in   (* x+y is STILL available -- reuse it! *)
    x
  else
    5                  (* x changed -- x+y is KILLED *)
in
let d = x + y in      (* Is x+y available? NO (not on all paths) *)
```

**Application:** Common Subexpression Elimination (CSE) -- avoid recomputing expressions that are already available.

---

## Available Expressions: A Must Analysis

Unlike reaching defs and live variables, this is a **must analysis**:

```
An expression is available ONLY IF it has been computed
on ALL paths reaching this point.
```

This means we use **intersection** at merge points:

```
IN[B] = n { OUT[P] | P is a predecessor of B }

OUT[B] = e_gen[B] U (IN[B] - e_kill[B])
```

Where:
- **e_gen[B]** = expressions computed in B (and whose operands are not subsequently redefined in B)
- **e_kill[B]** = expressions whose operands are redefined in B

**Initialization:** IN[entry] = {}, all other IN[B] = U (universal set, all expressions)

---

## Available Expressions: Example

```ocaml
(* Statement 1: *) let a = x + y in    (* generates x+y *)
(* Statement 2: *) let b = a * 2 in    (* generates a*2 *)
(* if condition: *)
(*   Statement 3: *) (* c = x + y *)   (* generates x+y -- redundant! *)
(*   Statement 4: *) (* a = c + 1 *)   (* kills a*2, since a changed *)
(* Statement 5: *) (* print_int a *)
(* Statement 6: *) (* d = b + a *)
```

```
After S1: available = {x+y}
After S2: available = {x+y, a*2}
Branch:
  After S3: available = {x+y, a*2}  (x+y already available)
  After S4: available = {x+y, c+1}  (a*2 killed, c+1 generated)
Merge:
  After merge: {x+y, a*2} n {x+y, c+1} = {x+y}
  (only x+y is available on ALL paths)
```

---

## Three Analyses Compared

| Analysis | Direction | Merge Op | Type | Init (non-entry) | Application |
|----------|-----------|----------|------|-------------------|-------------|
| Reaching Defs | Forward | Union (U) | May | {} | Dead code elimination |
| Live Variables | Backward | Union (U) | May | {} | Register allocation |
| Available Exprs | Forward | Intersection (n) | Must | Universal set | CSE optimization |

```
May analysis (Union):         Must analysis (Intersection):

  {d1,d2}   {d2,d3}           {e1,e2}   {e2,e3}
      \       /                    \       /
       v     v                      v     v
   {d1,d2,d3}                     {e2}
   (anything possible)       (only what's certain)
```

---

## The General Dataflow Framework

All three analyses are instances of the same framework:

```
Framework = (L, V, T, F, d)
```

| Component | Meaning | Reaching Defs | Live Vars | Available Exprs |
|-----------|---------|---------------|-----------|-----------------|
| **L** | Lattice | P(Definitions) | P(Variables) | P(Expressions) |
| **V** | Merge op | Union | Union | Intersection |
| **T** | Transfer | gen U (IN-kill) | use U (OUT-def) | e_gen U (IN-e_kill) |
| **F** | Direction | Forward | Backward | Forward |
| **d** | Init | Bottom ({}) | Bottom ({}) | Top (all exprs) |

To create a NEW analysis, just fill in this table!

---

## Lesson 6: Interprocedural Analysis

So far: intraprocedural (single function). Real programs have many functions.

```ocaml
let sanitize input_str =
  Str.global_replace (Str.regexp_string "'") "''" input_str

let query_db user_input =
  let clean = sanitize user_input in    (* Is clean safe? *)
  let sql = Printf.sprintf
    "SELECT * FROM users WHERE name = '%s'" clean in
  execute sql
```

To know if `clean` is safe, we must analyze **across function boundaries**.

---

## Call Graphs

**Definition:** A directed graph where nodes are functions and edges are call relationships.

```ocaml
let helper param =
  param + 1

let process_data x y =
  let temp = x * 2 in
  let result1 = helper temp in
  let result2 = helper y in
  result1 + result2

let main () =
  let a = 5 in
  let b = 10 in
  let _output = process_data a b in
  ()
```

```
    +------+
    | main |
    +------+
        |
        v
  +--------------+
  | process_data |
  +--------------+
      /        \
     v          v
  +--------+ +--------+
  | helper | | helper |
  | (ctx1) | | (ctx2) |
  +--------+ +--------+
```

---

## Context Sensitivity

**Context-insensitive:** Merge all calls to the same function.

```
helper is called with temp AND y
=> param could be temp OR y
=> Result: imprecise
```

**Context-sensitive:** Distinguish calls by their calling context.

```
Context 1: main -> process_data -> helper(temp)
  => param = temp = x * 2

Context 2: main -> process_data -> helper(y)
  => param = y

=> Result: precise, but expensive
```

---

## Scalability Trade-offs

```
Precision
    ^
    |   * Full context-sensitive
    |      (exponential cost)
    |
    |         * k-limited call strings
    |            (polynomial cost)
    |
    |               * Context-insensitive
    |                  (linear cost)
    |
    +------------------------------------> Scalability
```

| Approach | Precision | Cost | Use Case |
|----------|-----------|------|----------|
| Context-insensitive | Low | O(n) | Quick scanning, millions of LOC |
| 1-level context | Medium | O(n * k) | Industrial tools (Infer, Coverity) |
| Full context | High | O(n * 2^k) | Small critical components |
| Summary-based | Medium | O(n * m) | Modular analysis, libraries |

---

## Summary-Based Analysis

Instead of re-analyzing a function at every call site, **precompute a summary:**

```ocaml
let helper param =
  let local_var = param + 1 in
  local_var
```

**Summary for helper:**
```
Input:  param (any value)
Output: param + 1
Side effects: none
Defines: local_var (local scope only)
Kills: nothing external
```

Apply the summary at each call site instead of inlining the function body. This is how real-world tools scale.

---

## Interprocedural Challenges

**1. Dynamic Dispatch**
```ocaml
let process handler data =
  handler#process data  (* Which process () is called? *)
```
The target depends on the runtime type of `handler`.

**2. Higher-Order Functions**
```ocaml
let apply func x =
  func x  (* func could be anything! *)

let _ = apply sanitize user_input
let _ = apply (fun x -> x) user_input  (* Not sanitized! *)
```

**3. Recursive Functions**
```
f calls g, g calls f => cycle in call graph
=> fixpoint computation on the call graph itself
```

---

## Hands-On Exercise Overview

**Exercise: Build a Mini Reaching Definitions Analyzer**

```ocaml
(* Given this target program: *)
let target () =
  let x = 1 in          (* d1 *)
  let y = 2 in          (* d2 *)
  let x =
    if condition then
      y + 3              (* d3 *)
    else x
  in
  let z = x + y in      (* uses x, y *)
  z
```

Tasks:
1. Build the CFG (identify basic blocks, draw edges)
2. Compute gen/kill sets for each block
3. Run fixpoint iteration by hand (fill in the table)
4. Implement the analysis in OCaml
5. Verify your manual results match the code output

---

## Exercise: Analysis Comparison

Apply all three analyses to one program:

```ocaml
let multi_analysis () =
  let a = x + y in       (* S1 *)
  let b = a * 2 in       (* S2 *)
  let a =
    if condition then
      let c = x + y in   (* S3 (repeated expression) *)
      c + 1               (* S4 (redefines a) *)
    else a
  in
  print_int a;            (* S5 *)
  let d = b + a in        (* S6 *)
  d
```

| Analysis | What to compute |
|----------|----------------|
| Reaching Definitions | Which assignments reach each statement? |
| Live Variables | Which variables are live at each point? |
| Available Expressions | Which expressions can be reused? |

Fill in the comparison table and identify optimization opportunities.

---

## Key Takeaways

**Foundational Concepts:**
- **CFGs** transform linear code into directed graphs capturing all execution paths
- **Basic blocks** group always-together statements, simplifying analysis
- **Dataflow analysis** systematically propagates facts along CFG edges

**The Framework:**
- **Lattices** define what we track and how to combine information
- **Transfer functions** model how statements change tracked information
- **Fixpoint iteration** finds the stable, correct solution

**Analysis Diversity:**
- Forward vs backward matches the reasoning direction
- May (union) vs must (intersection) reflects safety requirements
- The same framework powers many different analyses

---

## Common Pitfalls

1. **Confusing gen and kill sets** -- gen is what a block creates, kill is what it destroys
2. **Wrong merge operator** -- union for "may" analyses, intersection for "must" analyses
3. **Forgetting back edges** -- loops create cycles; the fixpoint handles them
4. **Stopping iteration too early** -- must check ALL blocks for stability, not just the last
5. **Mixing up IN and OUT** -- IN is at block entry, OUT is at block exit
6. **Ignoring initialization** -- must analyses start at top (universal set), may analyses at bottom (empty set)

---

## Next Module Preview

**Module 4: Dynamic Analysis and Runtime Techniques**

- Dynamic instrumentation and execution traces
- Runtime profiling and performance analysis
- Combining static + dynamic analysis (hybrid approaches)
- Fuzzing and automated test generation

**Prep:** Review Module 3 concepts, especially:
- Where static analysis hits its limits (aliasing, dynamic dispatch)
- Why runtime information can complement static results
- Practice manual fixpoint computation on complex CFGs

---

## Additional Resources

**Primary Reading:**
- [Static Program Analysis](https://cs.au.dk/~amoeller/spa/) -- Moeller & Schwartzbach (free online)
- Chapters 1-4 cover CFGs, dataflow, and reaching definitions

**Practice:**
- Implement the reaching definitions analyzer from the exercise
- Try adding available expressions to the same framework
- Construct CFGs for your own OCaml functions

**Review:**
- Set theory: union, intersection, difference, powerset
- Graph algorithms: BFS, DFS, topological sort
- Fixpoint theory: monotone functions on lattices

---

## Summary: The Big Picture

```
Source Code
    |
    v
  [AST]          Module 2: Structure
    |
    v
  [CFG]          Module 3: Control flow (today)
    |
    v
  [Dataflow]     Module 3: Property computation (today)
    |
    v
  [Results]      "Variable x may be uninitialized"
    |             "Expression a+b is redundant"
    v             "Definition d3 is dead code"
  [Action]       Fix the bug / optimize the code
```

Static analysis turns **code** into **actionable knowledge**, automatically and at scale.
