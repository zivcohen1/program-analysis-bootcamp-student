(** Part A: Unified finding types (15 points).

    Define a unified finding type and implement operations
    for comparing, filtering, and formatting findings. *)

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
(* Conversion (TODO)                                                  *)
(* ------------------------------------------------------------------ *)

let severity_to_string (_s : severity) : string =
  failwith "TODO: severity_to_string"

let category_to_string (_c : category) : string =
  failwith "TODO: category_to_string"

let severity_to_int (_s : severity) : int =
  failwith "TODO: severity_to_int"

(* ------------------------------------------------------------------ *)
(* Comparison and filtering (TODO)                                    *)
(* ------------------------------------------------------------------ *)

(** Sort findings by severity, highest first. *)
let sort_by_severity (_findings : finding list) : finding list =
  failwith "TODO: sort_by_severity"

(** Keep only findings with severity >= threshold. *)
let filter_by_severity (_threshold : severity) (_findings : finding list)
    : finding list =
  failwith "TODO: filter_by_severity"

(** Keep only findings matching the given category. *)
let filter_by_category (_cat : category) (_findings : finding list)
    : finding list =
  failwith "TODO: filter_by_category"

(* ------------------------------------------------------------------ *)
(* Formatting (TODO)                                                  *)
(* ------------------------------------------------------------------ *)

(** Format: "[Severity] Category - message in location" *)
let format_finding (_f : finding) : string =
  failwith "TODO: format_finding"
