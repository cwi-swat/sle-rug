module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id name "{" Question* questions "}"; 

syntax Question
  = Str question Id answer ":" Type type
  | Str question Id answer ":" Type type "=" Expr expr
  | "if" "(" Expr condition ")" "{" Question* thenQuestions"}"
  | "if" "(" Expr condition ")" "{" Question* thenQuestions"}" "else" "{" Question* elseQuestions "}"
  ;


syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | Int
  | Bool
  | "(" Expr ")"
  > right "!" Expr
  > left Expr "*" Expr
  > left Expr "/" Expr
  > left Expr "+" Expr
  > left Expr "-" Expr
  > non-assoc Expr "\<" Expr
  | non-assoc Expr "\<=" Expr
  | non-assoc Expr "\>" Expr
  | non-assoc Expr "\>=" Expr
  > non-assoc Expr "==" Expr
  | non-assoc Expr "!=" Expr
  > left Expr "&&" Expr
  > left Expr "||" Expr
  ;
  
syntax Type
  = "boolean"
  | "integer"
  | "string"
  ;

lexical Str = "\"" ![\"]+ "\"";

lexical Int 
  = [0-9]+;

lexical Bool = "true" | "false";



