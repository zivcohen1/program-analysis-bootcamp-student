(** OUnit2 tests for the CFG construction exercise. *)

open OUnit2
open Shared_ast.Ast_types
open Cfg_exercises

(* ======================================================================
   Helpers
   ====================================================================== *)

(** Sort a string list for order-independent comparison. *)
let sort = List.sort String.compare

(** Check whether [haystack] contains [needle] as a substring. *)
let string_contains haystack needle =
  let hlen = String.length haystack in
  let nlen = String.length needle in
  if nlen > hlen then false
  else
    let found = ref false in
    for i = 0 to hlen - nlen do
      if String.sub haystack i nlen = needle then found := true
    done;
    !found

(** Assert that two string lists are equal after sorting. *)
let assert_set_eq ~msg expected actual =
  assert_equal ~msg ~printer:(fun l -> "[" ^ String.concat "; " l ^ "]")
    (sort expected) (sort actual)

(* ======================================================================
   Test: create_block
   ====================================================================== *)

let test_create_block _ =
  let b = Cfg.create_block "B1" [Assign ("x", IntLit 1)] in
  assert_equal ~msg:"label" "B1" b.label;
  assert_equal ~msg:"stmts length" 1 (List.length b.stmts);
  assert_equal ~msg:"succs empty" [] b.succs;
  assert_equal ~msg:"preds empty" [] b.preds

let test_create_block_empty _ =
  let b = Cfg.create_block "ENTRY" [] in
  assert_equal ~msg:"label" "ENTRY" b.label;
  assert_equal ~msg:"stmts length" 0 (List.length b.stmts);
  assert_equal ~msg:"succs empty" [] b.succs;
  assert_equal ~msg:"preds empty" [] b.preds

(* ======================================================================
   Test: add_edge / predecessors / successors
   ====================================================================== *)

let make_simple_cfg () : Cfg.cfg =
  let entry = Cfg.create_block "ENTRY" [] in
  let b1 = Cfg.create_block "B1" [Assign ("x", IntLit 1)] in
  let exit_b = Cfg.create_block "EXIT" [] in
  let blocks =
    Cfg.StringMap.empty
    |> Cfg.StringMap.add "ENTRY" entry
    |> Cfg.StringMap.add "B1" b1
    |> Cfg.StringMap.add "EXIT" exit_b
  in
  { Cfg.entry = "ENTRY"; exit_label = "EXIT"; blocks }

let test_add_edge_succs _ =
  let cfg = make_simple_cfg () in
  let cfg = Cfg.add_edge cfg "ENTRY" "B1" in
  assert_set_eq ~msg:"ENTRY succs" ["B1"] (Cfg.successors cfg "ENTRY")

let test_add_edge_preds _ =
  let cfg = make_simple_cfg () in
  let cfg = Cfg.add_edge cfg "ENTRY" "B1" in
  assert_set_eq ~msg:"B1 preds" ["ENTRY"] (Cfg.predecessors cfg "B1")

let test_add_multiple_edges _ =
  let cfg = make_simple_cfg () in
  let cfg = Cfg.add_edge cfg "ENTRY" "B1" in
  let cfg = Cfg.add_edge cfg "B1" "EXIT" in
  assert_set_eq ~msg:"B1 succs" ["EXIT"] (Cfg.successors cfg "B1");
  assert_set_eq ~msg:"B1 preds" ["ENTRY"] (Cfg.predecessors cfg "B1");
  assert_set_eq ~msg:"EXIT preds" ["B1"] (Cfg.predecessors cfg "EXIT")

let test_to_string_not_empty _ =
  let cfg = make_simple_cfg () in
  let cfg = Cfg.add_edge cfg "ENTRY" "B1" in
  let s = Cfg.to_string cfg in
  assert_bool "to_string should not be empty" (String.length s > 0);
  (* The output should mention every block label. *)
  assert_bool "mentions ENTRY" (string_contains s "ENTRY");
  assert_bool "mentions B1" (string_contains s "B1")

(* ======================================================================
   Test: build_cfg_sequential
   ====================================================================== *)

