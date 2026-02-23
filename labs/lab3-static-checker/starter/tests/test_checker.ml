open OUnit2
open Shared_ast.Ast_types
open Static_checker

(* ------------------------------------------------------------------ *)
(* Helper: build a simple program from a single function definition    *)
(* ------------------------------------------------------------------ *)
let make_program func = [func]

(* ================================================================== *)
(* Test: check_unused_variables                                        *)
(* ================================================================== *)
let test_unused_variables _ =
  let func = {
    name = "f";
    params = ["x"];
    body = [
      Assign ("unused", IntLit 42);
      Assign ("y", BinOp (Add, Var "x", IntLit 1));
      Return (Some (Var "y"));
    ];
  } in
  let issues = Rules.check_unused_variables func in
  assert_bool "should find at least one unused variable issue"
    (List.length issues > 0);
  assert_bool "issue should mention 'unused'"
    (List.exists (fun (i : Reporter.issue) ->
       String.length i.message > 0) issues)

(* ================================================================== *)
(* Test: check_unreachable_code                                        *)
(* ================================================================== *)
let test_unreachable_code _ =
  let func = {
    name = "g";
    params = [];
    body = [
      Return (Some (IntLit 1));
      Assign ("x", IntLit 2);
    ];
  } in
  let issues = Rules.check_unreachable_code func in
  assert_bool "should find unreachable code after return"
    (List.length issues > 0)

(* ================================================================== *)
(* Test: check_shadowed_variables                                      *)
(* ================================================================== *)
let test_shadowed_variables _ =
  let func = {
    name = "h";
    params = [];
    body = [
      Assign ("x", IntLit 10);
      If (
        BoolLit true,
        [ Assign ("x", IntLit 20) ],
        []
      );
      Return (Some (Var "x"));
    ];
  } in
  let issues = Rules.check_shadowed_variables func in
  assert_bool "should find shadowed variable 'x'"
    (List.length issues > 0)

(* ================================================================== *)
(* Test: clean program produces no issues                              *)
(* ================================================================== *)
let test_clean_program _ =
  let func = {
    name = "clean";
    params = ["a"; "b"];
    body = [
      Assign ("c", BinOp (Add, Var "a", Var "b"));
      Return (Some (Var "c"));
    ];
  } in
  let issues = Checker.check_program (make_program func) in
  assert_equal [] issues
    ~msg:"clean program should have no issues"

(* ================================================================== *)
(* Test: check_program aggregates issues from all rules                *)
(* ================================================================== *)
let test_aggregation _ =
  (* A function with an unused var AND unreachable code *)
  let func = {
    name = "messy";
    params = [];
    body = [
      Assign ("unused", IntLit 99);
      Return (Some (IntLit 0));
      Assign ("dead", IntLit 1);
    ];
  } in
  let issues = Checker.check_program (make_program func) in
  assert_bool "should find multiple issues from different rules"
    (List.length issues >= 2)

(* ================================================================== *)
(* Test suite                                                          *)
(* ================================================================== *)
let suite =
  "StaticChecker" >::: [
    "test_unused_variables"   >:: test_unused_variables;
    "test_unreachable_code"   >:: test_unreachable_code;
    "test_shadowed_variables" >:: test_shadowed_variables;
    "test_clean_program"      >:: test_clean_program;
    "test_aggregation"        >:: test_aggregation;
  ]

let () = run_test_tt_main suite
