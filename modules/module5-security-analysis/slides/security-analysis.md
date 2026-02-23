---
title: "Module 5: Security Analysis"
theme: white
revealOptions:
  transition: slide
  slideNumber: true
---

# Security Analysis

## Module 5 — Program Analysis Bootcamp

---

## Learning Objectives

1. Implement a **taint lattice** satisfying `ABSTRACT_DOMAIN`
2. Define **security configurations** (sources, sinks, sanitizers)
3. Build **forward taint propagation** using abstract transfer functions
4. Track **implicit information flows** via program-counter taint
5. Detect **OWASP vulnerability patterns** (SQLi, XSS, cmd injection)
6. Evaluate **precision and limitations** of taint analysis

---

## Prerequisites Review

From Module 4, you already know:

```
module type ABSTRACT_DOMAIN = sig
  type t
  val bottom : t    val top : t
  val join : t -> t -> t
  val meet : t -> t -> t
  val leq : t -> t -> bool
  val widen : t -> t -> t
  ...
end
```

- `MakeEnv(D)`: variable → abstract value maps
- `eval_expr`: recursive expression evaluation
- `transfer_stmt`: statement-level abstract transformers

---

## The Leap from Module 4

**Module 4**: What numeric value does `x` hold?
- Sign domain: `{Bot, Neg, Zero, Pos, Top}`
- Interval domain: `[lo, hi]`
- Detects: division by zero, overflow

**Module 5**: Where does `x`'s data come from?
- Taint domain: `{Bot, Untainted, Tainted, Top}`
- Tracks: data provenance and trust
- Detects: injection attacks, data leaks

Same infrastructure, different question!

---

## Motivating Example: SQL Injection

```
user_input = get_param("name")      -- SOURCE
query = "SELECT * FROM users WHERE name = '" + user_input + "'"
exec_query(query)                    -- SINK
```

If `user_input = "'; DROP TABLE users; --"`:

```sql
SELECT * FROM users WHERE name = ''; DROP TABLE users; --'
```

**Taint analysis detects this**: `get_param` → tainted → `exec_query` = vulnerability!

---

## Taint Analysis Core Idea

```
  Source              Propagation           Sink
  ------              -----------           ----
  get_param() ──→  x = source_val   ──→  exec_query(x)
  read_cookie()     y = x + z             send_response(y)
  read_input()      z = f(x)              exec_cmd(z)
       │                 │                      │
   [Tainted]     [Tainted spreads]    [Check: tainted arg?]
                                      [YES → vulnerability!]
```

Three-phase pipeline:
1. **Source** introduces taint
2. **Propagation** spreads taint through computation
3. **Sink** checks for tainted arguments

---

## Sources, Sinks, Sanitizers

| Category | Examples | OWASP Relevance |
|----------|----------|-----------------|
| **Sources** | `get_param`, `read_cookie`, `read_input` | Untrusted input entry points |
| **Sinks** | `exec_query`, `exec_cmd`, `send_response` | Security-sensitive operations |
| **Sanitizers** | `escape_sql`, `html_encode`, `shell_escape` | Input validation / encoding |

Sources **create** taint, sinks **consume** (and check) it, sanitizers **remove** it.

---

## The Taint Lattice

```
      Top          "may be tainted or untainted"
     /   \         → treat as tainted (sound)
 Tainted  Untainted
     \   /
      Bot          "unreachable"
```

- **Bot**: unreachable code (no information)
- **Untainted**: definitely clean data
- **Tainted**: definitely from untrusted source
- **Top**: unknown — could be either (conservative: treat as tainted)

This is a flat lattice, just like the sign domain!

---

## Taint Lattice Operations

**Join** (least upper bound):

| join | Bot | Untainted | Tainted | Top |
|------|-----|-----------|---------|-----|
| **Bot** | Bot | Untainted | Tainted | Top |
| **Untainted** | Untainted | Untainted | Top | Top |
| **Tainted** | Tainted | Top | Tainted | Top |
| **Top** | Top | Top | Top | Top |

- `join Tainted Untainted = Top` (might be either → treat as tainted)
- `widen = join` (finite lattice, no need for special widening)

---

## Taint Lattice vs Sign Lattice

```
   Sign Domain              Taint Domain

      Top                      Top
     / | \                    /   \
   Neg Zero Pos          Tainted Untainted
     \ | /                    \   /
      Bot                      Bot
```

Both are **flat lattices** satisfying `ABSTRACT_DOMAIN`.
Same `join`, `meet`, `leq` patterns — different interpretation!

- Sign: "what value?"  →  Taint: "what trust level?"
- Pos/Neg/Zero: concrete property  →  Tainted/Untainted: security property

---

## Security Configuration

