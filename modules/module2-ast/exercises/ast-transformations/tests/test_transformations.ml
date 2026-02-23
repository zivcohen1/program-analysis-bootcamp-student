(* test_transformations.ml - OUnit2 tests for the three AST transformations. *)

open OUnit2
open Shared_ast.Ast_types
open Ast_transformations

(* ========================================================================
   Constant folding
   ======================================================================== *)

let test_fold_two_ints _ =
  (* 2 + 3  -->  5 *)
  let input = BinOp (Add, IntLit 2, IntLit 3) in
  assert_equal (IntLit 5) (Transformations.constant_fold input)

let test_fold_subtraction _ =
  (* 10 - 4  -->  6 *)
  let input = BinOp (Sub, IntLit 10, IntLit 4) in
  assert_equal (IntLit 6) (Transformations.constant_fold input)

let test_fold_multiplication _ =
  (* 3 * 7  -->  21 *)
  let input = BinOp (Mul, IntLit 3, IntLit 7) in
  assert_equal (IntLit 21) (Transformations.constant_fold input)

let test_fold_division _ =
  (* 10 / 2  -->  5 *)
  let input = BinOp (Div, IntLit 10, IntLit 2) in
  assert_equal (IntLit 5) (Transformations.constant_fold input)

let test_fold_nested _ =
  (* 2 * (1 + 3)  -->  8 *)
  let input = BinOp (Mul, IntLit 2, BinOp (Add, IntLit 1, IntLit 3)) in
  assert_equal (IntLit 8) (Transformations.constant_fold input)

let test_fold_deeply_nested _ =
  (* (1 + 2) + (3 + 4)  -->  10 *)
  let input =
    BinOp (Add,
      BinOp (Add, IntLit 1, IntLit 2),
      BinOp (Add, IntLit 3, IntLit 4))
  in
  assert_equal (IntLit 10) (Transformations.constant_fold input)

let test_fold_comparison _ =
  (* 3 < 5  -->  true *)
  let input = BinOp (Lt, IntLit 3, IntLit 5) in
  assert_equal (BoolLit true) (Transformations.constant_fold input)

let test_fold_logical _ =
  (* true && false  -->  false *)
  let input = BinOp (And, BoolLit true, BoolLit false) in
  assert_equal (BoolLit false) (Transformations.constant_fold input)

let test_fold_nonconstant_unchanged _ =
  (* x + 1  stays  x + 1 *)
  let input = BinOp (Add, Var "x", IntLit 1) in
  assert_equal (BinOp (Add, Var "x", IntLit 1))
    (Transformations.constant_fold input)

let test_fold_partial_nested _ =
  (* x + (2 + 3)  -->  x + 5 *)
  let input = BinOp (Add, Var "x", BinOp (Add, IntLit 2, IntLit 3)) in
  assert_equal (BinOp (Add, Var "x", IntLit 5))
    (Transformations.constant_fold input)

let test_fold_unary_neg _ =
  (* -(5)  -->  -5 *)
  let input = UnaryOp (Neg, IntLit 5) in
  assert_equal (IntLit (-5)) (Transformations.constant_fold input)

let test_fold_unary_not _ =
  (* not true  -->  false *)
  let input = UnaryOp (Not, BoolLit true) in
  assert_equal (BoolLit false) (Transformations.constant_fold input)

let constant_fold_tests = "constant_fold" >::: [
  "two_ints"            >:: test_fold_two_ints;
  "subtraction"         >:: test_fold_subtraction;
  "multiplication"      >:: test_fold_multiplication;
  "division"            >:: test_fold_division;
  "nested"              >:: test_fold_nested;
  "deeply_nested"       >:: test_fold_deeply_nested;
  "comparison"          >:: test_fold_comparison;
  "logical"             >:: test_fold_logical;
  "nonconstant"         >:: test_fold_nonconstant_unchanged;
  "partial_nested"      >:: test_fold_partial_nested;
  "unary_neg"           >:: test_fold_unary_neg;
  "unary_not"           >:: test_fold_unary_not;
]

(* ========================================================================
   Variable renaming
   ======================================================================== *)

let test_rename_assign_lhs _ =
  (* x = 1  -->  tmp = 1  (rename x -> tmp) *)
  let input = [Assign ("x", IntLit 1)] in
  let expected = [Assign ("tmp", IntLit 1)] in
  assert_equal expected (Transformations.rename_variable "x" "tmp" input)

let test_rename_var_in_expr _ =
  (* y = x  -->  y = tmp *)
  let input = [Assign ("y", Var "x")] in
  let expected = [Assign ("y", Var "tmp")] in
  assert_equal expected (Transformations.rename_variable "x" "tmp" input)

let test_rename_print _ =
  (* print(x)  -->  print(tmp) *)
  let input = [Print [Var "x"]] in
  let expected = [Print [Var "tmp"]] in
  assert_equal expected (Transformations.rename_variable "x" "tmp" input)

let test_rename_full_example _ =
  (* x = 1; y = x; print(x)  -->  tmp = 1; y = tmp; print(tmp) *)
  let input = Build_sample_ast.rename_example in
  let expected =
    [ Assign ("tmp", IntLit 1);
      Assign ("y", Var "tmp");
      Print [Var "tmp"] ]
  in
  assert_equal expected (Transformations.rename_variable "x" "tmp" input)

let test_rename_leaves_others _ =
  (* Renaming "x" should not touch "y" *)
  let input = [Assign ("y", IntLit 1); Print [Var "y"]] in
  assert_equal input (Transformations.rename_variable "x" "tmp" input)

