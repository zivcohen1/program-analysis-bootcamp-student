(** [check_program program] runs all static analysis rules on every
    function definition in [program] and returns the aggregated list
    of issues.

    The rules to run are:
    - [Rules.check_unused_variables]
    - [Rules.check_unreachable_code]
    - [Rules.check_shadowed_variables] *)
let check_program (_program : Shared_ast.Ast_types.program) : Reporter.issue list =
  failwith "TODO: implement check_program"