```ocaml
type source = {
  source_name : string;       (* e.g. "get_param" *)
  source_description : string;
}

type sink = {
  sink_name : string;         (* e.g. "exec_query" *)
  sink_param_index : int;     (* which arg to check *)
  sink_vuln_type : string;    (* e.g. "sql-injection" *)
}

type sanitizer = {
  sanitizer_name : string;    (* e.g. "escape_sql" *)
  sanitizer_cleans : string list; (* ["sql-injection"] *)
}
```

Matched against `Call(name, args)` AST nodes — no AST changes needed!

---

## Forward Taint Propagation

**Expression evaluation rules:**

| Expression | Taint Rule |
|-----------|------------|
| `IntLit n` | → Untainted (constants are clean) |
| `BoolLit b` | → Untainted |
| `Var x` | → `lookup x env` |
| `BinOp(op, e1, e2)` | → `propagate (eval e1) (eval e2)` |
| `UnaryOp(op, e)` | → `eval e` |
| `Call(source, _)` | → Tainted (if source in config) |
| `Call(sanitizer, _)` | → Untainted (if sanitizer in config) |
| `Call(other, _)` | → Top (unknown function) |

Key insight: **taint propagates through binary operations** — if either operand is tainted, the result is tainted.

---

## Propagation Worked Example

```
1: input = get_param("q")       -- input: Tainted (source)
2: prefix = "SELECT * WHERE "   -- prefix: Untainted (literal)
3: query = prefix + input        -- query: Tainted (propagation!)
4: safe = escape_sql(input)      -- safe: Untainted (sanitizer)
5: safe_q = prefix + safe        -- safe_q: Untainted
6: exec_query(query)             -- VULNERABILITY: tainted at sink!
```

Step-by-step environment:
```
After 1: {input → Tainted}
After 2: {input → Tainted, prefix → Untainted}
After 3: {... query → Tainted}     ← propagate(Untainted, Tainted) = Tainted
After 4: {... safe → Untainted}    ← sanitizer cleans taint
After 5: {... safe_q → Untainted}  ← propagate(Untainted, Untainted) = Untainted
Line  6: exec_query(query) → query is Tainted → ALERT!
```

---

## Taint Transfer Functions

```ocaml
let transfer_stmt env stmt =
  match stmt with
  | Assign (x, e) ->
    let v = eval_expr env e in
    Env.update x v env

  | If (_cond, then_body, else_body) ->
    let env_t = transfer_stmts env then_body in
    let env_e = transfer_stmts env else_body in
    Env.join env_t env_e

  | While (_cond, body) ->
    (* fixpoint with widening *)
    ...
```

Same structure as Module 4's abstract interpreter — the domain changed, not the algorithm!

---

## Vulnerability Detection

At each `Call(name, args)` that is a **sink**:

```ocaml
let check_call env config func_name call_name args =
  match find_sink config call_name with
  | None -> []   (* not a sink, no check needed *)
  | Some sink ->
    let arg = List.nth args sink.sink_param_index in
    let taint = eval_expr env arg in
    if is_potentially_tainted taint then
      [{ vuln_type = sink.sink_vuln_type;
         location = func_name;
         sink_name = call_name;
         ... }]
    else []
```

---

## Sanitizers: Cleaning Taint

```
input = get_param("q")          -- Tainted
safe = escape_sql(input)        -- Untainted (sanitizer!)
exec_query(safe)                -- OK: clean data at sink
```

Sanitizer rule in `eval_expr`:
```ocaml
| Call (name, _) when is_sanitizer config name ->
    Untainted    (* sanitizer output is clean *)
```

But sanitizers are **vulnerability-type-specific**:
- `escape_sql` cleans **sql-injection** but NOT **xss**
- `html_encode` cleans **xss** but NOT **sql-injection**

---

## Sanitizer Effectiveness

| Sanitizer | Cleans | Does NOT Clean |
|-----------|--------|----------------|
| `escape_sql` | sql-injection | xss, command-injection |
| `html_encode` | xss | sql-injection, command-injection |
| `shell_escape` | command-injection | sql-injection, xss |
| `validate_path` | path-traversal | sql-injection, xss |
| `validate_url` | open-redirect | sql-injection, xss |

A sanitizer is only effective if it cleans the **specific vulnerability type** checked by the sink.

---

## Information Flow: Explicit

**Explicit flow**: data dependency (direct assignment)

```
secret = get_param("password")   -- Tainted
x = secret                        -- Tainted (explicit flow)
y = x + 1                         -- Tainted (propagation)
```

This is what standard taint propagation tracks.

The taint follows the **data** — wherever the value goes, taint goes.

---

## Information Flow: Implicit

**Implicit flow**: control dependency

```
secret = get_param("pin")    -- Tainted
if secret == 1234:
    x = 1                    -- x gets info about secret!
else:
    x = 0                    -- x gets info about secret!
```

After this code, `x` reveals whether `secret == 1234`.
The value of `secret` **influences** `x` through the branch condition, not through direct assignment.

