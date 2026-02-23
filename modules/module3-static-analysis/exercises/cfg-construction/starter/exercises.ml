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
  (* TODO:
     1. Create three blocks: "ENTRY" (empty), "B1" (all stmts), "EXIT" (empty)
     2. Add them to a StringMap
     3. Build the cfg record (entry = "ENTRY", exit_label = "EXIT")
     4. Add edges: ENTRY -> B1, B1 -> EXIT *)
  ignore stmts;
  failwith "TODO: build_cfg_sequential"

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
  (* TODO:
     1. Partition [stmts] to find the If and the statements before/after it.
        Hint: use a recursive helper or List.fold to split around the If.
     2. Extract then_stmts and else_stmts from the If node.
     3. Create blocks: ENTRY, B_cond, B_then, B_else, B_join, EXIT
     4. Wire edges:
          ENTRY -> B_cond
          B_cond -> B_then
          B_cond -> B_else
          B_then -> B_join
          B_else -> B_join
          B_join -> EXIT *)
  ignore stmts;
  failwith "TODO: build_cfg_ifelse"

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
  (* TODO:
     1. Partition [stmts] to find the While and the stmts before/after it.
     2. Extract the loop body from the While node.
     3. Create blocks: ENTRY, B_pre, B_cond, B_body, B_post, EXIT
     4. Wire edges:
          ENTRY  -> B_pre
          B_pre  -> B_cond
          B_cond -> B_body    (loop body)
          B_cond -> B_post    (loop exit)
          B_body -> B_cond    (back edge)
          B_post -> EXIT *)
  ignore stmts;
  failwith "TODO: build_cfg_while"
