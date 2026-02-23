(** Abstract environment for the numeric analyzer.

    Part A: Provides the abstract environment type and operations
    needed by the analyzer.  Uses the MakeEnv functor from the
    abstract_domains library but adds lab-specific helpers.
*)

module StringMap = Map.Make (String)

(** Extended environment functor for the analyzer. *)
module MakeAnalysisEnv (D : Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN) = struct

  module BaseEnv = Abstract_domains.Abstract_env.MakeEnv (D)

  include BaseEnv

  (** Return the list of variables bound in this environment. *)
  let bound_vars (_env : t) : string list =
    failwith "TODO: return list of variable names in the environment"

  (** Restrict an environment to only the given variables. *)
  let restrict (_vars : string list) (_env : t) : t =
    failwith "TODO: keep only bindings for the given variables"

  (** Return the number of variables that are not top or bottom. *)
  let count_precise (_env : t) : int =
    failwith "TODO: count variables with values that are neither top nor bottom"
end
