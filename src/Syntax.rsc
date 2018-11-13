module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = ; // TODO

// TODO: question, computed question, block, if-then-else, if-then
syntax Question = ; 

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = ref: Id name
  ; 
  
lexical Str = ; // TODO

lexical Int = ; // TODO

lexical Bool = ; // TODO



