(** Sample programs for taint propagation testing (provided). *)

open Shared_ast.Ast_types

(** SQL injection: tainted input flows to exec_query. *)
let sql_injection : program =
  [{ name = "handle_request"; params = [];
     body = [
       Assign ("input", Call ("get_param", [IntLit 0]));
       Assign ("query", BinOp (Add, Var "input", IntLit 0));
       Assign ("_result", Call ("exec_query", [Var "query"]));
     ] }]

(** Sanitized: tainted input cleaned before reaching sink. *)
let sanitized : program =
  [{ name = "safe_handler"; params = [];
     body = [
       Assign ("input", Call ("get_param", [IntLit 0]));
       Assign ("safe", Call ("escape_sql", [Var "input"]));
       Assign ("query", BinOp (Add, Var "safe", IntLit 0));
       Assign ("_result", Call ("exec_query", [Var "query"]));
     ] }]

(** Clean: no tainted sources at all. *)
let clean : program =
  [{ name = "compute"; params = [];
     body = [
       Assign ("x", IntLit 42);
       Assign ("y", BinOp (Add, Var "x", IntLit 1));
     ] }]

(** Branch taint: taint flows through one branch. *)
let branch_taint : program =
  [{ name = "branching"; params = [];
     body = [
       Assign ("input", Call ("get_param", [IntLit 0]));
       If (BoolLit true,
         [Assign ("x", Var "input")],
         [Assign ("x", IntLit 0)]);
     ] }]
