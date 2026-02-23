(** Unit tests for the numeric analyzer (Lab 4, Part A). *)

open OUnit2

(* ------------------------------------------------------------------ *)
(* A simple test domain: flat constants                               *)
(* ------------------------------------------------------------------ *)

module TestDomain : Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN = struct
  type t = Bot | Const of int | Top

  let bottom = Bot
  let top = Top

  let join a b = match a, b with
    | Bot, x | x, Bot -> x
    | Const m, Const n when m = n -> Const m
    | _ -> Top

  let meet a b = match a, b with
    | Top, x | x, Top -> x
    | Const m, Const n when m = n -> Const m
    | _ -> Bot

  let leq a b = match a, b with
    | Bot, _ -> true | _, Top -> true
    | Const m, Const n -> m = n
    | _ -> false

  let equal a b = a = b
  let widen a b = join a b

  let to_string = function
    | Bot -> "Bot" | Const n -> Printf.sprintf "Const(%d)" n
    | Top -> "Top"
end

module A = Numeric_analyzer.Analyzer.Make (TestDomain)

(* ------------------------------------------------------------------ *)
(* Tests                                                              *)
(* ------------------------------------------------------------------ *)

let test_analyze_empty_function _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "empty"; params = []; body = [] } in
  let env = A.analyze_function func in
  let vars = A.Env.bound_vars env in
  assert_equal ~printer:string_of_int 0 (List.length vars)

let test_analyze_single_assign _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [Assign ("x", IntLit 5)] } in
  let env = A.analyze_function func in
  let x = A.Env.lookup "x" env in
  assert_bool "x should not be Bot" (not (TestDomain.equal x TestDomain.bottom))

let test_analyze_two_assigns _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [
      Assign ("x", IntLit 1);
      Assign ("y", IntLit 2);
    ] } in
  let env = A.analyze_function func in
  assert_bool "x should exist" (not (TestDomain.equal (A.Env.lookup "x" env) TestDomain.bottom));
  assert_bool "y should exist" (not (TestDomain.equal (A.Env.lookup "y" env) TestDomain.bottom))

let test_analyze_param_function _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = ["a"];
    body = [Assign ("b", Var "a")] } in
  let env = A.analyze_function func in
  let a = A.Env.lookup "a" env in
  assert_equal ~printer:TestDomain.to_string TestDomain.top a

let test_analyze_branch _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [
      If (BoolLit true,
        [Assign ("x", IntLit 1)],
        [Assign ("x", IntLit 2)]);
    ] } in
  let env = A.analyze_function func in
  let x = A.Env.lookup "x" env in
  assert_bool "x should not be Bot after branch"
    (not (TestDomain.equal x TestDomain.bottom))

let test_analyze_program _ctx =
  let open Shared_ast.Ast_types in
  let prog = [
    { name = "f1"; params = []; body = [Assign ("x", IntLit 1)] };
    { name = "f2"; params = []; body = [Assign ("y", IntLit 2)] };
  ] in
  let results = A.analyze_program prog in
  assert_equal ~printer:string_of_int 2 (List.length results)

let test_env_bound_vars _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [
      Assign ("a", IntLit 1);
      Assign ("b", IntLit 2);
      Assign ("c", IntLit 3);
    ] } in
  let env = A.analyze_function func in
  let vars = A.Env.bound_vars env in
  assert_equal ~printer:string_of_int 3 (List.length vars)

let test_env_restrict _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [
      Assign ("a", IntLit 1);
      Assign ("b", IntLit 2);
      Assign ("c", IntLit 3);
    ] } in
  let env = A.analyze_function func in
  let restricted = A.Env.restrict ["a"; "c"] env in
  let vars = A.Env.bound_vars restricted in
  assert_equal ~printer:string_of_int 2 (List.length vars)

let test_while_terminates _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [
      Assign ("i", IntLit 0);
      While (BinOp (Lt, Var "i", IntLit 10),
        [Assign ("i", BinOp (Add, Var "i", IntLit 1))]);
    ] } in
  let env = A.analyze_function func in
  let i = A.Env.lookup "i" env in
  assert_bool "i should not be Bot after loop"
    (not (TestDomain.equal i TestDomain.bottom))

let test_return_preserves_env _ctx =
  let open Shared_ast.Ast_types in
  let func = { name = "f"; params = [];
    body = [
      Assign ("x", IntLit 42);
      Return (Some (Var "x"));
    ] } in
  let env = A.analyze_function func in
  let x = A.Env.lookup "x" env in
  assert_bool "x should still be bound after return"
    (not (TestDomain.equal x TestDomain.bottom))

let () =
  run_test_tt_main
    ("Lab 4 Analyzer" >::: [
       "empty function"      >:: test_analyze_empty_function;
       "single assign"       >:: test_analyze_single_assign;
       "two assigns"         >:: test_analyze_two_assigns;
       "param function"      >:: test_analyze_param_function;
       "branch"              >:: test_analyze_branch;
       "program"             >:: test_analyze_program;
       "bound vars"          >:: test_env_bound_vars;
       "restrict"            >:: test_env_restrict;
       "while terminates"    >:: test_while_terminates;
       "return preserves"    >:: test_return_preserves_env;
     ])
