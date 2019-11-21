module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id "{" Question* "}"; 

// TODO: what is a block?
syntax Question
  = "if" "("Expr")" "{" Question* "}" "else" "{" Question* "}"
  | "if" "("Expr")" "{" Question* "}"
  | Str Id":" Type "=" Expr
  | Str Id":" Type
  ; 

// TODO: Do we need to implement "+ Expr" and "- Expr"  as well?
// Is ambiguity among similar functioning operators fine?
// Should more operators need the exclamation mark stuff?
// Do we need more reserved keywords for identifiers?
// Should the last four option be at the top instead?

syntax Expr 
  = "(" Expr ")"
  > right "!" Expr
  > left Expr "*" Expr
  | left div: Expr!div "/" Expr!div
  > left Expr "+" Expr
  | left min: Expr!min "-" Expr!min
  > left Expr "\<" Expr
  | left Expr "\<=" Expr
  | left Expr "\>" Expr
  | left Expr "\>=" Expr
  > left Expr "==" Expr
  | left Expr "!=" Expr
  > left Expr "&&" Expr
  > left Expr "||" Expr
  > Id \ "true" \ "false" // true/false are reserved keywords.
  | Str
  | Int
  | Bool
  ;
  
syntax Type
  = "boolean" | "integer" | "string";  

// Also parses " \" \" " as a singular string rather than two.
lexical Str
= "\""("\\\""|![\"])*"\"";

lexical Int 
  = [^0-9]+;

lexical Bool
  = "true" | "false";



