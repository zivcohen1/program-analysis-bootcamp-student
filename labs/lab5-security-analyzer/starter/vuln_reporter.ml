(** Vulnerability reporter: formatting and display (Part B: 15 points).

    Formats detected vulnerabilities for human consumption.
*)

(** Severity levels for vulnerabilities. *)
type severity = Critical | High | Medium | Low

(** Determine severity from vulnerability type.
    - sql-injection, command-injection → Critical
    - xss, path-traversal → High
    - open-redirect → Medium
    - other → Low *)
let severity_of_vuln_type (_vt : string) : severity =
  failwith "TODO: map vulnerability type to severity"

(** Format severity as a string (e.g. "CRITICAL"). *)
let string_of_severity (_s : severity) : string =
  failwith "TODO: format severity"

(** Format a single vulnerability as a human-readable string.
    Format: [SEVERITY] vuln_type in location: message (tainted var: var, sink: name) *)
let format_vulnerability (_v : Vuln_checker.vulnerability) : string =
  failwith "TODO: format vulnerability as string"

(** Format a summary of all vulnerabilities.
    If empty: "No vulnerabilities found."
    Otherwise: header with count + formatted list. *)
let format_summary (_vulns : Vuln_checker.vulnerability list) : string =
  failwith "TODO: format vulnerability summary"

(** Group vulnerabilities by type and count occurrences.
    Returns sorted list of (vuln_type, count). *)
let group_by_type (_vulns : Vuln_checker.vulnerability list) : (string * int) list =
  failwith "TODO: group and count vulnerabilities by type"