Standard taint propagation **misses** this!

---

## Handling Implicit Flows

**Program-counter taint** (`pc_taint`): tracks whether we're inside a branch controlled by tainted data.

```ocaml
let transfer_stmt ~pc_taint env stmt =
  match stmt with
  | Assign (x, e) ->
    let v = eval_expr env e in
    let v' = propagate v pc_taint in  (* combine with pc_taint! *)
    Env.update x v' env
  | If (cond, then_b, else_b) ->
    let cond_taint = eval_expr env cond in
    let new_pc = propagate pc_taint cond_taint in
    let env_t = transfer_stmts ~pc_taint:new_pc env then_b in
    let env_e = transfer_stmts ~pc_taint:new_pc env else_b in
    Env.join env_t env_e
```

When the branch condition is tainted, **every assignment inside the branch is tainted**.

---

## Implicit Flows Worked Example

```
1: secret = get_param("pin")    -- {secret: Tainted}, pc: Untainted
2: if secret == 1234:           -- cond_taint: Tainted
3:     x = 1                    -- pc_taint: Tainted → x: Tainted!
4: else:
5:     x = 0                    -- pc_taint: Tainted → x: Tainted!
6: y = x                        -- pc: Untainted, y: Tainted (from x)
```

Without `pc_taint`: `x = 1` makes x Untainted (it's a literal).
With `pc_taint`: `propagate(Untainted, Tainted) = Tainted`. Correct!

---

## OWASP: SQL Injection (CWE-89)

```
input = get_param("search")       -- SOURCE
query = "SELECT * FROM t WHERE " + input
exec_query(query)                  -- SINK: sql-injection
```

**Detection pattern:**
- Source: `get_param` → Tainted
- Propagation: string concat spreads taint
- Sink: `exec_query` checks param 0

**Fix:** `safe_input = escape_sql(input)` before building query

---

## OWASP: XSS (CWE-79)

```
input = get_param("name")         -- SOURCE
html = "<h1>" + input + "</h1>"
send_response(html)               -- SINK: xss
```

**Reflected XSS**: user input is echoed directly into HTML response.

**Detection:** `send_response` with tainted arg → xss vulnerability

**Fix:** `safe = html_encode(input)` before embedding in HTML

---

## OWASP: Command Injection (CWE-78)

```
filename = get_param("file")      -- SOURCE
cmd = "cat " + filename
exec_cmd(cmd)                      -- SINK: command-injection
```

If `filename = "; rm -rf /"`:
```bash
cat ; rm -rf /
```

**Fix:** `safe = shell_escape(filename)` or avoid shell commands entirely

---

## OWASP: Path Traversal + Open Redirect

**Path Traversal (CWE-22):**
```
path = get_param("page")          -- SOURCE
open_file(path)                    -- SINK: path-traversal
```
If `path = "../../etc/passwd"` → reads sensitive file

**Open Redirect (CWE-601):**
```
url = get_param("next")           -- SOURCE
redirect(url)                      -- SINK: open-redirect
```
If `url = "https://evil.com"` → phishing attack

---

## Putting It All Together

```
                    Security Config
                    (sources, sinks, sanitizers)
                         │
  AST ──→ Taint Propagation ──→ Sink Checking ──→ Vulnerabilities
           │                      │                    │
     eval_expr uses          check_call at           format and
     config to mark          each Call node           report
     sources/sanitizers
```

The analysis pipeline:
1. Parse program → AST (existing infrastructure)
2. Configure sources, sinks, sanitizers
3. Forward taint propagation (abstract interpretation)
4. Check every sink call for tainted arguments
5. Report vulnerabilities with severity and location

---

## Limitations and False Positives

**Over-approximation** (sound but imprecise):
- `join Tainted Untainted = Top` → treated as tainted
- Branches where only one path is tainted → both paths get Top
- Unknown functions → Top (conservative)

**No string tracking:**
- Can't distinguish `"SELECT " + input` from `"SELECT " + escape_sql(input)` at the string level
- Must rely on sanitizer functions being called explicitly

**No alias analysis:**
- If `x` and `y` point to the same data, tainting `x` should taint `y`
- Our analysis treats variables independently

---

## Summary + Key Takeaways

1. **Taint analysis** reuses Module 4's abstract interpretation framework
2. The **taint lattice** is a flat 4-element domain (like the sign domain)
3. **Sources** create taint, **sinks** check for it, **sanitizers** clean it
4. **Explicit flows** follow data, **implicit flows** follow control
5. **Vulnerability detection** = taint propagation + sink checking

**Real-world tools using these ideas:**
- **Semgrep**: pattern-based taint tracking
- **CodeQL**: dataflow analysis for security
- **FlowDroid**: Android taint analysis
- **Infer**: Facebook's abstract interpretation engine
