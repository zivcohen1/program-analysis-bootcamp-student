(** Example multi-function program for interprocedural analysis.

    This is the same program as [Sample_programs.multi_function]:

    {v
    def helper(param):
        return param + 1

    def process_data(x, y):
        temp = x * 2
        result1 = helper(temp)
        result2 = helper(y)
        return result1 + result2

    def main():
        a = 5
        b = 10
        output = process_data(a, b)
        print(output)
    v}

    Call graph:  main -> process_data -> helper  *)

open Shared_ast.Ast_types

let program : program =
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
