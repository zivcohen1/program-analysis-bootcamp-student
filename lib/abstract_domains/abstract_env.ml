(** Abstract environment: maps from variable names to abstract values.

    Given an abstract domain [D], [MakeEnv(D)] provides an environment
    type (StringMap over [D.t]) with pointwise lattice operations.

    This is the workhorse data structure for abstract interpretation:
    at each program point we maintain an environment mapping every
    known variable to its abstract value.
*)

module StringMap = Map.Make (String)

module MakeEnv (D : Abstract_domain.ABSTRACT_DOMAIN) = struct

  (** An environment is a map from variable names to abstract values.
      Variables absent from the map are implicitly [D.bottom]. *)
  type t = D.t StringMap.t

  (** The empty environment (all variables are bottom). *)
  let bottom : t = StringMap.empty

  (** Look up a variable, defaulting to [D.bottom] if absent. *)
  let lookup (var : string) (env : t) : D.t =
    match StringMap.find_opt var env with
    | Some v -> v
    | None -> D.bottom

  (** Bind a variable to an abstract value. *)
  let update (var : string) (v : D.t) (env : t) : t =
    StringMap.add var v env

  (** Pointwise join of two environments.
      For each variable, take [D.join] of the values from both maps. *)
  let join (a : t) (b : t) : t =
    StringMap.union (fun _key va vb -> Some (D.join va vb)) a b

  (** Pointwise meet of two environments. *)
  let meet (a : t) (b : t) : t =
    StringMap.merge
      (fun _key va vb ->
        match va, vb with
        | Some x, Some y -> Some (D.meet x y)
        | _ -> None)
      a b

  (** Pointwise widening of two environments. *)
  let widen (a : t) (b : t) : t =
    StringMap.union (fun _key va vb -> Some (D.widen va vb)) a b

  (** Pointwise partial order: [leq a b] iff for every variable v,
      [D.leq (lookup v a) (lookup v b)]. *)
  let leq (a : t) (b : t) : bool =
    StringMap.for_all
      (fun var va -> D.leq va (lookup var b))
      a

  (** Equality: two environments are equal when they map every variable
      to equal abstract values. *)
  let equal (a : t) (b : t) : bool =
    leq a b && leq b a

  (** Pretty-print an environment as {x -> ..., y -> ...}. *)
  let to_string (env : t) : string =
    let bindings = StringMap.bindings env in
    let parts =
      List.map (fun (var, v) -> var ^ " -> " ^ D.to_string v) bindings
    in
    "{" ^ String.concat ", " parts ^ "}"
end
