(** Security configuration: sources, sinks, and sanitizers.

    Sources introduce tainted data (e.g. user input).
    Sinks consume data that must be untainted (e.g. SQL queries).
    Sanitizers clean tainted data (e.g. escaping functions).

    All are modeled as function calls matching by name. *)

(** A taint source: a function that returns tainted data. *)
type source = {
  source_name : string;       (** Function name (e.g. "get_param") *)
  source_description : string; (** Human-readable description *)
}

(** A taint sink: a function whose arguments must not be tainted. *)
type sink = {
  sink_name : string;            (** Function name (e.g. "exec_query") *)
  sink_param_index : int;        (** Which parameter to check (0-based) *)
  sink_vuln_type : string;       (** Vulnerability class (e.g. "sql-injection") *)
  sink_description : string;     (** Human-readable description *)
}

(** A sanitizer: a function that cleans taint of a specific kind. *)
type sanitizer = {
  sanitizer_name : string;       (** Function name (e.g. "escape_sql") *)
  sanitizer_cleans : string list; (** Vulnerability types this sanitizer prevents *)
  sanitizer_description : string; (** Human-readable description *)
}

(** A complete security configuration. *)
type security_config = {
  sources : source list;
  sinks : sink list;
  sanitizers : sanitizer list;
}

(* ------------------------------------------------------------------ *)
(* Config constructors                                                *)
(* ------------------------------------------------------------------ *)

let empty_config : security_config =
  { sources = []; sinks = []; sanitizers = [] }

let default_web_config : security_config =
  { sources = [
      { source_name = "get_param"; source_description = "HTTP request parameter" };
      { source_name = "read_cookie"; source_description = "HTTP cookie value" };
      { source_name = "read_input"; source_description = "User input from stdin" };
      { source_name = "read_file"; source_description = "File contents" };
      { source_name = "get_header"; source_description = "HTTP header value" };
    ];
    sinks = [
      { sink_name = "exec_query"; sink_param_index = 0;
        sink_vuln_type = "sql-injection";
        sink_description = "SQL query execution" };
      { sink_name = "send_response"; sink_param_index = 0;
        sink_vuln_type = "xss";
        sink_description = "HTTP response body" };
      { sink_name = "exec_cmd"; sink_param_index = 0;
        sink_vuln_type = "command-injection";
        sink_description = "OS command execution" };
      { sink_name = "open_file"; sink_param_index = 0;
        sink_vuln_type = "path-traversal";
        sink_description = "File path used in open" };
      { sink_name = "redirect"; sink_param_index = 0;
        sink_vuln_type = "open-redirect";
        sink_description = "HTTP redirect URL" };
    ];
    sanitizers = [
      { sanitizer_name = "escape_sql";
        sanitizer_cleans = ["sql-injection"];
        sanitizer_description = "SQL parameterization / escaping" };
      { sanitizer_name = "html_encode";
        sanitizer_cleans = ["xss"];
        sanitizer_description = "HTML entity encoding" };
      { sanitizer_name = "shell_escape";
        sanitizer_cleans = ["command-injection"];
        sanitizer_description = "Shell argument escaping" };
      { sanitizer_name = "validate_path";
        sanitizer_cleans = ["path-traversal"];
        sanitizer_description = "Path traversal validation" };
      { sanitizer_name = "validate_url";
        sanitizer_cleans = ["open-redirect"];
        sanitizer_description = "URL validation" };
    ];
  }

(* ------------------------------------------------------------------ *)
(* Lookup helpers                                                     *)
(* ------------------------------------------------------------------ *)

let is_source (config : security_config) (name : string) : bool =
  List.exists (fun s -> s.source_name = name) config.sources

let find_sink (config : security_config) (name : string) : sink option =
  List.find_opt (fun s -> s.sink_name = name) config.sinks

let find_sanitizer (config : security_config) (name : string) : sanitizer option =
  List.find_opt (fun s -> s.sanitizer_name = name) config.sanitizers

let sink_checks_param (sink : sink) (param_index : int) : bool =
  sink.sink_param_index = param_index

let sanitizer_cleans (sanitizer : sanitizer) (vuln_type : string) : bool =
  List.mem vuln_type sanitizer.sanitizer_cleans

(* ------------------------------------------------------------------ *)
(* Mutation helpers                                                   *)
(* ------------------------------------------------------------------ *)

let add_source (config : security_config) (source : source) : security_config =
  { config with sources = source :: config.sources }

let add_sink (config : security_config) (sink : sink) : security_config =
  { config with sinks = sink :: config.sinks }

let add_sanitizer (config : security_config) (sanitizer : sanitizer) : security_config =
  { config with sanitizers = sanitizer :: config.sanitizers }
