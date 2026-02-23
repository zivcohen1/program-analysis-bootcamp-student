(** Symbol table with nested lexical scopes. *)

type symbol_info = {
  sym_name : string;
  sym_type : string;
  mutable_flag : bool;
}

(** Abstract type representing a scoped symbol table. *)
type t

(** [create ()] returns a new symbol table with a single empty scope. *)
val create : unit -> t

(** [define tbl name info] returns a new table with [name] bound to [info]
    in the current (innermost) scope. *)
val define : t -> string -> symbol_info -> t

(** [lookup tbl name] searches for [name] starting from the innermost scope
    outward. Returns [Some info] if found, [None] otherwise. *)
val lookup : t -> string -> symbol_info option

(** [enter_scope tbl] pushes a new empty scope onto the table. *)
val enter_scope : t -> t

(** [exit_scope tbl] pops the innermost scope. Returns [None] if only one
    scope remains (cannot pop the global scope). *)
val exit_scope : t -> t option
