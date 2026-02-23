(** Security analysis types: vulnerabilities and reporting. *)

type severity = Critical | High | Medium | Low | Info

type vulnerability = {
  vuln_type : string;
  location : string;
  source_var : string;
  sink_name : string;
  severity : severity;
  message : string;
}

val severity_to_string : severity -> string
val severity_of_vuln_type : string -> severity
val format_vulnerability : vulnerability -> string
val format_summary : vulnerability list -> string
val group_by_type : vulnerability list -> (string * int) list
