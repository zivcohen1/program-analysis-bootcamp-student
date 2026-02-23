(** Test suite for Exercise 4: Configurable Pipeline (18 tests). *)

open OUnit2
open Config_pipeline_ex

(* ================================================================== *)
(* Config construction tests (5)                                      *)
(* ================================================================== *)

let test_default_config _ctx =
  let c = Pipeline.default_config in
  assert_equal ~printer:string_of_int 3 (List.length c.Pipeline.enabled_passes);
  assert_equal Finding_types.Info c.Pipeline.min_severity;
  assert_equal None c.Pipeline.max_findings;
  assert_equal None c.Pipeline.target_categories

let test_config_with_passes _ctx =
  let c = Pipeline.config_with_passes [Pipeline.Safety; Pipeline.Taint] in
  assert_equal ~printer:string_of_int 2 (List.length c.Pipeline.enabled_passes)

let test_config_with_severity _ctx =
  let c = Pipeline.config_with_severity Finding_types.High Pipeline.default_config in
  assert_equal Finding_types.High c.Pipeline.min_severity

let test_config_with_max _ctx =
  let c = Pipeline.config_with_max 5 Pipeline.default_config in
  assert_equal (Some 5) c.Pipeline.max_findings

let test_config_with_categories _ctx =
  let c = Pipeline.config_with_categories [Finding_types.Security]
      Pipeline.default_config in
  assert_equal (Some [Finding_types.Security]) c.Pipeline.target_categories

(* ================================================================== *)
(* Pass creation tests (3)                                            *)
(* ================================================================== *)

let test_create_safety_pass _ctx =
  let pass = Pipeline.create_pass Pipeline.Safety in
  assert_equal ~printer:Fun.id "safety" pass.Pass_registry.name

let test_create_taint_pass _ctx =
  let pass = Pipeline.create_pass Pipeline.Taint in
  assert_equal ~printer:Fun.id "taint" pass.Pass_registry.name

let test_create_dead_code_pass _ctx =
  let pass = Pipeline.create_pass Pipeline.DeadCode in
  assert_equal ~printer:Fun.id "dead_code" pass.Pass_registry.name

(* ================================================================== *)
(* Build pipeline tests (2)                                           *)
(* ================================================================== *)

let test_build_pipeline_all _ctx =
  let passes = Pipeline.build_pipeline Pipeline.default_config in
  assert_equal ~printer:string_of_int 3 (List.length passes)

let test_build_pipeline_subset _ctx =
  let config = Pipeline.config_with_passes [Pipeline.Safety] in
  let passes = Pipeline.build_pipeline config in
  assert_equal ~printer:string_of_int 1 (List.length passes);
  assert_equal ~printer:Fun.id "safety"
    (List.hd passes).Pass_registry.name

(* ================================================================== *)
(* Filtering tests (4)                                                *)
(* ================================================================== *)

let sample_findings = [
  { Finding_types.id = 1; category = Security; severity = Critical;
    pass_name = "taint"; location = "f"; message = "sqli";
    suggestion = None };
  { Finding_types.id = 2; category = Safety; severity = High;
    pass_name = "safety"; location = "g"; message = "div0";
    suggestion = None };
  { Finding_types.id = 3; category = CodeQuality; severity = Medium;
    pass_name = "dead_code"; location = "h"; message = "unreachable";
    suggestion = None };
  { Finding_types.id = 4; category = CodeQuality; severity = Info;
    pass_name = "dead_code"; location = "i"; message = "unused param";
    suggestion = None };
]

let test_filter_by_severity _ctx =
  let config = Pipeline.config_with_severity Finding_types.High
      Pipeline.default_config in
  let result = Pipeline.apply_filters config sample_findings in
  assert_equal ~printer:string_of_int 2 (List.length result)

let test_filter_by_category _ctx =
  let config = Pipeline.config_with_categories [Finding_types.Security]
      Pipeline.default_config in
  let result = Pipeline.apply_filters config sample_findings in
  assert_equal ~printer:string_of_int 1 (List.length result)

let test_filter_max_findings _ctx =
  let config = Pipeline.config_with_max 2 Pipeline.default_config in
  let result = Pipeline.apply_filters config sample_findings in
  assert_equal ~printer:string_of_int 2 (List.length result);
  (* Most severe should come first *)
  assert_equal Finding_types.Critical (List.hd result).Finding_types.severity

let test_filter_combined _ctx =
  let config = Pipeline.default_config
    |> Pipeline.config_with_severity Finding_types.Medium
    |> Pipeline.config_with_max 1 in
  let result = Pipeline.apply_filters config sample_findings in
  assert_equal ~printer:string_of_int 1 (List.length result);
  assert_equal Finding_types.Critical (List.hd result).Finding_types.severity

(* ================================================================== *)
(* Run pipeline tests (4)                                             *)
(* ================================================================== *)

let test_run_pipeline_all _ctx =
  let findings = Pipeline.run_pipeline Pipeline.default_config
      Sample_programs.mixed_issues in
  assert_bool "finds some issues" (List.length findings > 0)

let test_run_pipeline_safety_only _ctx =
  let config = Pipeline.config_with_passes [Pipeline.Safety] in
  let findings = Pipeline.run_pipeline config Sample_programs.div_by_zero in
  assert_bool "finds safety issues" (List.length findings > 0);
  List.iter (fun f ->
    assert_equal ~printer:Fun.id "safety" f.Finding_types.pass_name)
    findings

let test_run_pipeline_taint_only _ctx =
  let config = Pipeline.config_with_passes [Pipeline.Taint] in
  let findings = Pipeline.run_pipeline config Sample_programs.taint_to_sink in
  assert_bool "finds taint issues" (List.length findings > 0)

let test_run_pipeline_severity_filter _ctx =
  let config = Pipeline.default_config
    |> Pipeline.config_with_severity Finding_types.Critical in
  let findings = Pipeline.run_pipeline config Sample_programs.mixed_issues in
  List.iter (fun f ->
    assert_bool "all critical or above"
      (Finding_types.severity_to_int f.Finding_types.severity >= 4))
    findings

(* ================================================================== *)
(* Test suite                                                         *)
(* ================================================================== *)

let () =
  run_test_tt_main
    ("Exercise 4: Configurable Pipeline" >::: [
       (* Config construction (5) *)
       "default_config"              >:: test_default_config;
       "config_with_passes"          >:: test_config_with_passes;
       "config_with_severity"        >:: test_config_with_severity;
       "config_with_max"             >:: test_config_with_max;
       "config_with_categories"      >:: test_config_with_categories;
       (* Pass creation (3) *)
       "create safety pass"          >:: test_create_safety_pass;
       "create taint pass"           >:: test_create_taint_pass;
       "create dead_code pass"       >:: test_create_dead_code_pass;
       (* Build pipeline (2) *)
       "build pipeline all"          >:: test_build_pipeline_all;
       "build pipeline subset"       >:: test_build_pipeline_subset;
       (* Filtering (4) *)
       "filter by severity"          >:: test_filter_by_severity;
       "filter by category"          >:: test_filter_by_category;
       "filter max findings"         >:: test_filter_max_findings;
       "filter combined"             >:: test_filter_combined;
       (* Run pipeline (4) *)
       "run pipeline all"            >:: test_run_pipeline_all;
       "run pipeline safety only"    >:: test_run_pipeline_safety_only;
       "run pipeline taint only"     >:: test_run_pipeline_taint_only;
       "run pipeline severity filter" >:: test_run_pipeline_severity_filter;
     ])
