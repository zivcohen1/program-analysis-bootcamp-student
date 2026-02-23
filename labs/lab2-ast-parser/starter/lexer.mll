(* MiniLang Lexer
   This lexer tokenizes the MiniLang language for use with the Menhir parser.
   All token rules are fully provided -- lexing is not the focus of this lab. *)

{
  open Parser
  exception Lexer_error of string
}

let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z' '_']
let alnum = ['a'-'z' 'A'-'Z' '0'-'9' '_']
let whitespace = [' ' '\t' '\r' '\n']

rule token = parse
  (* Whitespace and comments *)
  | whitespace+        { token lexbuf }
  | "//" [^ '\n']* '\n'? { token lexbuf }   (* single-line comments *)

  (* Keywords *)
  | "fun"              { FUN }
  | "if"               { IF }
  | "else"             { ELSE }
  | "while"            { WHILE }
  | "return"           { RETURN }
  | "print"            { PRINT }
  | "true"             { BOOL_LIT true }
  | "false"            { BOOL_LIT false }

  (* Operators -- multi-char before single-char to avoid ambiguity *)
  | "=="               { EQ_EQ }
  | "!="               { BANG_EQ }
  | "<="               { LE }
  | ">="               { GE }
  | "&&"               { AND_AND }
  | "||"               { OR_OR }
  | '+'                { PLUS }
  | '-'                { MINUS }
  | '*'                { STAR }
  | '/'                { SLASH }
  | '<'                { LT }
  | '>'                { GT }
  | '!'                { BANG }
  | '='                { EQ }

  (* Delimiters *)
  | '('                { LPAREN }
  | ')'                { RPAREN }
  | '{'                { LBRACE }
  | '}'                { RBRACE }
  | ','                { COMMA }
  | ';'                { SEMI }

  (* Literals and identifiers *)
  | digit+ as n        { INT_LIT (int_of_string n) }
  | alpha alnum* as id { IDENT id }

  (* End of file *)
  | eof                { EOF }

  (* Catch-all for unexpected characters *)
  | _ as c             { raise (Lexer_error (Printf.sprintf "Unexpected character: '%c'" c)) }
