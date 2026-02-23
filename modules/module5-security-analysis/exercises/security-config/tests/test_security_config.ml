(** Tests for security configuration (Exercise 2). *)

open OUnit2
open Security_config_ex

(* ------------------------------------------------------------------ *)
(* Empty config tests                                                 *)
(* ------------------------------------------------------------------ *)

let test_empty_no_sources _ctx =
  assert_bool "empty has no sources"
    (not (Config.is_source Config.empty_config "get_param"))

let test_empty_no_sinks _ctx =
  assert_equal ~msg:"empty has no sinks" None
    (Config.find_sink Config.empty_config "exec_query")

(* ------------------------------------------------------------------ *)
(* Default config tests                                               *)
(* ------------------------------------------------------------------ *)

let test_default_has_sources _ctx =
  assert_bool "get_param is a source"
    (Config.is_source Config.default_web_config "get_param");
  assert_bool "read_cookie is a source"
    (Config.is_source Config.default_web_config "read_cookie")

let test_default_has_sinks _ctx =
  let sink = Config.find_sink Config.default_web_config "exec_query" in
  assert_bool "exec_query is a sink" (sink <> None);
  match sink with
  | Some s ->
    assert_equal ~printer:Fun.id "sql-injection" s.Config.sink_vuln_type
  | None -> assert_failure "expected sink"

let test_default_has_sanitizers _ctx =
  let san = Config.find_sanitizer Config.default_web_config "escape_sql" in
  assert_bool "escape_sql is a sanitizer" (san <> None)

let test_default_not_source _ctx =
  assert_bool "exec_query is not a source"
    (not (Config.is_source Config.default_web_config "exec_query"))

(* ------------------------------------------------------------------ *)
(* Lookup tests                                                       *)
(* ------------------------------------------------------------------ *)

let test_find_all_sinks _ctx =
  let sinks = ["exec_query"; "send_response"; "exec_cmd"; "open_file"; "redirect"] in
  List.iter
    (fun name ->
      assert_bool (name ^ " should be a sink")
        (Config.find_sink Config.default_web_config name <> None))
    sinks

let test_find_all_sanitizers _ctx =
  let sanitizers = ["escape_sql"; "html_encode"; "shell_escape";
                    "validate_path"; "validate_url"] in
  List.iter
    (fun name ->
      assert_bool (name ^ " should be a sanitizer")
        (Config.find_sanitizer Config.default_web_config name <> None))
    sanitizers

let test_find_nonexistent _ctx =
  assert_equal None (Config.find_sink Config.default_web_config "nonexistent");
  assert_equal None (Config.find_sanitizer Config.default_web_config "nonexistent")

let test_all_sources _ctx =
  let sources = ["get_param"; "read_cookie"; "read_input"; "read_file"; "get_header"] in
  List.iter
    (fun name ->
      assert_bool (name ^ " should be a source")
        (Config.is_source Config.default_web_config name))
    sources

let test_sink_vuln_types _ctx =
  let expected = [
    ("exec_query", "sql-injection");
    ("send_response", "xss");
    ("exec_cmd", "command-injection");
    ("open_file", "path-traversal");
    ("redirect", "open-redirect");
  ] in
  List.iter
    (fun (name, vtype) ->
      match Config.find_sink Config.default_web_config name with
      | Some s ->
        assert_equal ~printer:Fun.id ~msg:(name ^ " vuln type")
          vtype s.Config.sink_vuln_type
      | None -> assert_failure (name ^ " not found"))
    expected

(* ------------------------------------------------------------------ *)
(* Param check and sanitizer clean tests                              *)
(* ------------------------------------------------------------------ *)

let test_sink_checks_param _ctx =
  match Config.find_sink Config.default_web_config "exec_query" with
  | Some s ->
    assert_bool "checks param 0" (Config.sink_checks_param s 0);
    assert_bool "does not check param 1" (not (Config.sink_checks_param s 1))
  | None -> assert_failure "expected sink"

let test_sanitizer_cleans _ctx =
  match Config.find_sanitizer Config.default_web_config "escape_sql" with
  | Some s ->
    assert_bool "cleans sql-injection"
      (Config.sanitizer_cleans s "sql-injection");
    assert_bool "does not clean xss"
      (not (Config.sanitizer_cleans s "xss"))
  | None -> assert_failure "expected sanitizer"

(* ------------------------------------------------------------------ *)
(* Mutation tests                                                     *)
(* ------------------------------------------------------------------ *)

let test_add_source _ctx =
  let src = Config.{ source_name = "custom_src"; source_description = "test" } in
  let config = Config.add_source Config.empty_config src in
  assert_bool "custom source added"
    (Config.is_source config "custom_src")

let test_add_sink _ctx =
  let snk = Config.{
    sink_name = "custom_sink"; sink_param_index = 0;
    sink_vuln_type = "custom"; sink_description = "test"
  } in
  let config = Config.add_sink Config.empty_config snk in
  assert_bool "custom sink added"
    (Config.find_sink config "custom_sink" <> None)

let test_add_sanitizer _ctx =
  let san = Config.{
    sanitizer_name = "custom_san"; sanitizer_cleans = ["custom"];
    sanitizer_description = "test"
  } in
  let config = Config.add_sanitizer Config.empty_config san in
  assert_bool "custom sanitizer added"
    (Config.find_sanitizer config "custom_san" <> None)

let test_html_encode_cleans_xss _ctx =
  match Config.find_sanitizer Config.default_web_config "html_encode" with
  | Some s ->
    assert_bool "html_encode cleans xss"
      (Config.sanitizer_cleans s "xss");
    assert_bool "html_encode does not clean sql-injection"
      (not (Config.sanitizer_cleans s "sql-injection"))
  | None -> assert_failure "expected sanitizer"

let () =
  run_test_tt_main
    ("Security Config" >::: [
       (* Empty config: 2 tests *)
       "empty no sources"     >:: test_empty_no_sources;
       "empty no sinks"       >:: test_empty_no_sinks;
       (* Default config: 4 tests *)
       "default has sources"  >:: test_default_has_sources;
       "default has sinks"    >:: test_default_has_sinks;
       "default has sanitizers" >:: test_default_has_sanitizers;
       "default not source"   >:: test_default_not_source;
       (* Lookups: 5 tests *)
       "find all sinks"       >:: test_find_all_sinks;
       "find all sanitizers"  >:: test_find_all_sanitizers;
       "find nonexistent"     >:: test_find_nonexistent;
       "all sources"          >:: test_all_sources;
       "sink vuln types"      >:: test_sink_vuln_types;
       (* Param and sanitizer checks: 2 tests *)
       "sink checks param"    >:: test_sink_checks_param;
       "sanitizer cleans"     >:: test_sanitizer_cleans;
       (* Mutation: 3 tests *)
       "add source"           >:: test_add_source;
       "add sink"             >:: test_add_sink;
       "add sanitizer"        >:: test_add_sanitizer;
       (* Extra: 1 test *)
       "html_encode cleans xss" >:: test_html_encode_cleans_xss;
     ])
