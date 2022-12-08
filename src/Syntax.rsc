module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id name "{" Question* questions "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question = StrLiteral Statement
                | "if" "(" Expr ")" "{" Question* "}" ElseStatement?
                ;

syntax ElseStatement  = "else" "{" Question* "}"
                  ;

syntax Statement = Id ":" Type ("=" Expr)?;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Term
  | "(" Expr ")" Expr?
  | Expr "!" Expr
  > Expr "*" Expr
  | Expr "/" Expr
  > Expr "+" Expr
  | Expr "-" Expr
  > Expr "\>" Expr
  | Expr "\<" Expr
  | Expr "\<=" Expr
  | Expr "\>=" Expr
  > Expr "==" Expr
  | Expr "!=" Expr
  > Expr "&&" Expr
  > Expr "||" Expr
  ;

syntax Type
  = Str
  | Int
  | Bool
  ;

syntax Term
  = Id \ "true" \ "false"
  | StrLiteral
  | "-"* IntLiteral
  | BoolLiteral
  ;

lexical Str = "str";
syntax StrLiteral =  [\"] ![\"]* [\"];

lexical Int = "integer";
syntax IntLiteral = [0-9]*;


lexical Bool = "boolean";
syntax BoolLiteral = "true" | "false";



