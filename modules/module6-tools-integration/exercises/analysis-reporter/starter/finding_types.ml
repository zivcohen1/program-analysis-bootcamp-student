(** Unified finding types (provided -- not a TODO). *)

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

let severity_to_string (s : severity) : string =
  match s with
  | Critical -> "Critical" | High -> "High" | Medium -> "Medium"
  | Low -> "Low" | Info -> "Info"

let category_to_string (c : category) : string =
  match c with
  | Security -> "Security" | Safety -> "Safety"
  | CodeQuality -> "CodeQuality" | Performance -> "Performance"

let severity_to_int (s : severity) : int =
  match s with
  | Critical -> 4 | High -> 3 | Medium -> 2 | Low -> 1 | Info -> 0

let all_severities = [Critical; High; Medium; Low; Info]
let all_categories = [Security; Safety; CodeQuality; Performance]
