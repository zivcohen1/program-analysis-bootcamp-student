(** Part C: Report generation (15 points).

    Generate structured text and summary reports from findings. *)

(* ------------------------------------------------------------------ *)
(* Report type (provided -- not a TODO)                               *)
(* ------------------------------------------------------------------ *)

type report = {
  program_name : string;
  total_findings : int;
  findings : Finding.finding list;
  severity_counts : (Finding.severity * int) list;
  category_counts : (Finding.category * int) list;
}

(* ------------------------------------------------------------------ *)
(* Report building (TODO)                                             *)
(* ------------------------------------------------------------------ *)

(** Build a report from program name and findings.
    Compute severity_counts and category_counts. *)
let build_report (_name : string) (_findings : Finding.finding list) : report =
  failwith "TODO: build_report"

(** Format a report as human-readable text.
    Header: "=== Analysis Report: name ==="
    Total count, then each finding formatted, then severity breakdown. *)
let format_text_report (_r : report) : string =
  failwith "TODO: format_text_report"

(** One-line summary.
    Empty: "Analysis of 'name': No findings."
    Non-empty: "Analysis of 'name': N findings (X Critical, ...)" *)
let format_summary (_r : report) : string =
  failwith "TODO: format_summary"
