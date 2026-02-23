(* MiniLang Parser Driver
   Provides convenience functions that wire the lexer and parser together. *)

let parse_string s =
  let lexbuf = Lexing.from_string s in
  Parser.program Lexer.token lexbuf

let parse_file filename =
  let ic = open_in filename in
  let lexbuf = Lexing.from_channel ic in
  let result = Parser.program Lexer.token lexbuf in
  close_in ic;
  result
