(* MiniLang Analyzer
   Utility functions that walk the AST to extract information.

   TODO: Implement each function using pattern matching over the
   Shared_ast.Ast_types constructors. *)

open Shared_ast.Ast_types

(** Return the names of all functions defined in the program. *)
let extract_functions (_prog : program) : string list =
  failwith "TODO: implement extract_functions"

(** Return all variable names that appear on the left-hand side of an
    assignment anywhere in the given statement list (including nested
    blocks, if-branches, and while-bodies).  Duplicates are acceptable. *)
let extract_variables (_stmts : stmt list) : string list =
  failwith "TODO: implement extract_variables"

(** Return all function names that appear in Call expressions anywhere
    in the given statement list (including nested blocks).
    Duplicates are acceptable. *)
let extract_calls (_stmts : stmt list) : string list =
  failwith "TODO: implement extract_calls"
