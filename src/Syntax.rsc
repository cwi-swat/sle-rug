module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = @Foldable "form" Id "{" Question* "}"; 

syntax Question
  = Str Id ":" Type
  | Str Id ":" Type "=" Expr
  | @Foldable left "if" "(" Expr ")" "{" Question* "}"
  | @Foldable left "if" "(" Expr ")" "{" Question* "}" "else" "{" Question* "}"
  ; 


syntax Expr 
  = Id \ Reserved
  | left Str \ Reserved
  | left Int
  | left Bool
  | bracket "(" Expr ")"
  > left "!" Expr
  > left (Expr "*" Expr
  	| Expr "/" Expr)
  > left (Expr "+" Expr
  	| Expr "-" Expr)
  > left (Expr "\<" Expr
  	| Expr "\<=" Expr
  	| Expr "\>" Expr
  	| Expr "=\>" Expr)
  > left (Expr "!=" Expr
  	| Expr "==" Expr)
  > left Expr "&&" Expr
  > left Expr "||" Expr
  ;
  
keyword Reserved 
	= "true"
	| "false"
	| "if"
	| "else"
	;
  
syntax Type
  = "boolean"
  | "integer"
  | "string"
  ;  
  
lexical Str = [\"] ![\"]* [\"];

lexical Int = [\-]?[1-9][0-9]*
  | [0]
  ;

lexical Bool = "true"
	| "false";