let test_sequential_structure _ =
  let stmts = [
    Assign ("x", IntLit 1);
    Assign ("y", IntLit 2);
    Assign ("z", BinOp (Add, Var "x", Var "y"));
  ] in
  let cfg = Exercises.build_cfg_sequential stmts in
  (* ENTRY -> B1 -> EXIT *)
  assert_set_eq ~msg:"ENTRY succs" ["B1"] (Cfg.successors cfg "ENTRY");
  assert_set_eq ~msg:"B1 preds" ["ENTRY"] (Cfg.predecessors cfg "B1");
  assert_set_eq ~msg:"B1 succs" ["EXIT"] (Cfg.successors cfg "B1");
  assert_set_eq ~msg:"EXIT preds" ["B1"] (Cfg.predecessors cfg "EXIT");
  (* B1 should contain all 3 statements *)
  let b1 = Cfg.StringMap.find "B1" cfg.blocks in
  assert_equal ~msg:"B1 stmt count" 3 (List.length b1.stmts)

let test_sequential_entry_exit _ =
  let stmts = [Assign ("a", IntLit 42)] in
  let cfg = Exercises.build_cfg_sequential stmts in
  assert_equal ~msg:"entry" "ENTRY" cfg.entry;
  assert_equal ~msg:"exit" "EXIT" cfg.exit_label;
  (* ENTRY and EXIT blocks should be empty *)
  let entry_b = Cfg.StringMap.find "ENTRY" cfg.blocks in
  let exit_b  = Cfg.StringMap.find "EXIT"  cfg.blocks in
  assert_equal ~msg:"ENTRY stmts" 0 (List.length entry_b.stmts);
  assert_equal ~msg:"EXIT stmts"  0 (List.length exit_b.stmts)

(* ======================================================================
   Test: build_cfg_ifelse (diamond shape)
   ====================================================================== *)

let ifelse_stmts =
  [ Assign ("a", IntLit 1);
    If (BinOp (Gt, Var "x", IntLit 0),
        [Assign ("a", IntLit 3)],
        [Assign ("a", IntLit 4)]);
    Print [Var "a"]
  ]

let test_ifelse_diamond _ =
  let cfg = Exercises.build_cfg_ifelse ifelse_stmts in
  (* ENTRY -> B_cond *)
  assert_set_eq ~msg:"ENTRY succs" ["B_cond"] (Cfg.successors cfg "ENTRY");
  (* B_cond -> B_then, B_else *)
  assert_set_eq ~msg:"B_cond succs" ["B_then"; "B_else"]
    (Cfg.successors cfg "B_cond");
  (* B_then -> B_join *)
  assert_set_eq ~msg:"B_then succs" ["B_join"] (Cfg.successors cfg "B_then");
  (* B_else -> B_join *)
  assert_set_eq ~msg:"B_else succs" ["B_join"] (Cfg.successors cfg "B_else");
  (* B_join -> EXIT *)
  assert_set_eq ~msg:"B_join succs" ["EXIT"] (Cfg.successors cfg "B_join")

let test_ifelse_preds _ =
  let cfg = Exercises.build_cfg_ifelse ifelse_stmts in
  (* B_join should have two predecessors *)
  assert_set_eq ~msg:"B_join preds" ["B_then"; "B_else"]
    (Cfg.predecessors cfg "B_join");
  (* B_then and B_else each have one predecessor *)
  assert_set_eq ~msg:"B_then preds" ["B_cond"]
    (Cfg.predecessors cfg "B_then");
  assert_set_eq ~msg:"B_else preds" ["B_cond"]
    (Cfg.predecessors cfg "B_else")

let test_ifelse_block_contents _ =
  let cfg = Exercises.build_cfg_ifelse ifelse_stmts in
  (* B_cond should contain the pre-if statement: Assign("a", IntLit 1) *)
  let b_cond = Cfg.StringMap.find "B_cond" cfg.blocks in
  assert_equal ~msg:"B_cond stmts" 1 (List.length b_cond.stmts);
  (* B_then should have 1 statement *)
  let b_then = Cfg.StringMap.find "B_then" cfg.blocks in
  assert_equal ~msg:"B_then stmts" 1 (List.length b_then.stmts);
  (* B_else should have 1 statement *)
  let b_else = Cfg.StringMap.find "B_else" cfg.blocks in
  assert_equal ~msg:"B_else stmts" 1 (List.length b_else.stmts);
  (* B_join should have the post-if statement: Print *)
  let b_join = Cfg.StringMap.find "B_join" cfg.blocks in
  assert_equal ~msg:"B_join stmts" 1 (List.length b_join.stmts)

