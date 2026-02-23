(* MiniLang Parser
   This Menhir grammar defines the syntax of MiniLang and produces
   Shared_ast.Ast_types values directly.

   TODO: Complete the stmt, expr, and atom grammar rules.
   The program and func_def rules are provided as examples. *)

%{
  open Shared_ast.Ast_types
%}

(* ---- Token declarations ---- *)

(* Literals *)
%token <int> INT_LIT
%token <bool> BOOL_LIT
%token <string> IDENT

(* Keywords *)
%token FUN IF ELSE WHILE RETURN PRINT

(* Operators *)
%token PLUS MINUS STAR SLASH
%token EQ_EQ BANG_EQ LT GT LE GE
%token AND_AND OR_OR
%token BANG
%token EQ

(* Delimiters *)
%token LPAREN RPAREN LBRACE RBRACE COMMA SEMI

(* End of file *)
%token EOF

(* ---- Precedence and associativity (lowest to highest) ---- *)
%left OR_OR
%left AND_AND
%left EQ_EQ BANG_EQ
%left LT GT LE GE
%left PLUS MINUS
%left STAR SLASH
%nonassoc UMINUS UNOT

(* ---- Start symbol ---- *)
%start <Shared_ast.Ast_types.program> program

%%

(* ================================================================
   PROVIDED RULES -- These are complete; do not modify.
   ================================================================ *)

program:
  | fs = list(func_def) EOF { fs }
  ;

func_def:
  | FUN name = IDENT LPAREN params = separated_list(COMMA, IDENT) RPAREN
    LBRACE body = list(stmt) RBRACE
    { { name; params; body } }
  ;

(* ================================================================
   TODO: Complete the grammar rules below.

   HINT 1 -- stmt should handle these cases:
     - Assignment:   IDENT = expr ;
     - If/else:      if (expr) { stmts } else { stmts }
                     if (expr) { stmts }
     - While:        while (expr) { stmts }
     - Return:       return expr ;   OR   return ;
     - Print:        print ( expr, expr, ... ) ;

   HINT 2 -- expr should handle binary operations with the
   precedence already declared above:
     ||  (lowest)
     &&
     == !=
     < > <= >=
     + -
     * /  (highest)
   Use the %prec annotation for unary minus/not.

   HINT 3 -- atom should handle:
     - Integer literals
     - Boolean literals
     - Variables (identifiers)
     - Parenthesized expressions: ( expr )
     - Unary operators: - expr, ! expr
     - Function calls: IDENT ( args )
   ================================================================ *)

stmt:
  (* TODO: Replace this placeholder with real grammar rules.
     Currently produces a parse error so the tests fail until you
     complete it. *)
  | SEMI { failwith "TODO: implement stmt rules" }
  ;

expr:
  (* TODO: Replace this placeholder with real grammar rules. *)
  | atom { failwith "TODO: implement expr rules" }
  ;

atom:
  (* TODO: Replace this placeholder with real grammar rules. *)
  | INT_LIT { failwith "TODO: implement atom rules" }
  ;
