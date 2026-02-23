(** Analysis reporter: structured text and JSON output.

    Generates human-readable and machine-readable reports
    from analysis findings. *)

(* ------------------------------------------------------------------ *)
(* Report type (provided -- not a TODO)                               *)
(* ------------------------------------------------------------------ *)

type report = {
  program_name : string;
  total_findings : int;
  findings : Finding_types.finding list;
  severity_counts : (Finding_types.severity * int) list;
  category_counts : (Finding_types.category * int) list;
  pass_counts : (string * int) list;
}

(* ------------------------------------------------------------------ *)
(* Building reports                                                   *)
(* ------------------------------------------------------------------ *)

(** Build a report from a program name and list of findings.
    Compute severity_counts, category_counts, and pass_counts. *)
let build_report (_name : string) (_findings : Finding_types.finding list)
    : report =
  failwith "TODO: build_report"

(* ------------------------------------------------------------------ *)
(* Text report                                                        *)
(* ------------------------------------------------------------------ *)

(** Format a report as human-readable text.
    Include header, total count, formatted findings, severity breakdown. *)
let format_text_report (_r : report) : string =
  failwith "TODO: format_text_report"

(* ------------------------------------------------------------------ *)
(* JSON report                                                        *)
(* ------------------------------------------------------------------ *)

(** Format a single finding as a JSON object string.
    Fields: id, category, severity, pass_name, location, message, suggestion. *)
let format_json_finding (_f : Finding_types.finding) : string =
  failwith "TODO: format_json_finding"

(** Format a full report as a JSON object string.
    Fields: program, total, findings (array), severity_counts, category_counts. *)
let format_json_report (_r : report) : string =
  failwith "TODO: format_json_report"

(* ------------------------------------------------------------------ *)
(* Summary and table                                                  *)
(* ------------------------------------------------------------------ *)

(** Format a brief one-line summary of the report.
    Empty: "Analysis of 'name': No findings."
    Non-empty: "Analysis of 'name': N findings (X Critical, Y High, ...)" *)
let format_summary (_r : report) : string =
  failwith "TODO: format_summary"

(** Format findings as an aligned text table with columns:
    Severity, Category, Pass, Location, Message. *)
let format_findings_table (_findings : Finding_types.finding list) : string =
  failwith "TODO: format_findings_table"

(* ------------------------------------------------------------------ *)
(* Utility functions                                                  *)
(* ------------------------------------------------------------------ *)

(** Return the top N findings sorted by severity (highest first). *)
let top_n_findings (_n : int) (_findings : Finding_types.finding list)
    : Finding_types.finding list =
  failwith "TODO: top_n_findings"

(** Return findings with severity >= the given threshold. *)
let findings_above_severity (_threshold : Finding_types.severity)
    (_findings : Finding_types.finding list) : Finding_types.finding list =
  failwith "TODO: findings_above_severity"
