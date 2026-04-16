(* transformations.ml - AST transformation passes.

   Each transformation is a pure function: it takes an AST (or part of one)
   and returns a *new* AST with the transformation applied.  The original
   tree is never mutated.

   Implement the three transformations below.  Each one exercises a
   different kind of recursive tree rewriting. *)

open Shared_ast.Ast_types

(* --------------------------------------------------------------------------
   1. Constant folding
   --------------------------------------------------------------------------
   Simplify expressions whose operands are known at compile time.

   Strategy:
     - Recursively fold sub-expressions first (bottom-up).
     - After folding, check whether a BinOp has two IntLit children.
       If so, evaluate the operation and return a single IntLit (or BoolLit
       for comparison / logical operators).
     - Leave everything else unchanged.

   Examples:
     BinOp(Add, IntLit 2, IntLit 3)           --> IntLit 5
     BinOp(Mul, IntLit 2, BinOp(Add, IntLit 1, IntLit 3))
                                                --> IntLit 8
     BinOp(Add, Var "x", IntLit 1)            --> BinOp(Add, Var "x", IntLit 1)
*)
let constant_fold (_expr : expr) : expr =
  let rec fold_expr (expr : expr) : expr =
    match expr with
    | IntLit _ | BoolLit _ | Var _ -> expr
    | Call (fname, args) -> Call (fname, List.map fold_expr args)
    | UnaryOp (Neg, e) ->
      begin match fold_expr e with
      | IntLit n -> IntLit (-n)
      | e' -> UnaryOp (Neg, e')
      end
    | UnaryOp (Not, e) ->
      begin match fold_expr e with
      | BoolLit b -> BoolLit (not b)
      | e' -> UnaryOp (Not, e')
      end
    | BinOp (op, l, r) ->
      let l' = fold_expr l in
      let r' = fold_expr r in
      begin match op, l', r' with
      | Add, IntLit a, IntLit b -> IntLit (a + b)
      | Sub, IntLit a, IntLit b -> IntLit (a - b)
      | Mul, IntLit a, IntLit b -> IntLit (a * b)
      | Div, IntLit a, IntLit b when b <> 0 -> IntLit (a / b)
      | Eq,  IntLit a, IntLit b -> BoolLit (a = b)
      | Neq, IntLit a, IntLit b -> BoolLit (a <> b)
      | Lt,  IntLit a, IntLit b -> BoolLit (a < b)
      | Gt,  IntLit a, IntLit b -> BoolLit (a > b)
      | Le,  IntLit a, IntLit b -> BoolLit (a <= b)
      | Ge,  IntLit a, IntLit b -> BoolLit (a >= b)
      | Eq,  BoolLit a, BoolLit b -> BoolLit (a = b)
      | Neq, BoolLit a, BoolLit b -> BoolLit (a <> b)
      | And, BoolLit a, BoolLit b -> BoolLit (a && b)
      | Or,  BoolLit a, BoolLit b -> BoolLit (a || b)
      | _ -> BinOp (op, l', r')
      end
  in
  fold_expr _expr

(* --------------------------------------------------------------------------
   2. Variable renaming
   --------------------------------------------------------------------------
   Replace every occurrence of a variable named [old_name] with [new_name]
   throughout a list of statements.  This includes:
     - Var references inside expressions
     - The left-hand side of Assign statements
   Other identifiers (function names in Call, etc.) are left alone.

   You will need a helper to rename inside expressions as well.

   Example:
     rename_variable "x" "tmp"
       [Assign("x", IntLit 1); Print [Var "x"]]
     -->
       [Assign("tmp", IntLit 1); Print [Var "tmp"]]
*)
let rename_variable (_old_name : string) (_new_name : string)
    (_stmts : stmt list) : stmt list =
  let rename_name name = if String.equal name _old_name then _new_name else name in
  let rec rename_expr (expr : expr) : expr =
    match expr with
    | IntLit _ | BoolLit _ -> expr
    | Var name -> Var (rename_name name)
    | UnaryOp (op, e) -> UnaryOp (op, rename_expr e)
    | BinOp (op, l, r) -> BinOp (op, rename_expr l, rename_expr r)
    | Call (fname, args) -> Call (fname, List.map rename_expr args)
  in
  let rec rename_stmt (stmt : stmt) : stmt =
    match stmt with
    | Assign (name, e) -> Assign (rename_name name, rename_expr e)
    | If (cond, then_branch, else_branch) ->
      If (cond |> rename_expr,
          then_branch |> List.map rename_stmt,
          else_branch |> List.map rename_stmt)
    | While (cond, body) -> While (rename_expr cond, List.map rename_stmt body)
    | Return None -> Return None
    | Return (Some e) -> Return (Some (rename_expr e))
    | Print exprs -> Print (List.map rename_expr exprs)
    | Block stmts -> Block (List.map rename_stmt stmts)
  in
  List.map rename_stmt _stmts

(* --------------------------------------------------------------------------
   3. Dead-code elimination
   --------------------------------------------------------------------------
   Remove statements that can never execute.  Two cases to handle:

   a) Unreachable code after Return:
      In a statement list, once a Return is encountered, all subsequent
      statements in that same list are dead and should be removed.

   b) Trivially-decided If:
      - If(BoolLit true,  then_branch, _)  --> replace with then_branch
      - If(BoolLit false, _, else_branch)   --> replace with else_branch

   Apply these rules recursively into nested blocks (If branches, While
   bodies, Block contents).

   Example:
     [Return (Some (IntLit 42)); Print [Var "unreachable"]]
     -->
     [Return (Some (IntLit 42))]
*)
let eliminate_dead_code (_stmts : stmt list) : stmt list =
  let rec dce_list (stmts : stmt list) : stmt list =
    match stmts with
    | [] -> []
    | stmt :: rest ->
      let stmt' = dce_stmt stmt in
      begin match stmt' with
      | Return _ -> [stmt']
      | _ -> stmt' :: dce_list rest
      end
  and dce_stmt (stmt : stmt) : stmt =
    match stmt with
    | Assign _ -> stmt
    | Print _ -> stmt
    | Return _ -> stmt
    | While (cond, body) -> While (cond, dce_list body)
    | Block stmts -> Block (dce_list stmts)
    | If (BoolLit true, then_branch, _else_branch) ->
      Block (dce_list then_branch)
    | If (BoolLit false, _then_branch, else_branch) ->
      Block (dce_list else_branch)
    | If (cond, then_branch, else_branch) ->
      If (cond, dce_list then_branch, dce_list else_branch)
  in
  dce_list _stmts
