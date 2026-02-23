(* ast_visualizer.ml - AST Structure Mapping Exercise
   ===================================================
   Implement three ways to visualize an AST built from Shared_ast.Ast_types:

   1. dump_ast       - Indented tree representation showing node types
   2. count_node_types - Count occurrences of each AST node type
   3. print_tree     - Pretty-print as human-readable pseudo-code

   Each function operates on a stmt list (i.e., a function body).
   Refer to Ast_types for the type definitions:
     expr: IntLit, BoolLit, Var, BinOp, UnaryOp, Call
     stmt: Assign, If, While, Return, Print, Block
*)

open Shared_ast.Ast_types

(* ------------------------------------------------------------------ *)
(* Helper: create an indentation string of [n] levels (2 spaces each) *)
(* ------------------------------------------------------------------ *)
let indent n = String.make (n * 2) ' '

(* ================================================================== *)
(* 1. dump_ast : stmt list -> string                                  *)
(*                                                                    *)
(*    Produce an indented, tree-style dump of the AST.                *)
(*    Example output for  Assign("x", IntLit 5):                      *)
(*      Assign("x")                                                   *)
(*        IntLit(5)                                                   *)
(*                                                                    *)
(*    For BinOp(Add, IntLit 2, IntLit 3):                             *)
(*      BinOp(+)                                                      *)
(*        IntLit(2)                                                   *)
(*        IntLit(3)                                                   *)
(* ================================================================== *)

(* Dump a single expression at the given indentation depth.
   Hint: use [indent depth] for the padding string, then match on the
   expression and format each variant.  For compound nodes (BinOp, UnaryOp,
   Call), recursively dump the sub-expressions at [depth + 1]. *)
let rec dump_expr (depth : int) (e : expr) : string =
  let _pad = indent depth in
  match e with
  | IntLit _n ->
    (* TODO: return  "<pad>IntLit(<n>)" *)
    failwith "TODO: dump_expr IntLit"
  | BoolLit _b ->
    (* TODO: return  "<pad>BoolLit(<b>)" *)
    failwith "TODO: dump_expr BoolLit"
  | Var _s ->
    (* TODO: return  "<pad>Var(\"<s>\")" *)
    failwith "TODO: dump_expr Var"
  | BinOp (_op, e1, e2) ->
    (* TODO: return  "<pad>BinOp(<op>)\n<dump e1>\n<dump e2>"
       Use dump_expr recursively on e1 and e2 at depth+1. *)
    ignore (dump_expr (depth + 1) e1, dump_expr (depth + 1) e2);
    failwith "TODO: dump_expr BinOp"
  | UnaryOp (_op, e1) ->
    (* TODO: return  "<pad>UnaryOp(<op>)\n<dump e>" *)
    ignore (dump_expr (depth + 1) e1);
    failwith "TODO: dump_expr UnaryOp"
  | Call (_name, args) ->
    (* TODO: return  "<pad>Call(\"<name>\")\n<dump each arg>" *)
    ignore (List.map (dump_expr (depth + 1)) args);
    failwith "TODO: dump_expr Call"

(* Dump a single statement at the given indentation depth.
   For statements that contain expressions (Assign, If, While, Return, Print),
   use dump_expr at [depth + 1].
   For statements that contain sub-statement lists (If, While, Block),
   use dump_stmts at [depth + 1]. *)
and dump_stmt (depth : int) (s : stmt) : string =
  let _pad = indent depth in
  match s with
  | Assign (_v, e) ->
    (* TODO: return  "<pad>Assign(\"<v>\")\n<dump e at depth+1>" *)
    ignore (dump_expr (depth + 1) e);
    failwith "TODO: dump_stmt Assign"
  | If (cond, then_b, else_b) ->
    (* TODO: return
         "<pad>If\n<dump cond>\n<pad>Then\n<dump then stmts>\n<pad>Else\n<dump else stmts>"
    *)
    ignore (dump_expr (depth + 1) cond,
            dump_stmts (depth + 1) then_b,
            dump_stmts (depth + 1) else_b);
    failwith "TODO: dump_stmt If"
  | While (cond, body) ->
    (* TODO: return
         "<pad>While\n<dump cond>\n<pad>Body\n<dump body stmts>"
    *)
    ignore (dump_expr (depth + 1) cond, dump_stmts (depth + 1) body);
    failwith "TODO: dump_stmt While"
  | Return None ->
    (* TODO: return  "<pad>Return()" *)
    failwith "TODO: dump_stmt Return None"
  | Return (Some e) ->
    (* TODO: return  "<pad>Return\n<dump e at depth+1>" *)
    ignore (dump_expr (depth + 1) e);
    failwith "TODO: dump_stmt Return Some"
  | Print exprs ->
    (* TODO: return  "<pad>Print\n<dump each expr at depth+1>" *)
    ignore (List.map (dump_expr (depth + 1)) exprs);
    failwith "TODO: dump_stmt Print"
  | Block stmts ->
    (* TODO: return  "<pad>Block\n<dump each stmt at depth+1>" *)
    ignore (dump_stmts (depth + 1) stmts);
    failwith "TODO: dump_stmt Block"

