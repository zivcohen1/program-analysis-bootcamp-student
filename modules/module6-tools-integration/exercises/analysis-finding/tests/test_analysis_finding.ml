(** Test suite for Exercise 1: Analysis Finding (20 tests). *)

open OUnit2
open Analysis_finding_ex.Analysis_finding

(* ------------------------------------------------------------------ *)
(* Sample findings for tests                                          *)
(* ------------------------------------------------------------------ *)

let f_critical = {
  id = 1; category = Security; severity = Critical;
  pass_name = "taint"; location = "handler";
  message = "SQL injection"; suggestion = Some "Use parameterized queries";
}

let f_high = {
  id = 2; category = Safety; severity = High;
  pass_name = "safety"; location = "compute";
  message = "Division by zero"; suggestion = None;
}

let f_medium = {
  id = 3; category = Security; severity = Medium;
  pass_name = "taint"; location = "redirect_handler";
  message = "Open redirect"; suggestion = Some "Validate URL";
}

let f_low = {
  id = 4; category = CodeQuality; severity = Low;
  pass_name = "dead_code"; location = "main";
  message = "Unused variable x"; suggestion = None;
}

let f_info = {
  id = 5; category = CodeQuality; severity = Info;
  pass_name = "dead_code"; location = "helper";
  message = "Unused parameter y"; suggestion = None;
}

let f_dup = {
  id = 6; category = Security; severity = Critical;
  pass_name = "taint"; location = "handler";
  message = "SQL injection"; suggestion = None;
}

let all_findings = [f_critical; f_high; f_medium; f_low; f_info]

(* ================================================================== *)
(* Conversion tests (4)                                               *)
(* ================================================================== *)

let test_severity_to_string _ctx =
  assert_equal ~printer:Fun.id "Critical" (severity_to_string Critical);
  assert_equal ~printer:Fun.id "High" (severity_to_string High);
  assert_equal ~printer:Fun.id "Medium" (severity_to_string Medium);
  assert_equal ~printer:Fun.id "Low" (severity_to_string Low);
  assert_equal ~printer:Fun.id "Info" (severity_to_string Info)

let test_category_to_string _ctx =
  assert_equal ~printer:Fun.id "Security" (category_to_string Security);
  assert_equal ~printer:Fun.id "Safety" (category_to_string Safety);
  assert_equal ~printer:Fun.id "CodeQuality" (category_to_string CodeQuality);
  assert_equal ~printer:Fun.id "Performance" (category_to_string Performance)

let test_severity_to_int _ctx =
  assert_equal ~printer:string_of_int 4 (severity_to_int Critical);
  assert_equal ~printer:string_of_int 3 (severity_to_int High);
  assert_equal ~printer:string_of_int 2 (severity_to_int Medium);
  assert_equal ~printer:string_of_int 1 (severity_to_int Low);
  assert_equal ~printer:string_of_int 0 (severity_to_int Info)

let test_severity_ordering _ctx =
  assert_bool "Critical > High"
    (severity_to_int Critical > severity_to_int High);
  assert_bool "High > Medium"
    (severity_to_int High > severity_to_int Medium);
  assert_bool "Low > Info"
    (severity_to_int Low > severity_to_int Info)

(* ================================================================== *)
(* Comparison tests (3)                                               *)
(* ================================================================== *)

let test_compare_by_severity_order _ctx =
  assert_bool "critical before high"
    (compare_by_severity f_critical f_high < 0);
  assert_bool "high before medium"
    (compare_by_severity f_high f_medium < 0);
  assert_bool "info after low"
    (compare_by_severity f_info f_low > 0)

let test_compare_by_severity_equal _ctx =
  assert_equal ~printer:string_of_int 0
    (compare_by_severity f_critical f_dup)

let test_compare_by_location _ctx =
  assert_bool "compute before handler"
    (compare_by_location f_high f_critical < 0);
  assert_bool "handler before main"
    (compare_by_location f_critical f_low < 0)

(* ================================================================== *)
(* Filtering tests (4)                                                *)
(* ================================================================== *)

let test_filter_by_severity_high _ctx =
  let result = filter_by_severity High all_findings in
  assert_equal ~printer:string_of_int 2 (List.length result);
  List.iter (fun f ->
    assert_bool "severity >= High"
      (severity_to_int f.severity >= severity_to_int High))
    result

let test_filter_by_severity_info _ctx =
  let result = filter_by_severity Info all_findings in
  assert_equal ~printer:string_of_int 5 (List.length result)

