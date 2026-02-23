(* sample_asts.ml - Pre-built AST examples for the structure-mapping exercise.
   These re-export the sample programs from the shared_ast library so you can
   reference them conveniently in ast_visualizer.ml. *)

(* Simple: result = (2 + 3) * 4 *)
let simple_arithmetic = Shared_ast.Sample_programs.simple_arithmetic

(* If-else branching *)
let branching = Shared_ast.Sample_programs.branching

(* While loop *)
let loop_example = Shared_ast.Sample_programs.loop_example

(* Multiple functions with calls *)
let multi_function = Shared_ast.Sample_programs.multi_function

(* Dead code example *)
let dead_code = Shared_ast.Sample_programs.dead_code

(* Constant folding opportunity *)
let constant_fold_example = Shared_ast.Sample_programs.constant_fold_example

(* Shadow variable example *)
let shadow_example = Shared_ast.Sample_programs.shadow_example
