module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id "{" Question* "}"; 

// question, computed question, block, if-then-else, if-then
syntax Question
  = Str Id ":" Type
  | "if" "(" ExprBool ")" "{" Question* "}"
  | "if" "(" ExprBool ")" "{" Question* "}" "else" "{" Question* "}"
  | Question "=" ExprInt
  ; 

// +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)

syntax ExprInt
  = Id \ "true" \ "false" // true/false are reserved keywords.
  > left ExprInt '+' ExprInt
  > left ExprInt '-' ExprInt
  > left ExprInt '*' ExprInt
  > left ExprInt '/' ExprInt
  | "(" ExprInt ")"
  | Int
  ;
  
syntax ExprBool
  = Id \ "true" \ "false" // true/false are reserved keywords.
  > left ExprInt '\>' ExprInt
  > left ExprInt '\<' ExprInt
  > left ExprInt '\>=' ExprInt
  > left ExprInt '\<=' ExprInt
  > left ExprInt '==' ExprInt
  > left ExprInt '!=' ExprInt
  > left ExprBool '&&' ExprBool
  > left ExprBool '||' ExprBool
  > '!' ExprBool
  | "(" ExprBool ")"
  | Bool
  ;
  
syntax Type
  = "boolean"
  | "integer"
  ;  
  
lexical Str 
  = [\"] ![\"]* [\"]
  ;

lexical Int 
  = [0-9]+;

lexical Bool = 
  | "true"
  | "false";