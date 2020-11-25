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
  = question(str q, AId id, AType \type, list[AExpr] expr)
  | cond(AExpr c, list[AQuestion] \if, list[AQuestion] \else)
  ;

  data AExpr(loc src = |tmp:///|)
  = brackets(AExpr expr)
  | not(AExpr expr)
  | divide(AExpr expr1, AExpr expr2)
  | multiply(AExpr expr1, AExpr expr2)
  | add(AExpr expr1, AExpr expr2)
  | subtract(AExpr expr1, AExpr expr2)
  | less(AExpr expr1, AExpr expr2)
  | gtr(AExpr expr1, AExpr expr2)
  | leq(AExpr expr1, AExpr expr2)
  | geq(AExpr expr1, AExpr expr2)
  | eq(AExpr expr1, AExpr expr2)
  | neq(AExpr expr1, AExpr expr2)
  | and(AExpr expr1, AExpr expr2)
  | or(AExpr expr1, AExpr expr2)
  | ref(AId id)
  | integer(int n)
  | boolean(str \bool)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = \type(str \type);
 