(* Dump a list of statements, joining them with newlines. *)
and dump_stmts (depth : int) (stmts : stmt list) : string =
  (* TODO: map dump_stmt over stmts at the given depth and join with "\n" *)
  ignore (List.map (dump_stmt depth) stmts);
  failwith "TODO: dump_stmts"

(* Top-level entry point: dump an entire function body. *)
let dump_ast (stmts : stmt list) : string =
  dump_stmts 0 stmts


(* ================================================================== *)
(* 2. count_node_types : stmt list -> (string * int) list             *)
(*                                                                    *)
(*    Walk the AST and count how many of each node type appear.       *)
(*    Return an association list like:                                 *)
(*      [("Assign", 2); ("BinOp", 3); ("IntLit", 4); ...]            *)
(*                                                                    *)
(*    Node type names to count:                                       *)
(*      Statements: "Assign", "If", "While", "Return", "Print",      *)
(*                  "Block"                                           *)
(*      Expressions: "IntLit", "BoolLit", "Var", "BinOp",            *)
(*                   "UnaryOp", "Call"                                *)
(* ================================================================== *)

(* Helper: increment the count for [key] in an association list.
   If the key is not present, add it with count 1. *)
let inc (key : string) (counts : (string * int) list) : (string * int) list =
  (* TODO: if key exists in counts, increment its value; otherwise append (key, 1) *)
  ignore (key, counts);
  failwith "TODO: inc"

(* Count node types inside an expression, accumulating into [acc].
   Match on each expr variant, use [inc] to add its type name, then
   recurse into any sub-expressions. *)
let rec count_expr (acc : (string * int) list) (e : expr) : (string * int) list =
  match e with
  | IntLit _ ->
    (* TODO: inc "IntLit" acc *)
    ignore (acc, inc); failwith "TODO: count_expr IntLit"
  | BoolLit _ ->
    ignore acc; failwith "TODO: count_expr BoolLit"
  | Var _ ->
    ignore acc; failwith "TODO: count_expr Var"
  | BinOp (_, e1, e2) ->
    (* TODO: inc "BinOp", then recurse into e1 and e2 *)
    ignore (count_expr acc e1, count_expr acc e2);
    failwith "TODO: count_expr BinOp"
  | UnaryOp (_, e1) ->
    ignore (count_expr acc e1);
    failwith "TODO: count_expr UnaryOp"
  | Call (_, args) ->
    ignore (List.fold_left count_expr acc args);
    failwith "TODO: count_expr Call"

(* Count node types inside a statement, accumulating into [acc]. *)
and count_stmt (acc : (string * int) list) (s : stmt) : (string * int) list =
  match s with
  | Assign (_, e) ->
    ignore (count_expr acc e);
    failwith "TODO: count_stmt Assign"
  | If (cond, then_b, else_b) ->
    ignore (count_expr acc cond, count_stmts acc then_b, count_stmts acc else_b);
    failwith "TODO: count_stmt If"
  | While (cond, body) ->
    ignore (count_expr acc cond, count_stmts acc body);
    failwith "TODO: count_stmt While"
  | Return None ->
    ignore acc; failwith "TODO: count_stmt Return None"
  | Return (Some e) ->
    ignore (count_expr acc e);
    failwith "TODO: count_stmt Return Some"
  | Print exprs ->
    ignore (List.fold_left count_expr acc exprs);
    failwith "TODO: count_stmt Print"
  | Block stmts ->
    ignore (count_stmts acc stmts);
    failwith "TODO: count_stmt Block"

(* Count across a list of statements. *)
and count_stmts (acc : (string * int) list) (stmts : stmt list) : (string * int) list =
  (* TODO: fold count_stmt over the list *)
  ignore (List.fold_left count_stmt acc stmts);
  failwith "TODO: count_stmts"

(* Top-level entry point. *)
let count_node_types (stmts : stmt list) : (string * int) list =
  count_stmts [] stmts


(* ================================================================== *)
(* 3. print_tree : stmt list -> string                                *)
(*                                                                    *)
(*    Pretty-print the AST as human-readable pseudo-code.             *)
(*    Example:                                                        *)
(*      x = (2 + 3);                                                  *)
(*      if ((x > 0)) {                                                *)
(*        y = 1;                                                      *)
(*      } else {                                                      *)
(*        y = 0;                                                      *)
(*      }                                                             *)
(* ================================================================== *)

