open Ast_types

let string_of_op = function
  | Add -> "+" | Sub -> "-" | Mul -> "*" | Div -> "/"
  | Eq -> "==" | Neq -> "!=" | Lt -> "<" | Gt -> ">"
  | Le -> "<=" | Ge -> ">="
  | And -> "&&" | Or -> "||"

let string_of_uop = function
  | Neg -> "-" | Not -> "!"

let rec string_of_expr = function
  | IntLit n -> string_of_int n
  | BoolLit b -> string_of_bool b
  | Var s -> s
  | BinOp (op, e1, e2) ->
    Printf.sprintf "(%s %s %s)"
      (string_of_expr e1) (string_of_op op) (string_of_expr e2)
  | UnaryOp (op, e) ->
    Printf.sprintf "(%s%s)" (string_of_uop op) (string_of_expr e)
  | Call (name, args) ->
    Printf.sprintf "%s(%s)" name
      (String.concat ", " (List.map string_of_expr args))

let rec print_stmt indent stmt =
  let pad = String.make (indent * 2) ' ' in
  match stmt with
  | Assign (v, e) ->
    Printf.sprintf "%s%s = %s;" pad v (string_of_expr e)
  | If (cond, then_b, else_b) ->
    let then_s = print_stmts (indent + 1) then_b in
    let else_s = match else_b with
      | [] -> ""
      | _ -> Printf.sprintf "\n%selse {\n%s\n%s}" pad
               (print_stmts (indent + 1) else_b) pad
    in
    Printf.sprintf "%sif (%s) {\n%s\n%s}%s"
      pad (string_of_expr cond) then_s pad else_s
  | While (cond, body) ->
    Printf.sprintf "%swhile (%s) {\n%s\n%s}"
      pad (string_of_expr cond) (print_stmts (indent + 1) body) pad
  | Return None -> Printf.sprintf "%sreturn;" pad
  | Return (Some e) ->
    Printf.sprintf "%sreturn %s;" pad (string_of_expr e)
  | Print exprs ->
    Printf.sprintf "%sprint(%s);" pad
      (String.concat ", " (List.map string_of_expr exprs))
  | Block stmts ->
    Printf.sprintf "%s{\n%s\n%s}" pad (print_stmts (indent + 1) stmts) pad

and print_stmts indent stmts =
  String.concat "\n" (List.map (print_stmt indent) stmts)

let print_func_def fd =
  Printf.sprintf "fun %s(%s) {\n%s\n}"
    fd.name
    (String.concat ", " fd.params)
    (print_stmts 1 fd.body)

let print_program prog =
  String.concat "\n\n" (List.map print_func_def prog)

let rec dump_expr indent expr =
  let pad = String.make (indent * 2) ' ' in
  match expr with
  | IntLit n -> Printf.sprintf "%sIntLit(%d)" pad n
  | BoolLit b -> Printf.sprintf "%sBoolLit(%b)" pad b
  | Var s -> Printf.sprintf "%sVar(\"%s\")" pad s
  | BinOp (op, e1, e2) ->
    Printf.sprintf "%sBinOp(%s)\n%s\n%s"
      pad (string_of_op op) (dump_expr (indent + 1) e1) (dump_expr (indent + 1) e2)
  | UnaryOp (op, e) ->
    Printf.sprintf "%sUnaryOp(%s)\n%s"
      pad (string_of_uop op) (dump_expr (indent + 1) e)
  | Call (name, args) ->
    let args_s = List.map (dump_expr (indent + 1)) args in
    Printf.sprintf "%sCall(\"%s\")\n%s" pad name (String.concat "\n" args_s)

let rec dump_stmt indent stmt =
  let pad = String.make (indent * 2) ' ' in
  match stmt with
  | Assign (v, e) ->
    Printf.sprintf "%sAssign(\"%s\")\n%s" pad v (dump_expr (indent + 1) e)
  | If (cond, then_b, else_b) ->
    Printf.sprintf "%sIf\n%s\n%sThen\n%s\n%sElse\n%s"
      pad (dump_expr (indent + 1) cond)
      pad (dump_stmts (indent + 1) then_b)
      pad (dump_stmts (indent + 1) else_b)
  | While (cond, body) ->
    Printf.sprintf "%sWhile\n%s\n%sBody\n%s"
      pad (dump_expr (indent + 1) cond)
      pad (dump_stmts (indent + 1) body)
  | Return None -> Printf.sprintf "%sReturn()" pad
  | Return (Some e) ->
    Printf.sprintf "%sReturn\n%s" pad (dump_expr (indent + 1) e)
  | Print exprs ->
    let es = List.map (dump_expr (indent + 1)) exprs in
    Printf.sprintf "%sPrint\n%s" pad (String.concat "\n" es)
  | Block stmts ->
    Printf.sprintf "%sBlock\n%s" pad (dump_stmts (indent + 1) stmts)

and dump_stmts indent stmts =
  String.concat "\n" (List.map (dump_stmt indent) stmts)

let dump_program prog =
  List.iter (fun fd ->
    Printf.printf "FuncDef(\"%s\", [%s])\n%s\n"
      fd.name
      (String.concat "; " fd.params)
      (dump_stmts 1 fd.body)
  ) prog