let test_filter_by_category_security _ctx =
  let result = filter_by_category Security all_findings in
  assert_equal ~printer:string_of_int 2 (List.length result);
  List.iter (fun f ->
    assert_equal Security f.category) result

let test_filter_by_category_empty _ctx =
  let result = filter_by_category Performance all_findings in
  assert_equal ~printer:string_of_int 0 (List.length result)

(* ================================================================== *)
(* Deduplication tests (2)                                            *)
(* ================================================================== *)

let test_deduplicate_removes_dups _ctx =
  let input = [f_critical; f_high; f_dup; f_low] in
  let result = deduplicate input in
  assert_equal ~printer:string_of_int 3 (List.length result)

let test_deduplicate_preserves_order _ctx =
  let input = [f_low; f_critical; f_high; f_dup] in
  let result = deduplicate input in
  assert_equal ~printer:string_of_int 3 (List.length result);
  assert_equal 4 (List.hd result).id

(* ================================================================== *)
(* Formatting tests (3)                                               *)
(* ================================================================== *)

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

let test_format_finding_basic _ctx =
  let s = format_finding f_high in
  assert_bool "contains severity" (contains s "High");
  assert_bool "contains category" (contains s "Safety");
  assert_bool "contains message" (contains s "Division by zero");
  assert_bool "contains location" (contains s "compute")

let test_format_finding_with_suggestion _ctx =
  let s = format_finding f_critical in
  assert_bool "contains suggestion" (contains s "Suggestion");
  assert_bool "contains suggestion text" (contains s "parameterized queries")

let test_format_findings_list_empty _ctx =
  assert_equal ~printer:Fun.id "No findings." (format_findings_list [])

(* ================================================================== *)
(* Counting tests (4)                                                 *)
(* ================================================================== *)

let test_count_by_severity _ctx =
  let counts = count_by_severity all_findings in
  let find_count s = List.assoc_opt s counts in
  assert_equal ~printer:string_of_int ~msg:"1 critical"
    1 (Option.value ~default:0 (find_count Critical));
  assert_equal ~printer:string_of_int ~msg:"1 high"
    1 (Option.value ~default:0 (find_count High))

let test_count_by_severity_excludes_zero _ctx =
  let counts = count_by_severity all_findings in
  assert_bool "no Performance severity count for zero entries"
    (not (List.exists (fun (_, n) -> n = 0) counts))

let test_count_by_category _ctx =
  let counts = count_by_category all_findings in
  let find_count c = List.assoc_opt c counts in
  assert_equal ~printer:string_of_int ~msg:"2 security"
    2 (Option.value ~default:0 (find_count Security));
  assert_equal ~printer:string_of_int ~msg:"2 code quality"
    2 (Option.value ~default:0 (find_count CodeQuality))

let test_count_by_category_excludes_zero _ctx =
  let counts = count_by_category all_findings in
  assert_bool "no zero-count entries"
    (not (List.exists (fun (_, n) -> n = 0) counts))

(* ================================================================== *)
(* Test suite                                                         *)
(* ================================================================== *)

let () =
  run_test_tt_main
    ("Exercise 1: Analysis Finding" >::: [
       (* Conversion (4) *)
       "severity_to_string"         >:: test_severity_to_string;
       "category_to_string"         >:: test_category_to_string;
       "severity_to_int"            >:: test_severity_to_int;
       "severity ordering"          >:: test_severity_ordering;
       (* Comparison (3) *)
       "compare_by_severity order"  >:: test_compare_by_severity_order;
       "compare_by_severity equal"  >:: test_compare_by_severity_equal;
       "compare_by_location"        >:: test_compare_by_location;
       (* Filtering (4) *)
       "filter_by_severity High"    >:: test_filter_by_severity_high;
       "filter_by_severity Info"    >:: test_filter_by_severity_info;
       "filter_by_category Security" >:: test_filter_by_category_security;
       "filter_by_category empty"   >:: test_filter_by_category_empty;
       (* Deduplication (2) *)
       "deduplicate removes dups"   >:: test_deduplicate_removes_dups;
       "deduplicate preserves order" >:: test_deduplicate_preserves_order;
       (* Formatting (3) *)
       "format_finding basic"       >:: test_format_finding_basic;
       "format_finding suggestion"  >:: test_format_finding_with_suggestion;
       "format_findings_list empty" >:: test_format_findings_list_empty;
       (* Counting (4) *)
       "count_by_severity"          >:: test_count_by_severity;
       "count_by_severity no zeros" >:: test_count_by_severity_excludes_zero;
       "count_by_category"          >:: test_count_by_category;
       "count_by_category no zeros" >:: test_count_by_category_excludes_zero;
     ])
