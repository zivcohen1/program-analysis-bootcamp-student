type severity = Warning | Error

type issue = {
  rule : string;
  message : string;
  severity : severity;
  location : string;  (* function name or "global" *)
}

let string_of_severity = function
  | Warning -> "WARNING"
  | Error -> "ERROR"

let format_issue issue =
  Printf.sprintf "[%s] %s: %s (in %s)"
    (string_of_severity issue.severity)
    issue.rule
    issue.message
    issue.location

let print_report issues =
  if issues = [] then
    Printf.printf "No issues found.\n"
  else begin
    Printf.printf "Found %d issue(s):\n" (List.length issues);
    List.iter (fun i -> Printf.printf "  %s\n" (format_issue i)) issues
  end
