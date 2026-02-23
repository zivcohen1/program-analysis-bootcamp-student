(** Configurable analysis pipeline.

    Configuration-driven pipeline that selects analysis passes
    and filters results by severity, category, and count. *)

(* ------------------------------------------------------------------ *)
(* Configuration types (provided -- not a TODO)                       *)
(* ------------------------------------------------------------------ *)

type pass_id = DeadCode | Safety | Taint

type pipeline_config = {
  enabled_passes : pass_id list;
  min_severity : Finding_types.severity;
  max_findings : int option;
  target_categories : Finding_types.category list option;
}

(* ------------------------------------------------------------------ *)
(* Configuration builders                                             *)
(* ------------------------------------------------------------------ *)

(** Default configuration: all passes enabled, no filters. *)
let default_config : pipeline_config =
  ignore (DeadCode, Safety, Taint);
  failwith "TODO: default_config"

(** Create a config with only the specified passes enabled. *)
let config_with_passes (_passes : pass_id list) : pipeline_config =
  failwith "TODO: config_with_passes"

(** Set the minimum severity threshold on a config. *)
let config_with_severity (_sev : Finding_types.severity)
    (_config : pipeline_config) : pipeline_config =
  failwith "TODO: config_with_severity"

(** Set the maximum number of findings to return. *)
let config_with_max (_n : int)
    (_config : pipeline_config) : pipeline_config =
  failwith "TODO: config_with_max"

(** Set the target categories filter. *)
let config_with_categories (_cats : Finding_types.category list)
    (_config : pipeline_config) : pipeline_config =
  failwith "TODO: config_with_categories"

(* ------------------------------------------------------------------ *)
(* Pass creation                                                      *)
(* ------------------------------------------------------------------ *)

(** Create an analysis pass from a pass_id.
    DeadCode -> dead_code_pass, Safety -> safety_pass, Taint -> taint_pass *)
let create_pass (_pid : pass_id) : Pass_registry.analysis_pass =
  failwith "TODO: create_pass"

(** Build the list of passes from a config. *)
let build_pipeline (_config : pipeline_config) : Pass_registry.analysis_pass list =
  failwith "TODO: build_pipeline"

(* ------------------------------------------------------------------ *)
(* Filtering                                                          *)
(* ------------------------------------------------------------------ *)

(** Apply all config filters to a finding list:
    1. Filter by min_severity (keep >= threshold)
    2. Filter by target_categories (if Some)
    3. Sort by severity (highest first)
    4. Cap at max_findings (if Some) *)
let apply_filters (_config : pipeline_config)
    (_findings : Finding_types.finding list) : Finding_types.finding list =
  failwith "TODO: apply_filters"

(* ------------------------------------------------------------------ *)
(* Pipeline execution                                                 *)
(* ------------------------------------------------------------------ *)

(** Run the full pipeline: build passes, run all, apply filters. *)
let run_pipeline (_config : pipeline_config)
    (_prog : Shared_ast.Ast_types.program) : Finding_types.finding list =
  failwith "TODO: run_pipeline"
