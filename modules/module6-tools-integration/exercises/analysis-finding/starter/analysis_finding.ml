(** Unified analysis finding type and operations.

    Provides a standardized finding representation that works across
    all analysis passes (safety, security, code quality, etc.),
    plus operations for sorting, filtering, deduplication, and formatting. *)

(* ------------------------------------------------------------------ *)
(* Types (provided -- not a TODO)                                     *)
(* ------------------------------------------------------------------ *)

type severity = Critical | High | Medium | Low | Info

type category = Security | Safety | CodeQuality | Performance

type finding = {
  id : int;
  category : category;
  severity : severity;
  pass_name : string;
  location : string;
  message : string;
  suggestion : string option;
}

(* ------------------------------------------------------------------ *)
(* Conversion functions                                               *)
(* ------------------------------------------------------------------ *)

(** Convert severity to a human-readable string.
    Critical -> "Critical", High -> "High", etc. *)
let severity_to_string (_s : severity) : string =
  failwith "TODO: severity_to_string"

(** Convert category to a human-readable string.
    Security -> "Security", Safety -> "Safety", etc. *)
let category_to_string (_c : category) : string =
  failwith "TODO: category_to_string"

(** Map severity to an integer for ordering.
    Critical=4, High=3, Medium=2, Low=1, Info=0. *)
let severity_to_int (_s : severity) : int =
  failwith "TODO: severity_to_int"

(* ------------------------------------------------------------------ *)
(* Comparison functions                                               *)
(* ------------------------------------------------------------------ *)

(** Compare two findings by severity (higher severity first).
    Returns negative if [a] is more severe than [b]. *)
let compare_by_severity (_a : finding) (_b : finding) : int =
  failwith "TODO: compare_by_severity"

(** Compare two findings by location (alphabetical). *)
let compare_by_location (_a : finding) (_b : finding) : int =
  failwith "TODO: compare_by_location"

(* ------------------------------------------------------------------ *)
(* Filtering functions                                                *)
(* ------------------------------------------------------------------ *)

(** Keep only findings with severity >= the given threshold. *)
let filter_by_severity (_threshold : severity) (_findings : finding list)
    : finding list =
  failwith "TODO: filter_by_severity"

(** Keep only findings matching the given category. *)
let filter_by_category (_cat : category) (_findings : finding list)
    : finding list =
  failwith "TODO: filter_by_category"

(* ------------------------------------------------------------------ *)
(* Deduplication                                                      *)
(* ------------------------------------------------------------------ *)

(** Remove duplicate findings (same message AND same location).
    Preserve the first occurrence of each duplicate. *)
let deduplicate (_findings : finding list) : finding list =
  failwith "TODO: deduplicate"

(* ------------------------------------------------------------------ *)
(* Formatting                                                         *)
(* ------------------------------------------------------------------ *)

(** Format a single finding as a human-readable string.
    Format: "[Severity] Category - message in location"
    If suggestion is present, append "\n  Suggestion: ..." *)
let format_finding (_f : finding) : string =
  failwith "TODO: format_finding"

(** Format a list of findings, one per line.
    Returns "No findings." for an empty list. *)
let format_findings_list (_findings : finding list) : string =
  failwith "TODO: format_findings_list"

(* ------------------------------------------------------------------ *)
(* Counting                                                           *)
(* ------------------------------------------------------------------ *)

(** Count findings by severity.
    Returns a list of (severity, count) pairs, ordered
    Critical > High > Medium > Low > Info, excluding zero-count entries. *)
let count_by_severity (_findings : finding list)
    : (severity * int) list =
  failwith "TODO: count_by_severity"

(** Count findings by category.
    Returns a list of (category, count) pairs, ordered
    Security > Safety > CodeQuality > Performance, excluding zero-count entries. *)
let count_by_category (_findings : finding list)
    : (category * int) list =
  failwith "TODO: count_by_category"
