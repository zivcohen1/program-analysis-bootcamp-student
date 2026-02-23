(** Security configuration: sources, sinks, and sanitizers.

    Sources introduce tainted data (e.g. user input).
    Sinks consume data that must be untainted (e.g. SQL queries).
    Sanitizers clean tainted data (e.g. escaping functions).
*)

(** A taint source: a function that returns tainted data. *)
type source = {
  source_name : string;
  source_description : string;
}

(** A taint sink: a function whose arguments must not be tainted. *)
type sink = {
  sink_name : string;
  sink_param_index : int;
  sink_vuln_type : string;
  sink_description : string;
}

(** A sanitizer: a function that cleans taint of a specific kind. *)
type sanitizer = {
  sanitizer_name : string;
  sanitizer_cleans : string list;
  sanitizer_description : string;
}

(** A complete security configuration. *)
type security_config = {
  sources : source list;
  sinks : sink list;
  sanitizers : sanitizer list;
}

(** An empty configuration with no sources, sinks, or sanitizers. *)
let empty_config : security_config =
  failwith "TODO: return empty config"

(** A default web security configuration with common sources, sinks,
    and sanitizers for web applications.
    Sources: get_param, read_cookie, read_input, read_file, get_header
    Sinks: exec_query (sql-injection), send_response (xss),
           exec_cmd (command-injection), open_file (path-traversal),
           redirect (open-redirect)
    Sanitizers: escape_sql, html_encode, shell_escape,
                validate_path, validate_url *)
let default_web_config : security_config =
  failwith "TODO: define default web config"

(** [is_source config name] returns true if [name] is a source. *)
let is_source (_config : security_config) (_name : string) : bool =
  failwith "TODO: check if name is a source"

(** [find_sink config name] returns the sink if [name] is a sink. *)
let find_sink (_config : security_config) (_name : string) : sink option =
  failwith "TODO: find sink by name"

(** [find_sanitizer config name] returns the sanitizer if [name] is one. *)
let find_sanitizer (_config : security_config) (_name : string) : sanitizer option =
  failwith "TODO: find sanitizer by name"

(** [sink_checks_param sink idx] returns true if the sink checks parameter [idx]. *)
let sink_checks_param (_sink : sink) (_param_index : int) : bool =
  failwith "TODO: check if sink monitors this parameter"

(** [sanitizer_cleans san vuln_type] returns true if the sanitizer
    cleans the given vulnerability type. *)
let sanitizer_cleans (_sanitizer : sanitizer) (_vuln_type : string) : bool =
  failwith "TODO: check if sanitizer cleans this vulnerability type"

(** [add_source config source] adds a source to the configuration. *)
let add_source (_config : security_config) (_source : source) : security_config =
  failwith "TODO: add source to config"

(** [add_sink config sink] adds a sink to the configuration. *)
let add_sink (_config : security_config) (_sink : sink) : security_config =
  failwith "TODO: add sink to config"

(** [add_sanitizer config sanitizer] adds a sanitizer to the configuration. *)
let add_sanitizer (_config : security_config) (_sanitizer : sanitizer) : security_config =
  failwith "TODO: add sanitizer to config"
