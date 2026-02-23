(** Analysis pass registry (provided -- not a TODO).

    Contains complete implementations of safety, taint, and dead-code
    analysis passes, ready to be composed by the pipeline. *)

open Shared_ast.Ast_types

(* ------------------------------------------------------------------ *)
(* Analysis pass type                                                 *)
(* ------------------------------------------------------------------ *)

type analysis_pass = {
  name : string;
  category : Finding_types.category;
  run : program -> Finding_types.finding list;
}

let next_id = ref 0
let fresh_id () = incr next_id; !next_id

(* ------------------------------------------------------------------ *)
(* Safety pass (sign domain)                                          *)
(* ------------------------------------------------------------------ *)

module SignEnv = Abstract_domains.Abstract_env.MakeEnv (struct
  type t = Sign_domain.sign
  let bottom = Sign_domain.bottom
  let top = Sign_domain.top
  let join = Sign_domain.join
  let meet = Sign_domain.meet
  let leq = Sign_domain.leq
  let equal = Sign_domain.equal
  let widen = Sign_domain.widen
  let to_string = Sign_domain.to_string
end)

let rec eval_sign (env : SignEnv.t) (e : expr) : Sign_domain.sign =
  match e with
  | IntLit n -> Sign_domain.alpha_int n
  | BoolLit _ -> Sign_domain.Top
  | Var x -> SignEnv.lookup x env
  | BinOp (Add, e1, e2) ->
    Sign_domain.abstract_add (eval_sign env e1) (eval_sign env e2)
  | BinOp (Sub, e1, e2) ->
    Sign_domain.abstract_sub (eval_sign env e1) (eval_sign env e2)
  | BinOp (Mul, e1, e2) ->
    Sign_domain.abstract_mul (eval_sign env e1) (eval_sign env e2)
  | BinOp (Div, e1, e2) ->
    Sign_domain.abstract_div (eval_sign env e1) (eval_sign env e2)
  | BinOp (_, _, _) -> Sign_domain.Top
  | UnaryOp (Neg, e1) -> Sign_domain.abstract_neg (eval_sign env e1)
  | UnaryOp (Not, _) -> Sign_domain.Top
  | Call (_, _) -> Sign_domain.Top

