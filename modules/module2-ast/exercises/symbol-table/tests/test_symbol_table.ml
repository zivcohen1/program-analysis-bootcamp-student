open OUnit2
open Symbol_table_lib.Symbol_table

(* ------------------------------------------------------------------ *)
(* Helpers                                                             *)
(* ------------------------------------------------------------------ *)

let mk_info ?(mut = false) name ty =
  { sym_name = name; sym_type = ty; mutable_flag = mut }

(* ------------------------------------------------------------------ *)
(* Tests                                                               *)
(* ------------------------------------------------------------------ *)

let test_create_and_define _ =
  let tbl = create () in
  let info = mk_info "x" "int" in
  let tbl = define tbl "x" info in
  match lookup tbl "x" with
  | Some found ->
    assert_equal "x"   found.sym_name;
    assert_equal "int" found.sym_type;
    assert_equal false  found.mutable_flag
  | None ->
    assert_failure "expected to find 'x' after define"

let test_lookup_current_scope _ =
  let tbl = create () in
  let tbl = define tbl "a" (mk_info "a" "bool") in
  let tbl = define tbl "b" (mk_info ~mut:true "b" "string") in
  (* Both symbols should be found in the same scope *)
  (match lookup tbl "a" with
   | Some i -> assert_equal "bool" i.sym_type
   | None   -> assert_failure "expected 'a'");
  (match lookup tbl "b" with
   | Some i ->
     assert_equal "string" i.sym_type;
     assert_equal true i.mutable_flag
   | None   -> assert_failure "expected 'b'")

let test_lookup_across_scopes _ =
  (* Define 'x' in global scope, then enter a new scope and look it up. *)
  let tbl = create () in
  let tbl = define tbl "x" (mk_info "x" "int") in
  let tbl = enter_scope tbl in
  (* 'x' should still be visible from the inner scope *)
  (match lookup tbl "x" with
   | Some i -> assert_equal "int" i.sym_type
   | None   -> assert_failure "expected 'x' visible from inner scope")

let test_shadowing _ =
  (* Outer scope has x:int; inner scope redefines x:float. *)
  let tbl = create () in
  let tbl = define tbl "x" (mk_info "x" "int") in
  let tbl = enter_scope tbl in
  let tbl = define tbl "x" (mk_info "x" "float") in
  (* The inner definition should shadow the outer one *)
  (match lookup tbl "x" with
   | Some i -> assert_equal "float" i.sym_type
   | None   -> assert_failure "expected shadowed 'x'")

let test_exit_scope _ =
  let tbl = create () in
  let tbl = enter_scope tbl in
  (* Exiting the inner scope should succeed *)
  (match exit_scope tbl with
   | Some _ -> ()
   | None   -> assert_failure "expected Some after exit_scope");
  (* Exiting the only remaining (global) scope should return None *)
  let tbl = create () in
  (match exit_scope tbl with
   | None   -> ()
   | Some _ -> assert_failure "expected None when popping the global scope")

let test_lookup_after_exit_scope _ =
  (* Define 'x' in outer, 'y' in inner.  After exit_scope, 'x' should
     still be found but 'y' should be gone. *)
  let tbl = create () in
  let tbl = define tbl "x" (mk_info "x" "int") in
  let tbl = enter_scope tbl in
  let tbl = define tbl "y" (mk_info "y" "bool") in
  (* Both visible before exit *)
  assert_bool "y visible before exit" (lookup tbl "y" <> None);
  assert_bool "x visible before exit" (lookup tbl "x" <> None);
  (* Exit the inner scope *)
  let tbl = match exit_scope tbl with
    | Some t -> t
    | None   -> assert_failure "exit_scope should succeed"
  in
  (* 'x' should still be reachable; 'y' should not *)
  (match lookup tbl "x" with
   | Some i -> assert_equal "int" i.sym_type
   | None   -> assert_failure "expected 'x' after exit_scope");
  (match lookup tbl "y" with
   | Some _ -> assert_failure "'y' should not be visible after exit_scope"
   | None   -> ())

(* ------------------------------------------------------------------ *)
(* Suite                                                               *)
(* ------------------------------------------------------------------ *)

let suite =
  "Symbol_table tests" >::: [
    "create and define"         >:: test_create_and_define;
    "lookup current scope"      >:: test_lookup_current_scope;
    "lookup across scopes"      >:: test_lookup_across_scopes;
    "shadowing"                 >:: test_shadowing;
    "exit_scope"                >:: test_exit_scope;
    "lookup after exit_scope"   >:: test_lookup_after_exit_scope;
  ]

let () = run_test_tt_main suite
