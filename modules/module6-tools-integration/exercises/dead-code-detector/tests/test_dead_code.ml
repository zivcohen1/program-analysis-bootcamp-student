(** Test suite for Exercise 2: Dead Code Detector (20 tests). *)

open OUnit2
open Shared_ast.Ast_types
open Dead_code_ex

module StringSet = Dead_code.StringSet

(* ------------------------------------------------------------------ *)
(* Sample programs                                                    *)
(* ------------------------------------------------------------------ *)

let func_with_return : func_def =
  { name = "f"; params = [];
    body = [
      Assign ("x", IntLit 1);
      Return (Some (Var "x"));
      Print [Var "x"];
      Assign ("y", IntLit 2);
    ] }

let func_no_return : func_def =
  { name = "g"; params = [];
    body = [
      Assign ("x", IntLit 1);
      Print [Var "x"];
    ] }

let func_unused_var : func_def =
  { name = "h"; params = [];
    body = [
      Assign ("used", IntLit 1);
      Assign ("unused", IntLit 2);
      Print [Var "used"];
    ] }

let func_underscore_var : func_def =
  { name = "i"; params = [];
    body = [
      Assign ("_temp", IntLit 1);
      Assign ("x", IntLit 2);
      Print [Var "x"];
    ] }

let func_unused_param : func_def =
  { name = "j"; params = ["used_p"; "unused_p"];
    body = [
      Print [Var "used_p"];
    ] }

let func_underscore_param : func_def =
  { name = "k"; params = ["x"; "_unused"];
    body = [
      Print [Var "x"];
    ] }

let func_all_issues : func_def =
  { name = "bad"; params = ["a"; "unused_param"];
    body = [
      Assign ("b", IntLit 1);
      Assign ("c", Var "a");
      Return (Some (Var "c"));
      Print [IntLit 99];
    ] }

let clean_func : func_def =
  { name = "clean"; params = ["x"; "y"];
    body = [
      Assign ("result", BinOp (Add, Var "x", Var "y"));
      Return (Some (Var "result"));
    ] }

(* ================================================================== *)
(* has_return tests (2)                                               *)
(* ================================================================== *)

let test_has_return_yes _ctx =
  assert_bool "function with return" (Dead_code.has_return func_with_return.body)

let test_has_return_no _ctx =
  assert_bool "function without return" (not (Dead_code.has_return func_no_return.body))

(* ================================================================== *)
(* stmts_after_return tests (2)                                       *)
(* ================================================================== *)

let test_stmts_after_return_present _ctx =
  let after = Dead_code.stmts_after_return func_with_return.body in
  assert_equal ~printer:string_of_int 2 (List.length after)

let test_stmts_after_return_none _ctx =
  let after = Dead_code.stmts_after_return func_no_return.body in
  assert_equal ~printer:string_of_int 0 (List.length after)

(* ================================================================== *)
(* Variable collection tests (4)                                      *)
(* ================================================================== *)

let test_collect_used_vars_expr _ctx =
  let e = BinOp (Add, Var "a", BinOp (Mul, Var "b", IntLit 3)) in
  let vars = Dead_code.collect_used_vars_expr e in
  assert_bool "contains a" (StringSet.mem "a" vars);
  assert_bool "contains b" (StringSet.mem "b" vars);
  assert_equal ~printer:string_of_int 2 (StringSet.cardinal vars)

let test_collect_used_vars_expr_call _ctx =
  let e = Call ("foo", [Var "x"; IntLit 1; Var "y"]) in
  let vars = Dead_code.collect_used_vars_expr e in
  assert_bool "contains x" (StringSet.mem "x" vars);
  assert_bool "contains y" (StringSet.mem "y" vars);
  assert_equal ~printer:string_of_int 2 (StringSet.cardinal vars)

let test_collect_used_vars_stmts _ctx =
  let stmts = [
    Assign ("a", BinOp (Add, Var "x", IntLit 1));
    If (Var "flag", [Print [Var "y"]], []);
  ] in
  let vars = Dead_code.collect_used_vars_stmts stmts in
  assert_bool "x used" (StringSet.mem "x" vars);
  assert_bool "flag used" (StringSet.mem "flag" vars);
  assert_bool "y used" (StringSet.mem "y" vars)

let test_collect_assigned_vars _ctx =
  let stmts = [
    Assign ("a", IntLit 1);
    If (BoolLit true, [Assign ("b", IntLit 2)], [Assign ("c", IntLit 3)]);
    While (BoolLit false, [Assign ("d", IntLit 4)]);
  ] in
  let vars = Dead_code.collect_assigned_vars stmts in
  assert_bool "a assigned" (StringSet.mem "a" vars);
  assert_bool "b assigned" (StringSet.mem "b" vars);
  assert_bool "c assigned" (StringSet.mem "c" vars);
  assert_bool "d assigned" (StringSet.mem "d" vars);
  assert_equal ~printer:string_of_int 4 (StringSet.cardinal vars)