let rec transfer_sign (func_name : string) (env : SignEnv.t)
    (s : stmt) : SignEnv.t * Finding_types.finding list =
  match s with
  | Assign (x, e) ->
    let findings = match e with
      | BinOp (Div, _, denom) ->
        let d = eval_sign env denom in
        (match d with
         | Sign_domain.Zero ->
           [{ Finding_types.id = fresh_id ();
              category = Safety; severity = High;
              pass_name = "safety"; location = func_name;
              message = "Division by zero (divisor is always zero)";
              suggestion = Some "Check divisor before dividing"; }]
         | Sign_domain.Top ->
           [{ Finding_types.id = fresh_id ();
              category = Safety; severity = Medium;
              pass_name = "safety"; location = func_name;
              message = "Potential division by zero (divisor may be zero)";
              suggestion = Some "Add a zero check for divisor"; }]
         | _ -> [])
      | _ -> []
    in
    let v = eval_sign env e in
    (SignEnv.update x v env, findings)
  | If (_, then_b, else_b) ->
    let (env_t, f_t) = transfer_sign_stmts func_name env then_b in
    let (env_e, f_e) = transfer_sign_stmts func_name env else_b in
    (SignEnv.join env_t env_e, f_t @ f_e)
  | While (_, body) ->
    let rec fixpoint env_in n =
      if n >= 100 then env_in
      else
        let (env_body, _) = transfer_sign_stmts func_name env_in body in
        let env_next = SignEnv.widen env_in (SignEnv.join env_in env_body) in
        if SignEnv.equal env_in env_next then env_next
        else fixpoint env_next (n + 1)
    in
    let env' = fixpoint env 0 in
    let (_, vulns) = transfer_sign_stmts func_name env' body in
    (env', vulns)
  | Return _ | Print _ -> (env, [])
  | Block stmts -> transfer_sign_stmts func_name env stmts

and transfer_sign_stmts (func_name : string) (env : SignEnv.t)
    (stmts : stmt list) : SignEnv.t * Finding_types.finding list =
  List.fold_left
    (fun (acc_env, acc_f) s ->
      let (env', f) = transfer_sign func_name acc_env s in
      (env', acc_f @ f))
    (env, []) stmts

let safety_pass : analysis_pass =
  { name = "safety"; category = Safety;
    run = fun prog ->
      List.concat_map (fun func ->
        let init = List.fold_left
          (fun env p -> SignEnv.update p Sign_domain.Top env)
          SignEnv.bottom func.params in
        let (_, findings) = transfer_sign_stmts func.name init func.body in
        findings) prog; }

(* ------------------------------------------------------------------ *)
(* Taint pass                                                         *)
(* ------------------------------------------------------------------ *)

module TaintEnv = Abstract_domains.Abstract_env.MakeEnv (struct
  type t = Taint_domain.taint
  let bottom = Taint_domain.bottom
  let top = Taint_domain.top
  let join = Taint_domain.join
  let meet = Taint_domain.meet
  let leq = Taint_domain.leq
  let equal = Taint_domain.equal
  let widen = Taint_domain.widen
  let to_string = Taint_domain.to_string
end)

let sources = ["get_param"; "read_cookie"; "read_input"; "read_file"; "get_header"]
let sinks = [("exec_query", "sql-injection"); ("send_response", "xss");
             ("exec_cmd", "command-injection"); ("open_file", "path-traversal")]
let sanitizers = ["escape_sql"; "html_encode"; "shell_escape"; "validate_path"]
let is_source name = List.mem name sources
let find_sink name = List.assoc_opt name sinks
let is_sanitizer name = List.mem name sanitizers

let rec eval_taint (env : TaintEnv.t) (e : expr) : Taint_domain.taint =
  match e with
  | IntLit _ | BoolLit _ -> Taint_domain.Untainted
  | Var x -> TaintEnv.lookup x env
  | BinOp (_, e1, e2) ->
    Taint_domain.propagate (eval_taint env e1) (eval_taint env e2)
  | UnaryOp (_, e1) -> eval_taint env e1
  | Call (name, _) ->
    if is_source name then Taint_domain.Tainted
    else if is_sanitizer name then Taint_domain.Untainted
    else Taint_domain.Top

let rec transfer_taint (func_name : string) (env : TaintEnv.t)
    (s : stmt) : TaintEnv.t * Finding_types.finding list =
  match s with
  | Assign (x, e) ->
    let findings = match e with
      | Call (name, args) ->
        (match find_sink name with
         | Some vuln_type ->
           if List.length args > 0 then
             let arg_taint = eval_taint env (List.hd args) in
             if Taint_domain.is_potentially_tainted arg_taint then
               [{ Finding_types.id = fresh_id ();
                  category = Security; severity = Critical;
                  pass_name = "taint"; location = func_name;
                  message = Printf.sprintf "Tainted data flows to %s (potential %s)"
                    name vuln_type;
                  suggestion = None; }]
             else []
           else []
         | None -> [])
      | _ -> []
    in
    let v = eval_taint env e in
    (TaintEnv.update x v env, findings)
  | If (_, then_b, else_b) ->
    let (env_t, f_t) = transfer_taint_stmts func_name env then_b in
    let (env_e, f_e) = transfer_taint_stmts func_name env else_b in
    (TaintEnv.join env_t env_e, f_t @ f_e)
  | While (_, body) ->
    let rec fixpoint env_in n =
      if n >= 100 then env_in
      else
        let (env_body, _) = transfer_taint_stmts func_name env_in body in
        let env_next = TaintEnv.widen env_in (TaintEnv.join env_in env_body) in
        if TaintEnv.equal env_in env_next then env_next
        else fixpoint env_next (n + 1)
    in
    let env' = fixpoint env 0 in
    let (_, vulns) = transfer_taint_stmts func_name env' body in
    (env', vulns)
  | Return _ | Print _ -> (env, [])
  | Block stmts -> transfer_taint_stmts func_name env stmts

and transfer_taint_stmts (func_name : string) (env : TaintEnv.t)
    (stmts : stmt list) : TaintEnv.t * Finding_types.finding list =
  List.fold_left
    (fun (acc_env, acc_f) s ->
      let (env', f) = transfer_taint func_name acc_env s in
      (env', acc_f @ f))
    (env, []) stmts

let taint_pass : analysis_pass =
  { name = "taint"; category = Security;
    run = fun prog ->
      List.concat_map (fun func ->
        let init = List.fold_left
          (fun env p -> TaintEnv.update p Taint_domain.Top env)
          TaintEnv.bottom func.params in
        let (_, findings) = transfer_taint_stmts func.name init func.body in
        findings) prog; }

(* ------------------------------------------------------------------ *)
(* Dead-code pass (purely AST)                                        *)
(* ------------------------------------------------------------------ *)

module StringSet = Set.Make (String)

let rec collect_used_vars_expr (e : expr) : StringSet.t =
  match e with
  | IntLit _ | BoolLit _ -> StringSet.empty
  | Var x -> StringSet.singleton x
  | BinOp (_, e1, e2) ->
    StringSet.union (collect_used_vars_expr e1) (collect_used_vars_expr e2)
  | UnaryOp (_, e1) -> collect_used_vars_expr e1
  | Call (_, args) ->
    List.fold_left
      (fun acc a -> StringSet.union acc (collect_used_vars_expr a))
      StringSet.empty args

let rec collect_used_vars_stmts (stmts : stmt list) : StringSet.t =
  List.fold_left
    (fun acc s -> StringSet.union acc (collect_used_vars_stmt s))
    StringSet.empty stmts

and collect_used_vars_stmt (s : stmt) : StringSet.t =
  match s with
  | Assign (_, e) -> collect_used_vars_expr e
  | If (cond, t, e) ->
    StringSet.union (collect_used_vars_expr cond)
      (StringSet.union (collect_used_vars_stmts t) (collect_used_vars_stmts e))
  | While (cond, body) ->
    StringSet.union (collect_used_vars_expr cond) (collect_used_vars_stmts body)
  | Return (Some e) -> collect_used_vars_expr e
  | Return None -> StringSet.empty
  | Print exprs ->
    List.fold_left (fun acc e -> StringSet.union acc (collect_used_vars_expr e))
      StringSet.empty exprs
  | Block stmts -> collect_used_vars_stmts stmts

let stmts_after_return (stmts : stmt list) : stmt list =
  let rec loop = function
    | [] -> []
    | (Return _) :: rest -> rest
    | _ :: rest -> loop rest
  in
  loop stmts

let dead_code_pass : analysis_pass =
  { name = "dead_code"; category = CodeQuality;
    run = fun prog ->
      List.concat_map (fun func ->
        let findings = ref [] in
        (* Unreachable code *)
        let after = stmts_after_return func.body in
        if after <> [] then
          findings := { Finding_types.id = fresh_id ();
            category = CodeQuality; severity = Medium;
            pass_name = "dead_code"; location = func.name;
            message = Printf.sprintf "Unreachable code after return (%d statements)"
              (List.length after);
            suggestion = Some "Remove unreachable statements"; } :: !findings;
        (* Unused variables *)
        let used = collect_used_vars_stmts func.body in
        List.iter (fun param ->
          if String.length param > 0 && param.[0] <> '_'
             && not (StringSet.mem param used) then
            findings := { Finding_types.id = fresh_id ();
              category = CodeQuality; severity = Info;
              pass_name = "dead_code"; location = func.name;
              message = Printf.sprintf "Unused parameter '%s'" param;
              suggestion = None; } :: !findings)
          func.params;
        List.rev !findings) prog; }
