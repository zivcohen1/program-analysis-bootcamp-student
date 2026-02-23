(** Security configuration for the analyzer (Part A: 10 points).

    Define the types and configuration for sources, sinks, sanitizers.
    Implement lookup helpers used by the taint analyzer.
*)

(** A taint source: a function that returns tainted data. *)
type source = {
  source_name : string;
}

(** A taint sink: a function whose arguments must not be tainted. *)
type sink = {
  sink_name : string;
  sink_param_index : int;
  sink_vuln_type : string;
}

(** A sanitizer: a function that cleans taint. *)
type sanitizer = {
  sanitizer_name : string;
  sanitizer_cleans : string list;
}

(** Complete security configuration. *)
type config = {
  sources : source list;
  sinks : sink list;
  sanitizers : sanitizer list;
}

(** Default web security configuration.
    Sources: get_param, read_cookie, read_input, read_file, get_header
    Sinks: exec_query (sql-injection), send_response (xss),
           exec_cmd (command-injection), open_file (path-traversal),
           redirect (open-redirect)
    Sanitizers: escape_sql, html_encode, shell_escape,
                validate_path, validate_url *)
let default_config : config =
  failwith "TODO: define default web security config"

(** Check if a function name is a source in the config. *)
let is_source (_config : config) (_name : string) : bool =
  failwith "TODO: check if name is a source"

(** Find a sink by function name. *)
let find_sink (_config : config) (_name : string) : sink option =
  failwith "TODO: find sink by name"

(** Find a sanitizer by function name. *)
let find_sanitizer (_config : config) (_name : string) : sanitizer option =
  failwith "TODO: find sanitizer by name"
