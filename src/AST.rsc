module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = if_then_else(str name, list[AExpr] qs1, list[AExpr] qs2)
  | if_then(str name, list[AExpr] qs)
  | computed_question() //todo
  | question() //todo
  | block(list[AQuestion] qs)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | string(str literal)
  | integer(int number)
  | boolean(bool binary)
  | brackets(AExpr expr)
  | not(AExpr expr)
  | mul(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | sum(AExpr lhs, AExpr rhs)
  | min(AExpr lhs, AExpr rhs)
  | less(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | greater(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | equal(AExpr lhs, AExpr rhs)
  | neq(AExpr lhs, AExpr rhs)
  | and(AExpr lhs, AExpr rhs)
  | or(AExpr lhs, AExpr rhs)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|);
