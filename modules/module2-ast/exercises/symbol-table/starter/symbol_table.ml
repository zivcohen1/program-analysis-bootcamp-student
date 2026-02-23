(* Symbol table with nested lexical scopes.

   Internal representation
   -----------------------
   We use a list of maps as a scope stack.  The head of the list is the
   innermost (most local) scope, and the tail holds enclosing scopes all
   the way out to the global scope.

   Each scope is a [StringMap.t] mapping identifier names to [symbol_info]
   records.
*)

module StringMap = Map.Make (String)

type symbol_info = {
  sym_name : string;
  sym_type : string;
  mutable_flag : bool;
}

(* The type [t] is a scope stack: a list of maps from names to symbol_info.
   The head of the list is the innermost scope. *)
type t = symbol_info StringMap.t list

let create () : t =
  (* TODO: return a table with a single empty scope *)
  failwith "TODO"

let define (tbl : t) (_name : string) (_info : symbol_info) : t =
  (* TODO: add the binding to the innermost (head) scope *)
  ignore tbl;
  failwith "TODO"

let lookup (tbl : t) (_name : string) : symbol_info option =
  (* TODO: search from innermost scope outward; return first match *)
  ignore tbl;
  failwith "TODO"

let enter_scope (tbl : t) : t =
  (* TODO: push a new empty scope onto the front of the list *)
  ignore tbl;
  failwith "TODO"

let exit_scope (tbl : t) : t option =
  (* TODO: pop the innermost scope; return None if only one scope remains *)
  ignore tbl;
  failwith "TODO"
