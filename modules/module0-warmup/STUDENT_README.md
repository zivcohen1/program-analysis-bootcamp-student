# Module 0: OCaml Warm-Up -- Student Guide

Welcome to Module 0! This module gives you a hands-on introduction to OCaml
before you dive into the program analysis exercises in Modules 2-6. Each
exercise is themed around concepts you will encounter throughout the bootcamp.

```
Exercise 1          Exercise 2           Exercise 3             Exercise 4           Exercise 5
OCaml Basics        Types & Recursion    Collections            Modules & Functors   Calculator Parser
  |                   |                    |                      |                    |
  v                   v                    v                      v                    v
let, functions      ADTs, pattern        List.map/fold,         module type,         ocamllex,
tuples, Printf     matching, Option     records, Map, Set      functors, MakeEnv    Menhir grammar
  |                   |                    |                      |                    |
  v                   v                    v                      v                    v
Previews:           Previews:            Previews:              Previews:            Previews:
Lexer helpers       shared_ast expr      Dataflow analysis      abstract_domains     Lab 2 parser
(Lab 2)             (Module 2)           (Module 3)             (Module 3-4)         (Lab 2)
```

**Exercises:** 5 (guided tutorials, no automated tests)
**Estimated time:** ~2 hours

> **How it works:** Each exercise is a standalone OCaml file with `(* EXERCISE: ... *)`
> markers. Fill in the code, run with `dune exec`, and compare your output
> against the expected output shown below.

---

## Table of Contents

