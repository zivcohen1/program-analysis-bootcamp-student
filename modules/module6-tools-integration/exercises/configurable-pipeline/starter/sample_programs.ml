(** Sample programs for multi-pass analysis testing (provided -- not a TODO). *)

open Shared_ast.Ast_types

(** Division by zero: x / 0. *)
let div_by_zero : program =
  [{ name = "compute"; params = [];
     body = [
       Assign ("x", IntLit 10);
       Assign ("y", IntLit 0);
       Assign ("result", BinOp (Div, Var "x", Var "y"));
       Return (Some (Var "result"));
     ] }]

(** Tainted data flows to sink: get_param → exec_query. *)
let taint_to_sink : program =
  [{ name = "handler"; params = [];
     body = [
       Assign ("input", Call ("get_param", [IntLit 0]));
       Assign ("_r", Call ("exec_query", [Var "input"]));
     ] }]

(** Safe program: no issues. *)
let safe_program : program =
  [{ name = "safe"; params = ["x"; "y"];
     body = [
       Assign ("result", BinOp (Add, Var "x", Var "y"));
       Return (Some (Var "result"));
     ] }]

(** Mixed issues: div-by-zero AND taint flow. *)
let mixed_issues : program =
  [{ name = "risky_compute"; params = [];
     body = [
       Assign ("a", IntLit 10);
       Assign ("b", IntLit 0);
       Assign ("c", BinOp (Div, Var "a", Var "b"));
       Assign ("input", Call ("get_param", [IntLit 0]));
       Assign ("_r", Call ("exec_query", [Var "input"]));
       Return (Some (Var "c"));
     ] }]

(** Dead code example: code after return. *)
let dead_code_example : program =
  [{ name = "example"; params = [];
     body = [
       Assign ("x", IntLit 42);
       Return (Some (Var "x"));
       Print [IntLit 99];
     ] }]
