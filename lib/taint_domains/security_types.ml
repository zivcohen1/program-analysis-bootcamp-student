(** Security analysis types: vulnerabilities and reporting. *)

(** Severity levels for detected vulnerabilities. *)
type severity = Critical | High | Medium | Low | Info

(** A detected vulnerability. *)
type vulnerability = {
  vuln_type : string;          (** e.g. "sql-injection", "xss" *)
  location : string;           (** Function or program point *)
  source_var : string;         (** Variable carrying tainted data *)
  sink_name : string;          (** The sink function called *)
  severity : severity;         (** How severe this vulnerability is *)
  message : string;            (** Human-readable description *)
}

(* ------------------------------------------------------------------ *)
(* Severity helpers                                                   *)
(* ------------------------------------------------------------------ *)

let severity_to_string (s : severity) : string =
  match s with
  | Critical -> "CRITICAL"
  | High -> "HIGH"
  | Medium -> "MEDIUM"
  | Low -> "LOW"
  | Info -> "INFO"

let severity_of_vuln_type (vt : string) : severity =
  match vt with
  | "sql-injection" -> Critical
  | "command-injection" -> Critical
  | "xss" -> High
  | "path-traversal" -> High
  | "open-redirect" -> Medium
  | _ -> Low

(* ------------------------------------------------------------------ *)
(* Formatting                                                         *)
(* ------------------------------------------------------------------ *)

let format_vulnerability (v : vulnerability) : string =
  Printf.sprintf "[%s] %s in %s: %s (tainted var: %s, sink: %s)"
    (severity_to_string v.severity)
    v.vuln_type
    v.location
    v.message
    v.source_var
    v.sink_name

let format_summary (vulns : vulnerability list) : string =
  if vulns = [] then
    "No vulnerabilities found."
  else
    let count = List.length vulns in
    let header = Printf.sprintf "Found %d vulnerability(ies):\n" count in
    let lines = List.map
      (fun v -> "  " ^ format_vulnerability v)
      vulns
    in
    header ^ String.concat "\n" lines

let group_by_type (vulns : vulnerability list) : (string * int) list =
  let tbl = Hashtbl.create 8 in
  List.iter
    (fun v ->
      let cur = try Hashtbl.find tbl v.vuln_type with Not_found -> 0 in
      Hashtbl.replace tbl v.vuln_type (cur + 1))
    vulns;
  Hashtbl.fold (fun k v acc -> (k, v) :: acc) tbl []
  |> List.sort (fun (a, _) (b, _) -> String.compare a b)