(* Convert an operator to its string symbol.
   Add -> "+", Sub -> "-", Mul -> "*", Div -> "/",
   Eq -> "==", Neq -> "!=", Lt -> "<", Gt -> ">",
   Le -> "<=", Ge -> ">=", And -> "&&", Or -> "||" *)
let string_of_op (op : op) : string =
  (* TODO *)
  ignore op;
  failwith "TODO: string_of_op"

(* Convert a unary operator to its string symbol. *)
let string_of_uop (uop : uop) : string =
  (* TODO: Neg -> "-", Not -> "!" *)
  ignore uop;
  failwith "TODO: string_of_uop"

(* Convert an expression to a string (parenthesized where needed).
     - IntLit n   -> string_of_int n
     - BoolLit b  -> string_of_bool b
     - Var s      -> s
     - BinOp      -> "(<left> <op> <right>)"
     - UnaryOp    -> "(<op><expr>)"
     - Call       -> "<name>(<arg1>, <arg2>, ...)" *)
let rec expr_to_string (e : expr) : string =
  match e with
  | BinOp (_, e1, e2) ->
    (* TODO *)
    ignore (expr_to_string e1, expr_to_string e2, string_of_op, string_of_uop);
    failwith "TODO: expr_to_string BinOp"
  | UnaryOp (_, e1) ->
    ignore (expr_to_string e1);
    failwith "TODO: expr_to_string UnaryOp"
  | Call (_, args) ->
    ignore (List.map expr_to_string args);
    failwith "TODO: expr_to_string Call"
  | _ ->
    (* TODO: handle IntLit, BoolLit, Var *)
    failwith "TODO: expr_to_string leaf"

(* Pretty-print a single statement at the given indentation level.
     - Assign: "<pad><var> = <expr>;"
     - If:     "<pad>if (<cond>) {\n<then>\n<pad>} else {\n<else>\n<pad>}"
               (omit else clause if the else branch is [])
     - While:  "<pad>while (<cond>) {\n<body>\n<pad>}"
     - Return None:    "<pad>return;"
     - Return Some e:  "<pad>return <expr>;"
     - Print:  "<pad>print(<expr1>, <expr2>, ...);"
     - Block:  "<pad>{\n<stmts>\n<pad>}" *)
and pp_stmt (depth : int) (s : stmt) : string =
  let _pad = indent depth in
  match s with
  | Assign (_, e) ->
    ignore (expr_to_string e);
    failwith "TODO: pp_stmt Assign"
  | If (cond, then_b, else_b) ->
    ignore (expr_to_string cond, pp_stmts (depth + 1) then_b,
            pp_stmts (depth + 1) else_b);
    failwith "TODO: pp_stmt If"
  | While (cond, body) ->
    ignore (expr_to_string cond, pp_stmts (depth + 1) body);
    failwith "TODO: pp_stmt While"
  | Return None ->
    failwith "TODO: pp_stmt Return None"
  | Return (Some e) ->
    ignore (expr_to_string e);
    failwith "TODO: pp_stmt Return Some"
  | Print exprs ->
    ignore (List.map expr_to_string exprs);
    failwith "TODO: pp_stmt Print"
  | Block stmts ->
    ignore (pp_stmts (depth + 1) stmts);
    failwith "TODO: pp_stmt Block"

(* Pretty-print a list of statements, joining with newlines. *)
and pp_stmts (depth : int) (stmts : stmt list) : string =
  (* TODO *)
  ignore (List.map (pp_stmt depth) stmts);
  failwith "TODO: pp_stmts"

(* Top-level entry point. *)
let print_tree (stmts : stmt list) : string =
  pp_stmts 0 stmts


(* ================================================================== *)
(* Main - run the visualizer on the sample programs                   *)
(* ================================================================== *)
let () =
  let open Sample_asts in
  let programs = [
    ("simple_arithmetic", simple_arithmetic);
    ("branching",         branching);
    ("loop_example",      loop_example);
  ] in
  List.iter (fun (label, prog) ->
    let body = (List.hd prog).body in
    Printf.printf "=== %s ===\n\n" label;

    Printf.printf "--- dump_ast ---\n%s\n\n" (dump_ast body);

    Printf.printf "--- count_node_types ---\n";
    let counts = count_node_types body in
    List.iter (fun (name, n) ->
      Printf.printf "  %s: %d\n" name n
    ) counts;
    print_newline ();

    Printf.printf "--- print_tree ---\n%s\n\n" (print_tree body);
  ) programs
