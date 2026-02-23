(** Safety report formatter.

    Part B (continued): Formats safety checker output into a
    human-readable report, following Lab 3's Reporter pattern.
*)

module Make (D : Abstract_domains.Abstract_domain.ABSTRACT_DOMAIN) = struct

  module Checker = Safety_checker.Make (D)

  (** Format a single issue as a string. *)
  let format_issue (_issue : Checker.issue) : string =
    failwith "TODO: format as [KIND] location: message (variable)"

  (** Print a full report to stdout. *)
  let print_report (_issues : Checker.issue list) : unit =
    failwith "TODO: print header, then each formatted issue"

  (** Return a summary: counts by kind. *)
  let summary (_issues : Checker.issue list) : (string * int) list =
    failwith "TODO: group issues by kind, return (kind, count) pairs"
end
