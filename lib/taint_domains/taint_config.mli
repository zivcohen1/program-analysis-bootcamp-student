(** Security configuration: sources, sinks, and sanitizers. *)

type source = {
  source_name : string;
  source_description : string;
}

type sink = {
  sink_name : string;
  sink_param_index : int;
  sink_vuln_type : string;
  sink_description : string;
}

type sanitizer = {
  sanitizer_name : string;
  sanitizer_cleans : string list;
  sanitizer_description : string;
}

type security_config = {
  sources : source list;
  sinks : sink list;
  sanitizers : sanitizer list;
}

val empty_config : security_config
val default_web_config : security_config

val is_source : security_config -> string -> bool
val find_sink : security_config -> string -> sink option
val find_sanitizer : security_config -> string -> sanitizer option
val sink_checks_param : sink -> int -> bool
val sanitizer_cleans : sanitizer -> string -> bool

val add_source : security_config -> source -> security_config
val add_sink : security_config -> sink -> security_config
val add_sanitizer : security_config -> sanitizer -> security_config