(* ======================================================================
   Test: build_cfg_while (with back edge)
   ====================================================================== *)

let while_stmts =
  [ Assign ("i", IntLit 0);
    While (BinOp (Lt, Var "i", IntLit 10),
           [Assign ("i", BinOp (Add, Var "i", IntLit 1))]);
    Return (Some (Var "i"))
  ]

let test_while_forward_edges _ =
  let cfg = Exercises.build_cfg_while while_stmts in
  (* ENTRY -> B_pre *)
  assert_set_eq ~msg:"ENTRY succs" ["B_pre"] (Cfg.successors cfg "ENTRY");
  (* B_pre -> B_cond *)
  assert_set_eq ~msg:"B_pre succs" ["B_cond"] (Cfg.successors cfg "B_pre");
  (* B_cond -> B_body, B_post *)
  assert_set_eq ~msg:"B_cond succs" ["B_body"; "B_post"]
    (Cfg.successors cfg "B_cond");
  (* B_post -> EXIT *)
  assert_set_eq ~msg:"B_post succs" ["EXIT"] (Cfg.successors cfg "B_post")

let test_while_back_edge _ =
  let cfg = Exercises.build_cfg_while while_stmts in
  (* B_body should have a successor back to B_cond (back edge) *)
  assert_set_eq ~msg:"B_body succs" ["B_cond"]
    (Cfg.successors cfg "B_body");
  (* B_cond should have B_body AND B_pre as predecessors *)
  assert_set_eq ~msg:"B_cond preds" ["B_pre"; "B_body"]
    (Cfg.predecessors cfg "B_cond")

let test_while_block_contents _ =
  let cfg = Exercises.build_cfg_while while_stmts in
  (* B_pre should contain: Assign("i", IntLit 0) *)
  let b_pre = Cfg.StringMap.find "B_pre" cfg.blocks in
  assert_equal ~msg:"B_pre stmts" 1 (List.length b_pre.stmts);
  (* B_cond should be empty (condition is implicit) *)
  let b_cond = Cfg.StringMap.find "B_cond" cfg.blocks in
  assert_equal ~msg:"B_cond stmts" 0 (List.length b_cond.stmts);
  (* B_body should have 1 statement *)
  let b_body = Cfg.StringMap.find "B_body" cfg.blocks in
  assert_equal ~msg:"B_body stmts" 1 (List.length b_body.stmts);
  (* B_post should have: Return *)
  let b_post = Cfg.StringMap.find "B_post" cfg.blocks in
  assert_equal ~msg:"B_post stmts" 1 (List.length b_post.stmts)

(* ======================================================================
   Test suite
   ====================================================================== *)

let suite =
  "CFG Construction" >::: [
    (* create_block *)
    "create_block basic"       >:: test_create_block;
    "create_block empty"       >:: test_create_block_empty;

    (* add_edge / predecessors / successors *)
    "add_edge sets succs"      >:: test_add_edge_succs;
    "add_edge sets preds"      >:: test_add_edge_preds;
    "add multiple edges"       >:: test_add_multiple_edges;
    "to_string non-empty"      >:: test_to_string_not_empty;

    (* build_cfg_sequential *)
    "sequential structure"     >:: test_sequential_structure;
    "sequential entry/exit"    >:: test_sequential_entry_exit;

    (* build_cfg_ifelse *)
    "ifelse diamond"           >:: test_ifelse_diamond;
    "ifelse preds"             >:: test_ifelse_preds;
    "ifelse block contents"    >:: test_ifelse_block_contents;

    (* build_cfg_while *)
    "while forward edges"      >:: test_while_forward_edges;
    "while back edge"          >:: test_while_back_edge;
    "while block contents"     >:: test_while_block_contents;
  ]

let () = run_test_tt_main suite
