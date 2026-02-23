open Ast_types

(* Simple: result = (2 + 3) * 4 *)
let simple_arithmetic : program =
  [{ name = "main"; params = [];
     body = [
       Assign ("result",
         BinOp (Mul,
           BinOp (Add, IntLit 2, IntLit 3),
           IntLit 4))
     ] }]

(* If-else branching *)
let branching : program =
  [{ name = "example"; params = ["x"];
     body = [
       Assign ("a", IntLit 1);
       Assign ("b", IntLit 2);
       If (BinOp (Gt, Var "x", IntLit 0),
         [Assign ("a", IntLit 3);
          Assign ("c", Var "a")],
         [Assign ("b", IntLit 4);
          Assign ("c", Var "b")]);
       Print [Var "a"; Var "b"; Var "c"];
       Return (Some (BinOp (Add, Var "a",
                       BinOp (Add, Var "b", Var "c"))))
     ] }]

(* While loop *)
let loop_example : program =
  [{ name = "loop"; params = ["n"];
     body = [
       Assign ("i", IntLit 0);
       While (BinOp (Lt, Var "i", Var "n"),
         [Print [Var "i"];
          Assign ("i", BinOp (Add, Var "i", IntLit 1))]);
       Return (Some (Var "i"))
     ] }]

(* Multiple functions with calls *)
let multi_function : program =
  [{ name = "helper"; params = ["param"];
     body = [
       Return (Some (BinOp (Add, Var "param", IntLit 1)))
     ] };
   { name = "process_data"; params = ["x"; "y"];
     body = [
       Assign ("temp", BinOp (Mul, Var "x", IntLit 2));
       Assign ("result1", Call ("helper", [Var "temp"]));
       Assign ("result2", Call ("helper", [Var "y"]));
       Return (Some (BinOp (Add, Var "result1", Var "result2")))
     ] };
   { name = "main"; params = [];
     body = [
       Assign ("a", IntLit 5);
       Assign ("b", IntLit 10);
       Assign ("output", Call ("process_data", [Var "a"; Var "b"]));
       Print [Var "output"]
     ] }]

(* Dead code example *)
let dead_code : program =
  [{ name = "example"; params = [];
     body = [
       Return (Some (IntLit 42));
       Print [Var "unreachable"];
     ] }]

(* Constant folding opportunity *)
let constant_fold_example : program =
  [{ name = "compute"; params = [];
     body = [
       Assign ("x", BinOp (Add, IntLit 2, IntLit 3));
       Assign ("y", BinOp (Mul, Var "x", IntLit 4));
       Return (Some (Var "y"))
     ] }]

(* Shadow variable example *)
let shadow_example : program =
  [{ name = "outer"; params = [];
     body = [
       Assign ("x", IntLit 10);
       If (BoolLit true,
         [Assign ("x", IntLit 20);
          Print [Var "x"]],
         []);
       Print [Var "x"]
     ] }]
