(** Test suite for Exercise 3: Multi-Pass Analyzer (20 tests). *)

open OUnit2
open Multi_pass_ex

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
(* Safety pass tests (5)                                              *)
(* ================================================================== *)

let test_safety_div_by_zero _ctx =
  let pass = Multi_pass.make_safety_pass () in
  let findings = pass.Multi_pass.run Sample_programs.div_by_zero in
  assert_bool "detects division by zero"
    (List.length findings > 0);
  assert_bool "has Safety category"
    (List.exists (fun f -> f.Finding_types.category = Safety) findings)

let test_safety_safe_program _ctx =
  let pass = Multi_pass.make_safety_pass () in
  let findings = pass.Multi_pass.run Sample_programs.safe_program in
  let safety_findings = List.filter
    (fun f -> f.Finding_types.category = Finding_types.Safety
              && Finding_types.severity_to_int f.Finding_types.severity >= 3)
    findings in
  assert_equal ~printer:string_of_int
    ~msg:"safe program has no high+ safety findings"
    0 (List.length safety_findings)

let test_safety_pass_name _ctx =
  let pass = Multi_pass.make_safety_pass () in
  assert_equal ~printer:Fun.id "safety" pass.Multi_pass.name

let test_safety_pass_category _ctx =
  let pass = Multi_pass.make_safety_pass () in
  assert_equal Finding_types.Safety pass.Multi_pass.category

let test_safety_finding_location _ctx =
  let pass = Multi_pass.make_safety_pass () in
  let findings = pass.Multi_pass.run Sample_programs.div_by_zero in
  assert_bool "location is compute"
    (List.exists (fun f -> f.Finding_types.location = "compute") findings)

(* ================================================================== *)
(* Taint pass tests (5)                                               *)
(* ================================================================== *)

let test_taint_injection _ctx =
  let pass = Multi_pass.make_taint_pass () in
  let findings = pass.Multi_pass.run Sample_programs.taint_to_sink in
  assert_bool "detects injection"
    (List.length findings > 0);
  assert_bool "has Security category"
    (List.exists (fun f -> f.Finding_types.category = Security) findings)

let test_taint_safe_program _ctx =
  let pass = Multi_pass.make_taint_pass () in
  let findings = pass.Multi_pass.run Sample_programs.safe_program in
  let critical = List.filter
    (fun f -> f.Finding_types.severity = Finding_types.Critical) findings in
  assert_equal ~printer:string_of_int
    ~msg:"safe program has no critical taint findings"
    0 (List.length critical)

let test_taint_pass_name _ctx =
  let pass = Multi_pass.make_taint_pass () in
  assert_equal ~printer:Fun.id "taint" pass.Multi_pass.name

let test_taint_pass_category _ctx =
  let pass = Multi_pass.make_taint_pass () in
  assert_equal Finding_types.Security pass.Multi_pass.category

let test_taint_finding_message _ctx =
  let pass = Multi_pass.make_taint_pass () in
  let findings = pass.Multi_pass.run Sample_programs.taint_to_sink in
  assert_bool "message mentions exec_query"
    (List.exists
       (fun f -> contains f.Finding_types.message "exec_query")
       findings)

(* ================================================================== *)
(* Composition tests (5)                                              *)
(* ================================================================== *)

let test_run_pass _ctx =
  let pass = Multi_pass.make_safety_pass () in
  let findings = Multi_pass.run_pass pass Sample_programs.div_by_zero in
  assert_bool "run_pass produces findings"
    (List.length findings > 0)

let test_run_all_passes _ctx =
  let passes = Multi_pass.default_passes () in
  let findings = Multi_pass.run_all_passes passes Sample_programs.mixed_issues in
  let has_safety = List.exists
    (fun f -> f.Finding_types.category = Finding_types.Safety) findings in
  let has_security = List.exists
    (fun f -> f.Finding_types.category = Finding_types.Security) findings in
  assert_bool "finds safety issues" has_safety;
  assert_bool "finds security issues" has_security

let test_run_all_passes_safe _ctx =
  let passes = Multi_pass.default_passes () in
  let findings = Multi_pass.run_all_passes passes Sample_programs.safe_program in
  let critical = List.filter
    (fun f -> f.Finding_types.severity = Finding_types.Critical) findings in
  assert_equal ~printer:string_of_int
    ~msg:"safe program has no critical findings from all passes"
    0 (List.length critical)

