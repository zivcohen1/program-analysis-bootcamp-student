(* ================================================================
   Exercise 5: Calculator Lexer (FULLY PROVIDED)
   ================================================================

   This lexer tokenizes a simple calculator language with:
   - integers, identifiers
   - arithmetic operators: +, -, *, /
   - parentheses

   This is complete -- do not modify. It mirrors the structure
   of the MiniLang lexer you will see in Lab 2.
   ================================================================ *)

{
  open Parser
  exception Lexer_error of string
}

let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z' '_']
let alnum = ['a'-'z' 'A'-'Z' '0'-'9' '_']
let whitespace = [' ' '\t' '\r' '\n']

rule token = parse
  (* Whitespace *)
  | whitespace+        { token lexbuf }

  (* Operators *)
  | '+'                { PLUS }
  | '-'                { MINUS }
  | '*'                { STAR }
  | '/'                { SLASH }

  (* Delimiters *)
  | '('                { LPAREN }
  | ')'                { RPAREN }

  (* Literals and identifiers *)
  | digit+ as n        { INT (int_of_string n) }
  | alpha alnum* as id { IDENT id }

  (* End of file *)
  | eof                { EOF }

  (* Error *)
  | _ as c             { raise (Lexer_error
                           (Printf.sprintf "Unexpected character: '%c'" c)) }
