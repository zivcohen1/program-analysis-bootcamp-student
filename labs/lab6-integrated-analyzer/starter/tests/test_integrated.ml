(** Student test suite for Lab 6: Integrated Analyzer (10 tests). *)

open OUnit2
open Shared_ast.Ast_types
open Integrated_analyzer

let contains s sub =
  let slen = String.length s in
  let sublen = String.length sub in
  if sublen > slen then false
  else
    let rec check i =
      if i > slen - sublen then false
      else if String.sub s i sublen = sub then true
      else check (i + 1)
    in
    check 0

(* ================================================================== *)
(* Part A: Finding + Dead Code (5 tests)                              *)
(* ================================================================== *)

let test_severity_to_string _ctx =
  assert_equal ~printer:Fun.id "Critical"
    (Finding.severity_to_string Finding.Critical);
  assert_equal ~printer:Fun.id "Info"
    (Finding.severity_to_string Finding.Info)

let test_format_finding _ctx =
  let f = { Finding.id = 1; category = Security; severity = Critical;
            pass_name = "taint"; location = "handler";
            message = "SQL injection"; suggestion = None } in
  let s = Finding.format_finding f in
  assert_bool "contains Critical" (contains s "Critical");
  assert_bool "contains SQL injection" (contains s "SQL injection")

let test_dead_code_unreachable _ctx =
  let func = { name = "f"; params = [];
    body = [Return (Some (IntLit 1)); Print [IntLit 2]] } in
  let findings = Dead_code.analyze_function func in
  assert_bool "detects unreachable code" (List.length findings > 0)

let test_dead_code_unused_var _ctx =
  let func = { name = "f"; params = [];
    body = [Assign ("unused", IntLit 1); Print [IntLit 2]] } in
  let findings = Dead_code.find_unused_variables func in
  assert_bool "detects unused variable" (List.length findings > 0)

let test_dead_code_clean _ctx =
  let func = { name = "f"; params = ["x"];
    body = [Return (Some (Var "x"))] } in
  let findings = Dead_code.analyze_function func in
  assert_equal ~printer:string_of_int 0 (List.length findings)

(* ================================================================== *)
(* Part B: Safety + Taint + Pipeline (3 tests)                        *)
(* ================================================================== *)

let test_safety_div_zero _ctx =
  let prog = [{ name = "f"; params = [];
    body = [
      Assign ("x", IntLit 10);
      Assign ("y", IntLit 0);
      Assign ("z", BinOp (Div, Var "x", Var "y"));
    ] }] in
  let findings = Safety_analysis.analyze_program prog in
  assert_bool "detects division by zero" (List.length findings > 0)

let test_taint_injection _ctx =
  let prog = [{ name = "f"; params = [];
    body = [
      Assign ("input", Call ("get_param", [IntLit 0]));
      Assign ("_r", Call ("exec_query", [Var "input"]));
    ] }] in
  let findings = Taint_analysis.analyze_program prog in
  assert_bool "detects injection" (List.length findings > 0)

let test_pipeline_combined _ctx =
  let prog = [{ name = "f"; params = [];
    body = [
      Assign ("x", IntLit 0);
      Assign ("y", BinOp (Div, IntLit 1, Var "x"));
      Assign ("input", Call ("get_param", [IntLit 0]));
      Assign ("_r", Call ("exec_query", [Var "input"]));
      Return (Some (Var "y"));
      Print [IntLit 99];
    ] }] in
  let passes = Pipeline.default_passes () in
  let findings = Pipeline.run_all passes prog in
  assert_bool "finds multiple issues" (List.length findings >= 2)

(* ================================================================== *)
(* Part C: Reporter (2 tests)                                         *)
(* ================================================================== *)

let test_reporter_build _ctx =
  let findings = [
    { Finding.id = 1; category = Security; severity = Critical;
      pass_name = "taint"; location = "f"; message = "sqli";
      suggestion = None };
  ] in
  let r = Reporter.build_report "test" findings in
  assert_equal ~printer:string_of_int 1 r.Reporter.total_findings

let test_reporter_summary _ctx =
  let r = Reporter.build_report "app" [] in
  let s = Reporter.format_summary r in
  assert_bool "mentions no findings" (contains s "No findings")

(* ================================================================== *)
(* Test suite                                                         *)
(* ================================================================== *)

let () =
  run_test_tt_main
    ("Lab 6 Student Tests" >::: [
       (* Part A (5) *)
       "severity_to_string"          >:: test_severity_to_string;
       "format_finding"              >:: test_format_finding;
       "dead code unreachable"       >:: test_dead_code_unreachable;
       "dead code unused var"        >:: test_dead_code_unused_var;
       "dead code clean"             >:: test_dead_code_clean;
       (* Part B (3) *)
       "safety div zero"             >:: test_safety_div_zero;
       "taint injection"             >:: test_taint_injection;
       "pipeline combined"           >:: test_pipeline_combined;
       (* Part C (2) *)
       "reporter build"              >:: test_reporter_build;
       "reporter summary"            >:: test_reporter_summary;
     ])