(* ================================================================== *)
(* Unreachable code tests (4)                                         *)
(* ================================================================== *)

let test_find_unreachable_present _ctx =
  let findings = Dead_code.find_unreachable_code func_with_return in
  assert_equal ~printer:string_of_int 1 (List.length findings);
  let f = List.hd findings in
  assert_equal Finding_types.CodeQuality f.Finding_types.category;
  assert_equal Finding_types.Medium f.Finding_types.severity

let test_find_unreachable_absent _ctx =
  let findings = Dead_code.find_unreachable_code func_no_return in
  assert_equal ~printer:string_of_int 0 (List.length findings)

let test_find_unreachable_location _ctx =
  let findings = Dead_code.find_unreachable_code func_with_return in
  assert_equal ~printer:Fun.id "f" (List.hd findings).Finding_types.location

let test_find_unreachable_clean _ctx =
  let findings = Dead_code.find_unreachable_code clean_func in
  assert_equal ~printer:string_of_int 0 (List.length findings)

(* ================================================================== *)
(* Unused variable tests (3)                                          *)
(* ================================================================== *)

let test_find_unused_vars _ctx =
  let findings = Dead_code.find_unused_variables func_unused_var in
  assert_equal ~printer:string_of_int 1 (List.length findings);
  let f = List.hd findings in
  assert_equal Finding_types.Low f.Finding_types.severity

let test_find_unused_vars_underscore_exempt _ctx =
  let findings = Dead_code.find_unused_variables func_underscore_var in
  assert_equal ~printer:string_of_int 0 (List.length findings)

let test_find_unused_vars_clean _ctx =
  let findings = Dead_code.find_unused_variables clean_func in
  assert_equal ~printer:string_of_int 0 (List.length findings)

(* ================================================================== *)
(* Unused parameter tests (3)                                         *)
(* ================================================================== *)

let test_find_unused_params _ctx =
  let findings = Dead_code.find_unused_parameters func_unused_param in
  assert_equal ~printer:string_of_int 1 (List.length findings);
  let f = List.hd findings in
  assert_equal Finding_types.Info f.Finding_types.severity

let test_find_unused_params_underscore_exempt _ctx =
  let findings = Dead_code.find_unused_parameters func_underscore_param in
  assert_equal ~printer:string_of_int 0 (List.length findings)

let test_find_unused_params_clean _ctx =
  let findings = Dead_code.find_unused_parameters clean_func in
  assert_equal ~printer:string_of_int 0 (List.length findings)

(* ================================================================== *)
(* Integration tests (2)                                              *)
(* ================================================================== *)

let test_analyze_function_all_issues _ctx =
  let findings = Dead_code.analyze_function func_all_issues in
  (* Should find: unreachable code, unused var "b", unused param "unused_param" *)
  assert_bool "at least 3 findings" (List.length findings >= 3)

let test_analyze_program _ctx =
  let prog = [func_with_return; clean_func; func_unused_var] in
  let findings = Dead_code.analyze_program prog in
  (* func_with_return: unreachable + unused y *)
  (* clean_func: nothing *)
  (* func_unused_var: unused *)
  assert_bool "findings across multiple functions" (List.length findings >= 2)

(* ================================================================== *)
(* Test suite                                                         *)
(* ================================================================== *)

let () =
  run_test_tt_main
    ("Exercise 2: Dead Code Detector" >::: [
       (* has_return (2) *)
       "has_return yes"                  >:: test_has_return_yes;
       "has_return no"                   >:: test_has_return_no;
       (* stmts_after_return (2) *)
       "stmts_after_return present"      >:: test_stmts_after_return_present;
       "stmts_after_return none"         >:: test_stmts_after_return_none;
       (* Variable collection (4) *)
       "collect_used_vars_expr"          >:: test_collect_used_vars_expr;
       "collect_used_vars_expr call"     >:: test_collect_used_vars_expr_call;
       "collect_used_vars_stmts"         >:: test_collect_used_vars_stmts;
       "collect_assigned_vars"           >:: test_collect_assigned_vars;
       (* Unreachable code (4) *)
       "unreachable present"             >:: test_find_unreachable_present;
       "unreachable absent"              >:: test_find_unreachable_absent;
       "unreachable location"            >:: test_find_unreachable_location;
       "unreachable clean"               >:: test_find_unreachable_clean;
       (* Unused variables (3) *)
       "unused vars"                     >:: test_find_unused_vars;
       "unused vars underscore exempt"   >:: test_find_unused_vars_underscore_exempt;
       "unused vars clean"               >:: test_find_unused_vars_clean;
       (* Unused parameters (3) *)
       "unused params"                   >:: test_find_unused_params;
       "unused params underscore exempt" >:: test_find_unused_params_underscore_exempt;
       "unused params clean"             >:: test_find_unused_params_clean;
       (* Integration (2) *)
       "analyze_function all issues"     >:: test_analyze_function_all_issues;
       "analyze_program"                 >:: test_analyze_program;
     ])
