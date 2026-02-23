(** Unit tests for the security analyzer (Lab 5). *)

open OUnit2
open Security_analyzer

let config = Security_config.default_config

(* ------------------------------------------------------------------ *)
(* Part A: Config tests                                               *)
(* ------------------------------------------------------------------ *)

let test_config_has_sources _ctx =
  assert_bool "get_param is a source"
    (Security_config.is_source config "get_param")

let test_config_has_sinks _ctx =
  assert_bool "exec_query is a sink"
    (Security_config.find_sink config "exec_query" <> None)

let test_config_has_sanitizers _ctx =
  assert_bool "escape_sql is a sanitizer"
    (Security_config.find_sanitizer config "escape_sql" <> None)

(* ------------------------------------------------------------------ *)
(* Part A: Analyzer tests                                             *)
(* ------------------------------------------------------------------ *)

let test_analyze_empty _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = []; body = [] } in
  let _env = Taint_analyzer.analyze_function config func in
  assert_bool "empty function analyzes" true

let test_analyze_source _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [Assign ("x", Call ("get_param", [IntLit 0]))] } in
  let env = Taint_analyzer.analyze_function config func in
  assert_bool "x is tainted from source"
    (Taint_domain.is_potentially_tainted
      (Taint_analyzer.Env.lookup "x" env))

let test_analyze_literal _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [Assign ("x", IntLit 42)] } in
  let env = Taint_analyzer.analyze_function config func in
  assert_equal ~printer:Taint_domain.to_string
    Taint_domain.Untainted
    (Taint_analyzer.Env.lookup "x" env)

(* ------------------------------------------------------------------ *)
(* Part B: Checker tests                                              *)
(* ------------------------------------------------------------------ *)

let test_check_sqli _ctx =
  let open Shared_ast.Ast_types in
  let prog = [{ name = "f"; params = [];
    body = [
      Assign ("x", Call ("get_param", [IntLit 0]));
      Assign ("_r", Call ("exec_query", [Var "x"]));
    ] }] in
  let vulns = Vuln_checker.check_program config prog in
  assert_bool "detects sql injection"
    (List.exists (fun v -> v.Vuln_checker.vuln_type = "sql-injection") vulns)

let test_check_safe _ctx =
  let open Shared_ast.Ast_types in
  let prog = [{ name = "f"; params = [];
    body = [
      Assign ("x", IntLit 1);
      Assign ("_r", Call ("exec_query", [Var "x"]));
    ] }] in
  let vulns = Vuln_checker.check_program config prog in
  assert_equal ~printer:string_of_int 0 (List.length vulns)

(* ------------------------------------------------------------------ *)
(* Part B: Reporter tests                                             *)
(* ------------------------------------------------------------------ *)

let test_severity _ctx =
  let sev = Vuln_reporter.severity_of_vuln_type "sql-injection" in
  assert_equal ~printer:Fun.id "CRITICAL" (Vuln_reporter.string_of_severity sev)

let test_format_no_vulns _ctx =
  let s = Vuln_reporter.format_summary [] in
  assert_equal ~printer:Fun.id "No vulnerabilities found." s

let () =
  run_test_tt_main
    ("Lab 5 Security Analyzer" >::: [
       "config has sources"     >:: test_config_has_sources;
       "config has sinks"       >:: test_config_has_sinks;
       "config has sanitizers"  >:: test_config_has_sanitizers;
       "analyze empty"          >:: test_analyze_empty;
       "analyze source"         >:: test_analyze_source;
       "analyze literal"        >:: test_analyze_literal;
       "check sqli"             >:: test_check_sqli;
       "check safe"             >:: test_check_safe;
       "severity"               >:: test_severity;
       "format no vulns"        >:: test_format_no_vulns;
     ])
