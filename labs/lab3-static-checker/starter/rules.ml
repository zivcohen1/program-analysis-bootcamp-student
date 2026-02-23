(** [check_unused_variables func] returns a list of issues for variables
    that are assigned (appear on the LHS of an Assign statement) but are
    never referenced (never appear as a Var node in any expression) within
    [func].

    Approach:
    1. Walk all statements to collect the set of assigned variable names.
    2. Walk all expressions to collect the set of used variable names.
    3. Any variable in the assigned set but NOT in the used set is unused.
    4. Parameters count as "used" implicitly (they are not assigned by the
       programmer, so they should not be flagged). *)
let check_unused_variables (_func : Shared_ast.Ast_types.func_def) : Reporter.issue list =
  failwith "TODO: implement check_unused_variables"

(** [check_unreachable_code func] returns a list of issues for statements
    that appear after a Return statement within the same statement list.

    Approach:
    - Scan each statement list (the function body, and recursively the
      bodies of If branches and While loops).
    - When a Return is encountered, every subsequent statement in that
      same list is unreachable. *)
let check_unreachable_code (_func : Shared_ast.Ast_types.func_def) : Reporter.issue list =
  failwith "TODO: implement check_unreachable_code"

(** [check_shadowed_variables func] returns a list of issues for variables
    that are assigned inside a nested scope (the body of an If branch or
    While loop) when a variable of the same name was already assigned in
    an outer scope of the same function.

    Approach:
    - Track the set of variables defined at the current scope level.
    - When entering a nested scope (If/While body), check each Assign
      against the outer set. If the variable already exists, report
      shadowing. *)
let check_shadowed_variables (_func : Shared_ast.Ast_types.func_def) : Reporter.issue list =
  failwith "TODO: implement check_shadowed_variables"
