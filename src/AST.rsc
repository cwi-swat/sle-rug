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
  = question(str label, str name, AType questionType)
  | computed(str label, str name, AType questionType, AExpr expression)
  | block(list[AQuestion] questions)
  | ifThenElse(AExpr ifCondition, AQuestion thenQuestion, AQuestion ElseQuestion)
  | ifThen(AExpr ifCondition, AQuestion thenQuestion)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(str name)
  | string(str string)
  | boolean(bool b)
  | integer(int i)
  | parentheses(AExpr ex)
  | negation(AExpr ex)
  | multiply(AExpr ex1, AExpr ex2)
  | divide(AExpr ex1, AExpr ex2)
  | addition(AExpr ex1, AExpr ex2)
  | subtraction(AExpr ex1, AExpr ex2)
  | greaterThan(AExpr ex1, AExpr ex2)
  | lessThan(AExpr ex1, AExpr ex2)
  | lessThanEq(AExpr ex1, AExpr ex2)
  | greaterThanEq(AExpr ex1, AExpr ex2)
  | equals(AExpr ex1, AExpr ex2)
  | notEquals(AExpr ex1, AExpr ex2)
  | and(AExpr ex1, AExpr ex2)
  | or(AExpr ex1, AExpr ex2)
  ;

data AType(loc src = |tmp:///|)
  = boolean()
  | integer()
  | string();
  
