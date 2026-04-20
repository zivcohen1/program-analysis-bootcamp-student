(** CFG Construction Exercises.

    Each function below takes a list of AST statements and returns a CFG
    whose shape matches a specific control-flow pattern.

    Students: implement the functions marked with TODO.

    General approach for each exercise:
    1. Create the basic blocks with [Cfg.create_block].
    2. Put them into a [Cfg.StringMap] keyed by label.
    3. Build the initial [Cfg.cfg] record with entry, exit_label, and blocks.
    4. Use [Cfg.add_edge] to wire up the control flow edges.

    The ENTRY and EXIT blocks are always empty (no statements). *)

open Shared_ast.Ast_types

let build_blocks labels blocks =
  List.fold_left
    (fun acc (label, block) -> Cfg.StringMap.add label block acc)
    Cfg.StringMap.empty
    (List.combine labels blocks)

let split_around_if stmts =
  let rec aux prefix = function
    | [] -> failwith "Expected exactly one If statement"
    | If (cond, then_stmts, else_stmts) :: suffix ->
        (List.rev prefix, cond, then_stmts, else_stmts, suffix)
    | stmt :: rest -> aux (stmt :: prefix) rest
  in
  aux [] stmts

let split_around_while stmts =
  let rec aux prefix = function
    | [] -> failwith "Expected exactly one While statement"
    | While (cond, body_stmts) :: suffix ->
        (List.rev prefix, cond, body_stmts, suffix)
    | stmt :: rest -> aux (stmt :: prefix) rest
  in
  aux [] stmts

let wire_edge src dst cfg = Cfg.add_edge cfg src dst

(** Build a CFG for straight-line (sequential) code.

    Expected shape:

      ENTRY --> B1 --> EXIT

    All statements go into a single block B1.

    Example input:
      [ Assign ("x", IntLit 1);
        Assign ("y", IntLit 2);
        Assign ("z", BinOp (Add, Var "x", Var "y")) ]

    @param stmts  A flat list of statements with no branches or loops. *)
let build_cfg_sequential (stmts : stmt list) : Cfg.cfg =
  let blocks =
    build_blocks
      ["ENTRY"; "B1"; "EXIT"]
      [ Cfg.create_block "ENTRY" [];
        Cfg.create_block "B1" stmts;
        Cfg.create_block "EXIT" [] ]
  in
  let cfg = { Cfg.entry = "ENTRY"; exit_label = "EXIT"; blocks } in
  cfg
  |> wire_edge "ENTRY" "B1"
  |> wire_edge "B1" "EXIT"

(** Build a CFG for an if-else branch.

    Expected shape (diamond):

           ENTRY
             |
           B_cond
           /    \
       B_then  B_else
           \    /
           B_join
             |
            EXIT

    The input should contain statements before the if, the if-else
    itself, and statements after the if.

    The condition block B_cond holds any statements that precede the
    If, plus the If statement acts as the branch (but is not placed
    in a block -- only its children are).

    For simplicity, this exercise expects the input to be:
      [ ...pre-if stmts...;
        If (cond, then_stmts, else_stmts);
        ...post-if stmts... ]

    Map them to blocks:
    - B_cond : statements before the If
    - B_then : then_stmts
    - B_else : else_stmts
    - B_join : statements after the If

    @param stmts  Statement list containing exactly one If statement. *)
let build_cfg_ifelse (stmts : stmt list) : Cfg.cfg =
  let pre_stmts, _cond, then_stmts, else_stmts, post_stmts = split_around_if stmts in
  let blocks =
    build_blocks
      ["ENTRY"; "B_cond"; "B_then"; "B_else"; "B_join"; "EXIT"]
      [ Cfg.create_block "ENTRY" [];
        Cfg.create_block "B_cond" pre_stmts;
        Cfg.create_block "B_then" then_stmts;
        Cfg.create_block "B_else" else_stmts;
        Cfg.create_block "B_join" post_stmts;
        Cfg.create_block "EXIT" [] ]
  in
  let cfg = { Cfg.entry = "ENTRY"; exit_label = "EXIT"; blocks } in
  cfg
  |> wire_edge "ENTRY" "B_cond"
  |> wire_edge "B_cond" "B_then"
  |> wire_edge "B_cond" "B_else"
  |> wire_edge "B_then" "B_join"
  |> wire_edge "B_else" "B_join"
  |> wire_edge "B_join" "EXIT"

(** Build a CFG for a while loop.

    Expected shape:

       ENTRY
         |
       B_pre       (statements before the while)
         |
       B_cond  <---+
       /    \      |
    B_body   \     |
      |       \    |
      +--------+   |
               |
            B_post  (statements after the while)
               |
             EXIT

    More precisely:
      ENTRY -> B_pre -> B_cond -> B_body -> B_cond  (back edge!)
                                  B_cond -> B_post -> EXIT

    @param stmts  Statement list containing exactly one While statement. *)
let build_cfg_while (stmts : stmt list) : Cfg.cfg =
  let pre_stmts, _cond, body_stmts, post_stmts = split_around_while stmts in
  let blocks =
    build_blocks
      ["ENTRY"; "B_pre"; "B_cond"; "B_body"; "B_post"; "EXIT"]
      [ Cfg.create_block "ENTRY" [];
        Cfg.create_block "B_pre" pre_stmts;
        Cfg.create_block "B_cond" [];
        Cfg.create_block "B_body" body_stmts;
        Cfg.create_block "B_post" post_stmts;
        Cfg.create_block "EXIT" [] ]
  in
  let cfg = { Cfg.entry = "ENTRY"; exit_label = "EXIT"; blocks } in
  cfg
  |> wire_edge "ENTRY" "B_pre"
  |> wire_edge "B_pre" "B_cond"
  |> wire_edge "B_cond" "B_body"
  |> wire_edge "B_cond" "B_post"
  |> wire_edge "B_body" "B_cond"
  |> wire_edge "B_post" "EXIT"
