module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id name "{" Question* questions "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question = ;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | Term Rest
  ;
  
syntax Rest
  = "!" Term Rest
  | "-" Term Rest
  > "*" Term Rest 
  | "/" Term Rest 
  > "+" Term Rest
  | "-" Term Rest
  > "\>" Term Rest
  | "\<" Term Rest
  | "\<=" Term Rest
  | "\>=" Term Rest
  > "==" Term Rest
  | "!=" Term Rest
  > "&&" Term Rest
  > "||" Term Rest
 ;

syntax Term
  = Str
  | Int
  | Bool
  ;

syntax Type 
  = ([a-zA-Z0-9] | " " | "_") ;

lexical Str = "string";
syntax StrLiteral = "\"[.]*\"";

lexical Int = "int";
syntax IntLiteral = [0-9]*;


lexical Bool = "boolean";
syntax BoolLiteral = "True" | "False";