let test_rename_in_if _ =
  (* if (x > 0) { x = 1 } else { x = 2 }  rename x -> z *)
  let input =
    [If (BinOp (Gt, Var "x", IntLit 0),
      [Assign ("x", IntLit 1)],
      [Assign ("x", IntLit 2)])]
  in
  let expected =
    [If (BinOp (Gt, Var "z", IntLit 0),
      [Assign ("z", IntLit 1)],
      [Assign ("z", IntLit 2)])]
  in
  assert_equal expected (Transformations.rename_variable "x" "z" input)

let test_rename_in_while _ =
  (* while (x < 10) { x = x + 1 }  rename x -> i *)
  let input =
    [While (BinOp (Lt, Var "x", IntLit 10),
      [Assign ("x", BinOp (Add, Var "x", IntLit 1))])]
  in
  let expected =
    [While (BinOp (Lt, Var "i", IntLit 10),
      [Assign ("i", BinOp (Add, Var "i", IntLit 1))])]
  in
  assert_equal expected (Transformations.rename_variable "x" "i" input)

let test_rename_in_return _ =
  (* return x  -->  return tmp *)
  let input = [Return (Some (Var "x"))] in
  let expected = [Return (Some (Var "tmp"))] in
  assert_equal expected (Transformations.rename_variable "x" "tmp" input)

let rename_variable_tests = "rename_variable" >::: [
  "assign_lhs"    >:: test_rename_assign_lhs;
  "var_in_expr"   >:: test_rename_var_in_expr;
  "print"         >:: test_rename_print;
  "full_example"  >:: test_rename_full_example;
  "leaves_others" >:: test_rename_leaves_others;
  "in_if"         >:: test_rename_in_if;
  "in_while"      >:: test_rename_in_while;
  "in_return"     >:: test_rename_in_return;
]

(* ========================================================================
   Dead-code elimination
   ======================================================================== *)

let test_dce_after_return _ =
  (* return 42; print(x)  -->  return 42 *)
  let input = Build_sample_ast.dead_code_example in
  let expected = [Return (Some (IntLit 42))] in
  assert_equal expected (Transformations.eliminate_dead_code input)

let test_dce_multiple_after_return _ =
  (* return 1; x = 2; y = 3; print(x)  -->  return 1 *)
  let input =
    [ Return (Some (IntLit 1));
      Assign ("x", IntLit 2);
      Assign ("y", IntLit 3);
      Print [Var "x"] ]
  in
  let expected = [Return (Some (IntLit 1))] in
  assert_equal expected (Transformations.eliminate_dead_code input)

let test_dce_no_return _ =
  (* x = 1; print(x)  -->  unchanged *)
  let input = [Assign ("x", IntLit 1); Print [Var "x"]] in
  assert_equal input (Transformations.eliminate_dead_code input)

let test_dce_if_true _ =
  (* if (true) { x = 1 } else { x = 2 }  -->  Block [x = 1] *)
  let input =
    [If (BoolLit true,
      [Assign ("x", IntLit 1)],
      [Assign ("x", IntLit 2)])]
  in
  let expected = [Block [Assign ("x", IntLit 1)]] in
  assert_equal expected (Transformations.eliminate_dead_code input)

let test_dce_if_false _ =
  (* if (false) { x = 1 } else { x = 2 }  -->  Block [x = 2] *)
  let input =
    [If (BoolLit false,
      [Assign ("x", IntLit 1)],
      [Assign ("x", IntLit 2)])]
  in
  let expected = [Block [Assign ("x", IntLit 2)]] in
  assert_equal expected (Transformations.eliminate_dead_code input)

let test_dce_if_false_empty_else _ =
  (* if (false) { x = 1 } else { }  -->  Block [] *)
  let input =
    [If (BoolLit false,
      [Assign ("x", IntLit 1)],
      [])]
  in
  let expected = [Block []] in
  assert_equal expected (Transformations.eliminate_dead_code input)

let test_dce_nested_return_in_if _ =
  (* if (cond) { return 1; x = dead } else { y = 2 }
     -->  if (cond) { return 1 } else { y = 2 } *)
  let input =
    [If (Var "cond",
      [Return (Some (IntLit 1)); Assign ("x", Var "dead")],
      [Assign ("y", IntLit 2)])]
  in
  let expected =
    [If (Var "cond",
      [Return (Some (IntLit 1))],
      [Assign ("y", IntLit 2)])]
  in
  assert_equal expected (Transformations.eliminate_dead_code input)

let test_dce_preserves_before_return _ =
  (* x = 1; return x; y = 2  -->  x = 1; return x *)
  let input =
    [ Assign ("x", IntLit 1);
      Return (Some (Var "x"));
      Assign ("y", IntLit 2) ]
  in
  let expected =
    [ Assign ("x", IntLit 1);
      Return (Some (Var "x")) ]
  in
  assert_equal expected (Transformations.eliminate_dead_code input)

let dead_code_tests = "eliminate_dead_code" >::: [
  "after_return"           >:: test_dce_after_return;
  "multiple_after_return"  >:: test_dce_multiple_after_return;
  "no_return"              >:: test_dce_no_return;
  "if_true"                >:: test_dce_if_true;
  "if_false"               >:: test_dce_if_false;
  "if_false_empty_else"    >:: test_dce_if_false_empty_else;
  "nested_return_in_if"    >:: test_dce_nested_return_in_if;
  "preserves_before_return" >:: test_dce_preserves_before_return;
]

(* ========================================================================
   Runner
   ======================================================================== *)

let () =
  run_test_tt_main ("AST Transformations" >::: [
    constant_fold_tests;
    rename_variable_tests;
    dead_code_tests;
  ])
