(** Sample findings for testing (provided -- not a TODO). *)

let sqli_finding : Finding_types.finding = {
  id = 1; category = Security; severity = Critical;
  pass_name = "taint"; location = "handler";
  message = "SQL injection via user input";
  suggestion = Some "Use parameterized queries";
}

let div_zero_finding : Finding_types.finding = {
  id = 2; category = Safety; severity = High;
  pass_name = "safety"; location = "compute";
  message = "Division by zero";
  suggestion = Some "Check divisor before dividing";
}

let unreachable_finding : Finding_types.finding = {
  id = 3; category = CodeQuality; severity = Medium;
  pass_name = "dead_code"; location = "main";
  message = "Unreachable code after return (2 statements)";
  suggestion = Some "Remove unreachable statements";
}

let unused_var_finding : Finding_types.finding = {
  id = 4; category = CodeQuality; severity = Low;
  pass_name = "dead_code"; location = "helper";
  message = "Unused variable 'temp'";
  suggestion = None;
}

let unused_param_finding : Finding_types.finding = {
  id = 5; category = CodeQuality; severity = Info;
  pass_name = "dead_code"; location = "process";
  message = "Unused parameter 'debug'";
  suggestion = None;
}

let xss_finding : Finding_types.finding = {
  id = 6; category = Security; severity = Critical;
  pass_name = "taint"; location = "render";
  message = "XSS via unescaped output";
  suggestion = Some "HTML-encode output";
}

let all_findings = [
  sqli_finding; div_zero_finding; unreachable_finding;
  unused_var_finding; unused_param_finding; xss_finding;
]

let empty_findings : Finding_types.finding list = []
