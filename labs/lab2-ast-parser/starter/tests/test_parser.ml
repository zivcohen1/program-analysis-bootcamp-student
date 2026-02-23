(* Unit tests for the MiniLang parser and analyzer.
   These tests will FAIL until you complete the TODO sections in
   parser.mly and analyzer.ml. *)

open OUnit2
open Shared_ast.Ast_types

(* ---- Parser tests ---- *)

let test_parse_simple_assign _ =
  let prog = Minilang_parser.Ast_parser.parse_string
    "fun main() { x = 42; }" in
  assert_equal 1 (List.length prog);
  let f = List.hd prog in
  assert_equal "main" f.name;
  assert_equal 0 (List.length f.params);
  match f.body with
  | [ Assign ("x", IntLit 42) ] -> ()
  | _ -> assert_failure "Expected single assignment x = 42"

let test_parse_binop _ =
  let prog = Minilang_parser.Ast_parser.parse_string
    "fun f() { y = 1 + 2 * 3; }" in
  let f = List.hd prog in
  match f.body with
  | [ Assign ("y", BinOp (Add, IntLit 1, BinOp (Mul, IntLit 2, IntLit 3))) ] -> ()
  | _ -> assert_failure "Expected y = 1 + 2 * 3 with correct precedence"

let test_parse_if_else _ =
  let prog = Minilang_parser.Ast_parser.parse_string
    "fun f() { if (x > 0) { y = 1; } else { y = 0; } }" in
  let f = List.hd prog in
  match f.body with
  | [ If (BinOp (Gt, Var "x", IntLit 0),
          [ Assign ("y", IntLit 1) ],
          [ Assign ("y", IntLit 0) ]) ] -> ()
  | _ -> assert_failure "Expected if-else structure"

let test_parse_while _ =
  let prog = Minilang_parser.Ast_parser.parse_string
    "fun f() { while (i < 10) { i = i + 1; } }" in
  let f = List.hd prog in
  match f.body with
  | [ While (BinOp (Lt, Var "i", IntLit 10),
             [ Assign ("i", BinOp (Add, Var "i", IntLit 1)) ]) ] -> ()
  | _ -> assert_failure "Expected while loop"

let test_parse_return _ =
  let prog = Minilang_parser.Ast_parser.parse_string
    "fun f() { return 42; }" in
  let f = List.hd prog in
  match f.body with
  | [ Return (Some (IntLit 42)) ] -> ()
  | _ -> assert_failure "Expected return 42"

let test_parse_return_void _ =
  let prog = Minilang_parser.Ast_parser.parse_string
    "fun f() { return; }" in
  let f = List.hd prog in
  match f.body with
  | [ Return None ] -> ()
  | _ -> assert_failure "Expected void return"

let test_parse_print _ =
  let prog = Minilang_parser.Ast_parser.parse_string
    "fun f() { print(x, y); }" in
  let f = List.hd prog in
  match f.body with
  | [ Print [ Var "x"; Var "y" ] ] -> ()
  | _ -> assert_failure "Expected print(x, y)"

(* ---- Analyzer tests ---- *)

let test_extract_functions _ =
  let prog = Minilang_parser.Ast_parser.parse_string
    "fun foo() { x = 1; } fun bar(a, b) { y = a; }" in
  let names = Minilang_parser.Analyzer.extract_functions prog in
  assert_equal [ "foo"; "bar" ] names

let test_extract_variables _ =
  let prog = Minilang_parser.Ast_parser.parse_string
    "fun f() { x = 1; y = 2; if (x > 0) { z = 3; } else { w = 4; } }" in
  let f = List.hd prog in
  let vars = Minilang_parser.Analyzer.extract_variables f.body in
  List.iter (fun v ->
    assert_bool (Printf.sprintf "Expected variable %s" v)
      (List.mem v vars)
  ) [ "x"; "y"; "z"; "w" ]

(* ---- Test suite ---- *)

let suite =
  "MiniLang Parser Tests" >::: [
    "parse simple assign"  >:: test_parse_simple_assign;
    "parse binop"          >:: test_parse_binop;
    "parse if-else"        >:: test_parse_if_else;
    "parse while"          >:: test_parse_while;
    "parse return"         >:: test_parse_return;
    "parse return void"    >:: test_parse_return_void;
    "parse print"          >:: test_parse_print;
    "extract functions"    >:: test_extract_functions;
    "extract variables"    >:: test_extract_variables;
  ]

let () = run_test_tt_main suite