1. [Environment Setup](#1-environment-setup)
2. [How These Exercises Work](#2-how-these-exercises-work)
3. [Exercise 1: OCaml Basics (~20 min)](#3-exercise-1-ocaml-basics-20-min)
4. [Exercise 2: Types and Recursion (~25 min)](#4-exercise-2-types-and-recursion-25-min)
5. [Exercise 3: Collections and Records (~25 min)](#5-exercise-3-collections-and-records-25-min)
6. [Exercise 4: Modules and Functors (~25 min)](#6-exercise-4-modules-and-functors-25-min)
7. [Exercise 5: Calculator Parser (~25 min)](#7-exercise-5-calculator-parser-25-min)
8. [Troubleshooting](#8-troubleshooting)
9. [What's Next](#9-whats-next)

---

## 1. Environment Setup

You need **OCaml**, **opam**, **dune**, and **menhir** installed.

**macOS:**

```bash
brew install opam
opam init -y && eval $(opam env)
opam install dune ounit2 menhir -y
```

**Ubuntu / Debian (or WSL on Windows):**

```bash
sudo apt install opam -y
opam init -y && eval $(opam env)
opam install dune ounit2 menhir -y
```

**Verify your setup:**

```bash
ocaml --version     # should print 4.14.x or higher
dune --version      # should print 3.x
menhir --version    # should print 2021xxxx or higher
```

See `resources/tools/installation-guides/ocaml-setup.md` for the full guide.

---

## 2. How These Exercises Work

Unlike Modules 2-6, there are **no OUnit2 tests** here. Instead:

1. **Open the starter file** and look for `(* EXERCISE: ... *)` markers.
2. **Replace the `failwith "TODO: ..."` stub** with your implementation.
3. **Build and run:**
   ```bash
   dune exec modules/module0-warmup/exercises/<exercise-name>/starter/main.exe
   ```
4. **Compare your output** against the expected output in this README.

**Important:**
- Always run `dune` commands from the **repository root**, not from inside an
  exercise directory.
- If you see `Fatal error: exception Failure("TODO: ...")`, it means you still
  have an unimplemented stub.
- Implement functions **in order** -- later ones may depend on earlier ones.

---

## 3. Exercise 1: OCaml Basics (~20 min)

**File:** `exercises/ocaml-basics/starter/main.ml`
**Run:**
```bash
dune exec modules/module0-warmup/exercises/ocaml-basics/starter/main.exe
```

### What You'll Implement

| Function | What It Does | Concept |
|----------|-------------|---------|
| `square` | Returns x * x | Basic function |
| `is_empty` | Checks if string is empty | String.length |
| `greet` | Returns "Hello, name!" | String concatenation |
| `is_digit` | Checks if char is '0'..'9' | Char comparison |
| `is_alpha` | Checks if char is letter/underscore | Multiple ranges |
| `classify_char` | Returns "digit"/"alpha"/"operator"/"unknown" | Using helper functions |
| `format_token` | Formats a (category, text) tuple | Tuple destructuring |
| `make_token` | Creates token from text string | String indexing |
| `format_pos` | Formats a (line, col) position | Printf.sprintf |
| `advance_pos` | Updates position after reading a char | Newline handling |

### Hints

- `String.length s` returns the length of `s`.
- `s.[0]` returns the first character of string `s`.
- `Printf.sprintf "line %d, col %d" line col` creates a formatted string.
- Characters can be compared with `<=`: `'0' <= c && c <= '9'`.

### Expected Output

```
=== Exercise 1: OCaml Basics ===

square 5 = 25
square (-3) = 9
is_empty "" = true
is_empty "hi" = false
greet "OCaml" = Hello, OCaml!

classify_char '7' = digit
classify_char 'x' = alpha
classify_char '+' = operator
classify_char '!' = unknown

format_token ("keyword", "if") = [keyword: if]
make_token "42" = [number: 42]
make_token "hello" = [identifier: hello]
make_token "+" = [symbol: +]
make_token "" = [empty: ]

format_pos (1, 1) = line 1, col 1
advance_pos (1,1) 'a' = line 1, col 2
advance_pos (1,3) '\n' = line 2, col 1
scan_positions "ab\ncd" = line 2, col 3

Done!
```

---

## 4. Exercise 2: Types and Recursion (~25 min)

**File:** `exercises/types-and-recursion/starter/main.ml`
**Run:**
```bash
dune exec modules/module0-warmup/exercises/types-and-recursion/starter/main.exe
```

### What You'll Implement

This exercise defines a tiny expression tree -- a miniature version of the AST
you will work with in Modules 2-6:

```ocaml
type op = Add | Sub | Mul

type expr =
  | Num of int
  | Var of string
  | BinOp of op * expr * expr
```

| Function | What It Does | Concept |
|----------|-------------|---------|
| `string_of_op` | Converts op to "+", "-", "*" | Pattern matching |
| `string_of_expr` | Pretty-prints expression tree | Recursive pattern matching |
| `count_nodes` | Counts nodes in tree | Tree recursion |
| `depth` | Computes tree depth | Tree recursion with max |
| `eval` | Evaluates expr, returns `int option` | Option type |
| `substitute` | Replaces Var with Num | Tree transformation |
| `vars_in` | Collects variable names | List.sort_uniq |
| `is_constant` | Checks if expr has no Vars | Using vars_in |
| `simplify` | Constant folding optimization | Bottom-up transformation |

### Hints

- When a function needs recursion, the stub says "add `[rec]` when ready". Just
  change `let` to `let rec`.
- For `eval`, match on `(eval left, eval right)` to handle the `option` pairs:
  ```ocaml
  match eval left, eval right with
  | Some l, Some r -> Some (... compute ...)
  | _ -> None
  ```
- For `simplify`, simplify children first, then check if both are `Num`.

### Expected Output

```
=== Exercise 2: Types and Recursion ===

string_of_expr e1 = (2 + 3)
string_of_expr e2 = (x * (1 + y))
string_of_expr e3 = ((10 + 20) - 5)

count_nodes e1 = 3
count_nodes e2 = 5
depth e1 = 2
depth e2 = 3

eval e1 = Some 5
eval e2 = None
eval e3 = Some 25

substitute "x" 3 e2 = (3 * (1 + y))
eval (substitute "x" 3 e2) = None
vars_in e2 = [x; y]
is_constant e1 = true
is_constant e2 = false
simplify e3 = 25
simplify e2 = (x * (1 + y))

Done!
```

---

## 5. Exercise 3: Collections and Records (~25 min)

**File:** `exercises/collections-and-records/starter/main.ml`
**Run:**
```bash
dune exec modules/module0-warmup/exercises/collections-and-records/starter/main.exe
```

### What You'll Implement

| Function | What It Does | Concept |
|----------|-------------|---------|
| `double_all` | Doubles each element | List.map |
| `keep_positive` | Keeps only positive elements | List.filter |
| `sum` | Sums all elements | List.fold_left |
| `has_duplicates` | Checks for duplicate strings | Sort + adjacent check |
| `make_assign` | Creates assignment record | Record construction |
| `format_assign` | Formats record as string | Record field access |
| `increment_value` | Creates new record with updated value | `{ a with ... }` syntax |
| `build_env` | Builds StringMap from pairs | fold + StringMap.add |
| `lookup_var` | Looks up variable in map | StringMap.find_opt |
| `all_vars` | Lists all variable names | StringMap.bindings |
| `assigned_vars` | Collects assigned vars into set | StringSet.add |
| `common_vars` | Intersects two StringSets | StringSet.inter |
| `make_counter` | Returns incrementing closure | ref cell |

### Hints

- `List.map (fun x -> x * 2) xs` applies the function to each element.
- `List.filter (fun x -> x > 0) xs` keeps elements where the function returns true.
- `List.fold_left (fun acc x -> acc + x) 0 xs` accumulates from left with initial value 0.
- `StringMap.add key value map` returns a new map with the binding added.
- `StringMap.find_opt key map` returns `Some value` or `None`.
- `StringMap.bindings map` returns a list of `(key, value)` pairs.
- Records: `{ var_name = "x"; value = 5; line = 1 }` and `{ a with value = 10 }`.
- `ref`: `let r = ref 0 in r := !r + 1; !r` creates, updates, and reads a ref.

### Expected Output

```
=== Exercise 3: Collections and Records ===

double_all [1; 2; 3] = [2; 4; 6]
keep_positive [-1; 3; 0; 5; -2] = [3; 5]
sum [1; 2; 3; 4] = 10
has_duplicates ["a"; "b"; "a"] = true
has_duplicates ["a"; "b"; "c"] = false

format_assign a1 = x = 5 (line 1)
format_assign a2 = y = 10 (line 2)
increment_value a1 3 = x = 8 (line 1)

lookup_var "x" = Some 1
lookup_var "y" = Some 2
lookup_var "w" = None
all_vars env = [x; y; z]

assigned_vars = {x, y}
common_vars = {y, z}

counter: 0, 1, 2

Done!
```

> **Note on counter output:** OCaml evaluates function arguments in an
> unspecified order. You might see `counter: 2, 1, 0` instead. Both are
> correct -- what matters is that each call returns a different number.

---

## 6. Exercise 4: Modules and Functors (~25 min)

**File:** `exercises/modules-and-functors/starter/main.ml`
**Run:**
```bash
dune exec modules/module0-warmup/exercises/modules-and-functors/starter/main.exe
```

### What You'll Implement

This exercise builds the **exact same lattice pattern** used in Modules 3-4.
The `LATTICE` module type + `MakeEnv` functor structure here is identical to
`lib/abstract_domains/`.

```
module type LATTICE = sig         <-- Interface (Part 1, provided)
  type t
  val bottom : t
  val top    : t
  val join   : t -> t -> t
  val equal  : t -> t -> bool
  val to_string : t -> string
end

module BoolLattice : LATTICE      <-- Example implementation (Part 2, provided)
module ThreeValueLattice : LATTICE <-- Your implementation (Part 3)
module MakeEnv(L : LATTICE)       <-- Functor (Part 4)
```

| Function | What It Does | Concept |
|----------|-------------|---------|
| `BoolPrint.to_string` | Converts bool to "T"/"F" | Simple module function |
| `ThreeValueLattice.join` | Computes least upper bound | Lattice operation |
| `ThreeValueLattice.equal` | Tests equality of lattice values | Structural equality |
| `ThreeValueLattice.to_string` | Converts lattice value to string | Pattern matching |
| `MakeEnv.lookup` | Looks up variable in env | Map.find_opt |
| `MakeEnv.update` | Adds binding to env | Map.add |
| `MakeEnv.join` | Joins two environments pointwise | Map.union |

### Hints

- `BoolLattice` is provided as a complete example. Follow the same pattern for
  `ThreeValueLattice`.
- The three-value lattice:
  ```
      Unknown (top)
       /      \
    Zero    Positive
       \      /
        Bot (bottom)
  ```
  `join Bot x = x`, `join x Bot = x`, `join x x = x`, otherwise `Unknown`.
- For `MakeEnv.join`, use `M.union`:
  ```ocaml
  M.union (fun _key v1 v2 -> Some (L.join v1 v2)) env1 env2
  ```

### Expected Output

```
=== Exercise 4: Modules and Functors ===

-- BoolLattice --
BoolPrint.to_string true = T
BoolPrint.to_string false = F
BoolLattice.join false true = true
BoolLattice.equal true true = true

-- ThreeValueLattice --
bottom = Bot
top = Unknown
join Bot Zero = Zero
join Zero Positive = Unknown
join Positive Positive = Positive
equal Zero Zero = true
equal Zero Positive = false

-- MakeEnv(ThreeValueLattice) --
empty = {}
lookup empty "x" = Bot
env1 = {x -> Zero, y -> Positive}
env2 = {x -> Positive, z -> Zero}
join env1 env2 = {x -> Unknown, y -> Positive, z -> Zero}

Done!
```

---

## 7. Exercise 5: Calculator Parser (~25 min)

**File:** `exercises/calculator-parser/starter/main.ml` (TODO: printing + eval)
**File:** `exercises/calculator-parser/starter/parser.mly` (TODO: grammar rules)
**Run:**
```bash
dune exec modules/module0-warmup/exercises/calculator-parser/starter/main.exe
```

### What You'll Implement

This exercise has **two files** to edit:

**parser.mly** -- add grammar rules:

| Rule | What It Produces | Provided? |
|------|-----------------|-----------|
| `expr PLUS expr` | `BinOp(Add, e1, e2)` | Yes (example) |
| `expr MINUS expr` | `BinOp(Sub, e1, e2)` | EXERCISE |
| `expr STAR expr` | `BinOp(Mul, e1, e2)` | EXERCISE |
| `expr SLASH expr` | `BinOp(Div, e1, e2)` | EXERCISE |
| `atom` fallthrough | `a` | Yes (provided) |
| `INT` literal | `Num n` | Yes (provided) |
| `IDENT` variable | `Var id` | EXERCISE |
| `LPAREN expr RPAREN` | `e` | EXERCISE |
| `MINUS atom %prec UMINUS` | `Neg a` | EXERCISE |

**main.ml** -- implement:

| Function | What It Does | Concept |
|----------|-------------|---------|
| `string_of_op` | Converts op to "+"/"-"/"*"/"/" | Pattern matching |
| `string_of_expr` | Pretty-prints AST | Recursive pattern matching |
| `eval` | Evaluates expression | Option + division by zero |

### Hints

- The lexer (`lexer.mll`) is fully provided -- you do not need to edit it.
- Parser rules follow this pattern:
  ```
  | e1 = expr MINUS e2 = expr  { BinOp (Sub, e1, e2) }
  ```
- `%prec UMINUS` tells Menhir to use the UMINUS precedence for unary minus:
  ```
  | MINUS a = atom %prec UMINUS  { Neg a }
  ```
- In `main.ml`, the types are defined in `ast.ml`:
  ```ocaml
  type op = Add | Sub | Mul | Div
  type expr = Num of int | Var of string | BinOp of op * expr * expr | Neg of expr
  ```

### Expected Output

```
=== Exercise 5: Calculator Parser ===

Input:  42
AST:    42
Result: 42

Input:  1 + 2
AST:    (1 + 2)
Result: 3

Input:  3 * 4 + 5
AST:    ((3 * 4) + 5)
Result: 17

Input:  (3 + 4) * 5
AST:    ((3 + 4) * 5)
Result: 35

Input:  10 - 3 - 2
AST:    ((10 - 3) - 2)
Result: 5

Input:  -7
AST:    (- 7)
Result: -7

Input:  x + 1
AST:    (x + 1)
Result: <cannot evaluate>

Done!
```

---

## 8. Troubleshooting

### "Fatal error: exception Failure("TODO: ...")"

You still have an unimplemented stub. Look for `failwith "TODO: ..."` in your
code and implement that function.

### "Error: Unbound value ..." or "Error: Unbound module ..."

Check for typos. In Exercise 4, make sure you use `L.bottom`, `L.join`, etc.
inside the functor (not `ThreeValueLattice.bottom`).

### "Error (warning 39): unused rec flag"

You added `rec` to a function that does not call itself. Either make the
function recursive or remove `rec`.

### "Error (warning 27): unused variable x"

You declared a variable but did not use it. Either use it (implement the
function) or prefix it with underscore: `_x`.

### Parser warnings about unused tokens

This is **expected** until you add the missing grammar rules in `parser.mly`.
The warnings will disappear once you add rules for `MINUS`, `STAR`, `SLASH`,
`IDENT`, `LPAREN`, `RPAREN`, and `UMINUS`.

### "Error: This expression has type ... but was expected of type ..."

Type mismatch. Common cases:
- Returning `int` where `int option` is expected: wrap with `Some`.
- Forgetting `Some`/`None` pattern match when using `eval`.
- Missing parentheses around negative numbers: `(-3)` not `-3`.

### Build succeeds but output is wrong

Check your logic:
- Is `is_alpha` handling `'_'` (underscore)?
- Is `advance_pos` resetting column to 1 on newline?
- Is `join Bot x` returning `x` (not `Unknown`)?
- Is `substitute` preserving other `Var` nodes it should not replace?

---

## 9. What's Next

With these exercises complete, you are ready for Module 2. Here is how each
exercise connects to what comes next:

| Exercise | Prepares You For |
|----------|-----------------|
| 1. OCaml Basics | Reading and writing OCaml fluently |
| 2. Types and Recursion | `Shared_ast.Ast_types` and all AST traversals (M2) |
| 3. Collections and Records | Dataflow analysis data structures (M3) |
| 4. Modules and Functors | `Abstract_domains` library (M3-4) |
| 5. Calculator Parser | Lab 2's Menhir parser |

Move on to **Module 1: Foundations of Program Analysis** for the conceptual
introduction to static vs dynamic analysis, then **Module 2: Code
Representation & ASTs** where you will use OCaml to build real analysis tools.
