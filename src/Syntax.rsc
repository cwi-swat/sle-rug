module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = form:				"form" Id "{" Question* "}"; 

syntax Question
  = if_then_else:		"if" "("Expr")" Question "else" Question
  | if_then:			"if" "("Expr")" Question
  | computed_qestion:	Str Id":" Type "=" Expr
  | question:			Str Id":" Type
  | block:				"{" Question* "}"
  ; 

// Should more operators need the exclamation mark stuff?
// Should the last four option be at the top instead?

syntax Expr 
  = brackets:		"(" Expr ")"
  > right not:		"!" Expr
  > left (mul:		Expr "*" Expr
  		| div:		Expr!div "/" Expr!div)
  > left (sum:		Expr "+" Expr
  		| min:		Expr!min "-" Expr!min)
  > left (less:		Expr "\<" Expr 
  		| leq:		Expr "\<=" Expr
  		| greater:	Expr "\>" Expr
  		| geq:		Expr "\>=" Expr)
  > left (equal:	Expr "==" Expr
  		| neq:		Expr "!=" Expr)
  > left and:		Expr "&&" Expr
  > left or:		Expr "||" Expr
  > ref: 			Id \ Reserved
  | string:			Str
  | integer:		Int
  | boolean:		Bool
  ;
  
syntax Type
  = lit_type: "boolean" | "integer" | "string";  
  
keyword Reserved
  = "true" | "false" | "if" | "else" | "form" | "boolean" | "integer" | "string";

// Also parses " \" \" " as a singular string rather than two.
lexical Str
  = "\""("\\\""|![\"])*"\"";

lexical Int 
  = "-"?[0-9]+;

lexical Bool
  = "true" | "false";
