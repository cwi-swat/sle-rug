module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id "{" Question* "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question = StrLiteral Prompt
                | "if" "(" Expr ")" "{" Question* "}" ElseStatement?
                ;

syntax ElseStatement  = "else" "{" Question* "}"
                  ;

syntax Prompt = Id ":" Type ("=" Expr)?;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Term
  | "(" Expr ")"
  > right ( neg: "!" Expr
          /*| umin: "-" Expr e */ )
  > binaryOp: BinaryOp
  ;

syntax BinaryOp
  = left  ( mul: Expr l "*" Expr r
          | div: Expr l "/" Expr r )
  > left  ( add: Expr l "+" Expr r
          | min: Expr l "-" Expr r )
  > left  ( greth: Expr l "\>" Expr r
          | leth:  Expr l "\<" Expr r
          | leq: Expr l "\<=" Expr r
          | geq: Expr l "\>=" Expr r)
  > left  ( eq:  Expr l "==" Expr r
          | neq: Expr l "!=" Expr r )
  > left    and: Expr l "&&" Expr r
  > left    or:  Expr l "||" Expr r
  ;

syntax Type
  = Str
  | Int
  | Bool
  ;

syntax Term
  = Id \ "true" \ "false"
  | StrLiteral
  | IntLiteral
  | BoolLiteral
  ;

lexical Str = "str";
syntax StrLiteral =  [\"] ![\"]* [\"];

lexical Int = "integer";
syntax IntLiteral = [0-9]*;


lexical Bool = "boolean";
syntax BoolLiteral = "true" | "false";