let test_merge_findings _ctx =
  let f1 = { Finding_types.id = 1; category = Safety; severity = Medium;
             pass_name = "safety"; location = "f"; message = "m1";
             suggestion = None } in
  let f2 = { Finding_types.id = 2; category = Security; severity = Critical;
             pass_name = "taint"; location = "g"; message = "m2";
             suggestion = None } in
  let merged = Multi_pass.merge_findings [[f1]; [f2]] in
  assert_equal ~printer:string_of_int 2 (List.length merged);
  (* Critical should come first *)
  assert_equal Finding_types.Critical (List.hd merged).Finding_types.severity

let test_merge_findings_empty _ctx =
  let merged = Multi_pass.merge_findings [[] ; []] in
  assert_equal ~printer:string_of_int 0 (List.length merged)

(* ================================================================== *)
(* Partition tests (3)                                                *)
(* ================================================================== *)

let test_partition_by_pass _ctx =
  let f1 = { Finding_types.id = 1; category = Safety; severity = High;
             pass_name = "safety"; location = "f"; message = "m";
             suggestion = None } in
  let f2 = { Finding_types.id = 2; category = Security; severity = Critical;
             pass_name = "taint"; location = "g"; message = "m2";
             suggestion = None } in
  let f3 = { Finding_types.id = 3; category = Safety; severity = Medium;
             pass_name = "safety"; location = "h"; message = "m3";
             suggestion = None } in
  let groups = Multi_pass.partition_by_pass [f1; f2; f3] in
  assert_equal ~printer:string_of_int 2 (List.length groups)

let test_partition_group_contents _ctx =
  let f1 = { Finding_types.id = 1; category = Safety; severity = High;
             pass_name = "safety"; location = "f"; message = "m";
             suggestion = None } in
  let f2 = { Finding_types.id = 2; category = Safety; severity = Medium;
             pass_name = "safety"; location = "g"; message = "m2";
             suggestion = None } in
  let groups = Multi_pass.partition_by_pass [f1; f2] in
  let safety_group = List.assoc_opt "safety" groups in
  assert_bool "safety group exists" (safety_group <> None);
  assert_equal ~printer:string_of_int 2
    (List.length (Option.get safety_group))

let test_partition_empty _ctx =
  let groups = Multi_pass.partition_by_pass [] in
  assert_equal ~printer:string_of_int 0 (List.length groups)

(* ================================================================== *)
(* Default passes tests (2)                                           *)
(* ================================================================== *)

let test_default_passes_count _ctx =
  let passes = Multi_pass.default_passes () in
  assert_equal ~printer:string_of_int 2 (List.length passes)

let test_default_passes_names _ctx =
  let passes = Multi_pass.default_passes () in
  let names = List.map (fun p -> p.Multi_pass.name) passes in
  assert_bool "has safety" (List.mem "safety" names);
  assert_bool "has taint" (List.mem "taint" names)

(* ================================================================== *)
(* Test suite                                                         *)
(* ================================================================== *)

let () =
  run_test_tt_main
    ("Exercise 3: Multi-Pass Analyzer" >::: [
       (* Safety pass (5) *)
       "safety div_by_zero"         >:: test_safety_div_by_zero;
       "safety safe program"        >:: test_safety_safe_program;
       "safety pass name"           >:: test_safety_pass_name;
       "safety pass category"       >:: test_safety_pass_category;
       "safety finding location"    >:: test_safety_finding_location;
       (* Taint pass (5) *)
       "taint injection"            >:: test_taint_injection;
       "taint safe program"         >:: test_taint_safe_program;
       "taint pass name"            >:: test_taint_pass_name;
       "taint pass category"        >:: test_taint_pass_category;
       "taint finding message"      >:: test_taint_finding_message;
       (* Composition (5) *)
       "run_pass"                   >:: test_run_pass;
       "run_all_passes mixed"       >:: test_run_all_passes;
       "run_all_passes safe"        >:: test_run_all_passes_safe;
       "merge_findings"             >:: test_merge_findings;
       "merge_findings empty"       >:: test_merge_findings_empty;
       (* Partition (3) *)
       "partition_by_pass"          >:: test_partition_by_pass;
       "partition group contents"   >:: test_partition_group_contents;
       "partition empty"            >:: test_partition_empty;
       (* Default passes (2) *)
       "default_passes count"       >:: test_default_passes_count;
       "default_passes names"       >:: test_default_passes_names;
     ])
