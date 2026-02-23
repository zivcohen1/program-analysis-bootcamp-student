(** Test suite for Exercise 5: Analysis Reporter (18 tests). *)

open OUnit2
open Analysis_reporter_ex

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
(* build_report tests (3)                                             *)
(* ================================================================== *)

let test_build_report_basic _ctx =
  let r = Reporter.build_report "test_prog" Sample_findings.all_findings in
  assert_equal ~printer:Fun.id "test_prog" r.Reporter.program_name;
  assert_equal ~printer:string_of_int 6 r.Reporter.total_findings

let test_build_report_severity_counts _ctx =
  let r = Reporter.build_report "test" Sample_findings.all_findings in
  let crit = List.assoc_opt Finding_types.Critical r.Reporter.severity_counts in
  assert_equal ~printer:string_of_int ~msg:"2 critical"
    2 (Option.value ~default:0 crit)

let test_build_report_empty _ctx =
  let r = Reporter.build_report "empty" [] in
  assert_equal ~printer:string_of_int 0 r.Reporter.total_findings;
  assert_equal ~printer:string_of_int 0
    (List.length r.Reporter.severity_counts)

(* ================================================================== *)
(* Text report tests (3)                                              *)
(* ================================================================== *)

let test_text_report_header _ctx =
  let r = Reporter.build_report "my_app" Sample_findings.all_findings in
  let text = Reporter.format_text_report r in
  assert_bool "contains program name" (contains text "my_app");
  assert_bool "contains total count" (contains text "6")

let test_text_report_findings _ctx =
  let r = Reporter.build_report "app" Sample_findings.all_findings in
  let text = Reporter.format_text_report r in
  assert_bool "contains Critical" (contains text "Critical");
  assert_bool "contains SQL injection" (contains text "SQL injection")

let test_text_report_empty _ctx =
  let r = Reporter.build_report "empty" [] in
  let text = Reporter.format_text_report r in
  assert_bool "mentions no findings" (contains text "No findings")

(* ================================================================== *)
(* JSON report tests (4)                                              *)
(* ================================================================== *)

let test_json_finding _ctx =
  let json = Reporter.format_json_finding Sample_findings.sqli_finding in
  assert_bool "has id" (contains json "\"id\":");
  assert_bool "has category" (contains json "\"Security\"");
  assert_bool "has severity" (contains json "\"Critical\"");
  assert_bool "has message" (contains json "SQL injection")

let test_json_finding_null_suggestion _ctx =
  let json = Reporter.format_json_finding Sample_findings.unused_var_finding in
  assert_bool "has null suggestion" (contains json "null")

let test_json_report_structure _ctx =
  let r = Reporter.build_report "app" Sample_findings.all_findings in
  let json = Reporter.format_json_report r in
  assert_bool "has program field" (contains json "\"program\":");
  assert_bool "has total field" (contains json "\"total\":");
  assert_bool "has findings field" (contains json "\"findings\":");
  assert_bool "has severity_counts" (contains json "\"severity_counts\":")

let test_json_report_empty _ctx =
  let r = Reporter.build_report "empty" [] in
  let json = Reporter.format_json_report r in
  assert_bool "has empty findings" (contains json "\"findings\": []");
  assert_bool "has total 0" (contains json "\"total\": 0")

(* ================================================================== *)
(* Summary tests (2)                                                  *)
(* ================================================================== *)

let test_summary_nonempty _ctx =
  let r = Reporter.build_report "app" Sample_findings.all_findings in
  let s = Reporter.format_summary r in
  assert_bool "contains program name" (contains s "app");
  assert_bool "contains count" (contains s "6");
  assert_bool "contains Critical" (contains s "Critical")

let test_summary_empty _ctx =
  let r = Reporter.build_report "app" [] in
  let s = Reporter.format_summary r in
  assert_bool "no findings message" (contains s "No findings")

(* ================================================================== *)
(* Table tests (2)                                                    *)
(* ================================================================== *)

let test_table_header _ctx =
  let tbl = Reporter.format_findings_table Sample_findings.all_findings in
  assert_bool "has Severity column" (contains tbl "Severity");
  assert_bool "has Category column" (contains tbl "Category");
  assert_bool "has Location column" (contains tbl "Location")

let test_table_rows _ctx =
  let tbl = Reporter.format_findings_table Sample_findings.all_findings in
  assert_bool "contains handler location" (contains tbl "handler");
  assert_bool "contains taint pass" (contains tbl "taint")

(* ================================================================== *)
(* top_n and filter tests (4)                                         *)
(* ================================================================== *)

let test_top_n_findings _ctx =
  let top2 = Reporter.top_n_findings 2 Sample_findings.all_findings in
  assert_equal ~printer:string_of_int 2 (List.length top2);
  assert_equal Finding_types.Critical
    (List.hd top2).Finding_types.severity

let test_top_n_more_than_available _ctx =
  let top100 = Reporter.top_n_findings 100 Sample_findings.all_findings in
  assert_equal ~printer:string_of_int 6 (List.length top100)

let test_findings_above_severity _ctx =
  let high_plus = Reporter.findings_above_severity Finding_types.High
      Sample_findings.all_findings in
  List.iter (fun f ->
    assert_bool "severity >= High"
      (Finding_types.severity_to_int f.Finding_types.severity >= 3))
    high_plus;
  assert_bool "at least 3 high+ findings" (List.length high_plus >= 3)

let test_findings_above_critical _ctx =
  let critical = Reporter.findings_above_severity Finding_types.Critical
      Sample_findings.all_findings in
  assert_equal ~printer:string_of_int 2 (List.length critical)

(* ================================================================== *)
(* Test suite                                                         *)
(* ================================================================== *)

let () =
  run_test_tt_main
    ("Exercise 5: Analysis Reporter" >::: [
       (* build_report (3) *)
       "build_report basic"          >:: test_build_report_basic;
       "build_report severity counts" >:: test_build_report_severity_counts;
       "build_report empty"          >:: test_build_report_empty;
       (* Text report (3) *)
       "text report header"          >:: test_text_report_header;
       "text report findings"        >:: test_text_report_findings;
       "text report empty"           >:: test_text_report_empty;
       (* JSON report (4) *)
       "json finding"                >:: test_json_finding;
       "json finding null suggestion" >:: test_json_finding_null_suggestion;
       "json report structure"       >:: test_json_report_structure;
       "json report empty"           >:: test_json_report_empty;
       (* Summary (2) *)
       "summary nonempty"            >:: test_summary_nonempty;
       "summary empty"               >:: test_summary_empty;
       (* Table (2) *)
       "table header"                >:: test_table_header;
       "table rows"                  >:: test_table_rows;
       (* Top-N / filter (4) *)
       "top_n findings"              >:: test_top_n_findings;
       "top_n more than available"   >:: test_top_n_more_than_available;
       "findings above severity"     >:: test_findings_above_severity;
       "findings above critical"     >:: test_findings_above_critical;
     ])
