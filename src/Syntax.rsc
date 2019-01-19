module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

// A form consists of the form keyword, an identifier and a list of questions
start syntax Form 
  = "form" Id "{" Question* "}"; 

// Question, computed question, block of questions, if-then-else, if-then
syntax Question
  = Str Id ":" Type
  | Str Id ":" Type "=" Expr
  | "{" Question* "}"
  | "if" "(" Expr ")" Question "else" Question
  | "if" "(" Expr ")" Question
  ;

// Expression components: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// JAVA-Style precedence rules are applied
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | Str
  | Bool
  | Int
  > "(" Expr ")"
  > "!" Expr
  > left ( left Expr "*" Expr
          | left Expr "/" Expr)
  > left ( left Expr "+" Expr
         | left Expr "-" Expr)
  > non-assoc ( left Expr "\>" Expr
         | left Expr "\<" Expr
         | left Expr "\<=" Expr
         | left Expr "\>=" Expr
         | left Expr "==" Expr
         | left Expr "!=" Expr)
  > left Expr "&&" Expr
  > left Expr "||" Expr
  ;
  
// The types that we define for our QL can be either Boolean, Integer or String
syntax Type
  = "boolean" | "integer" | "string";
  
  // A String consists of two double quotes with characters in between
lexical Str = "\"" ![\"]* "\"";

// An Integer in our QL starts with a positive digit, optionally followed by digits 0-9
// Also negative integers are supported, indicated by an optional minus.
// We also allow for an integer with 0 as value
lexical Int 
  = "-"?[1-9][0-9]*
  | "0";

// A Bool can be either true or false
lexical Bool = "true" | "false";
