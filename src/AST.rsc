module AST

/*  
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

// Composition of an abstract Form, having both a name and a list of questions
data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

// An Abstract Question can be 5 types of questions, analogous to the CST
data AQuestion(loc src = |tmp:///|)
  = question(str label, str name, AType questionType)
  | computed(str label, str name, AType questionType, AExpr expression)
  | block(list[AQuestion] questions)
  | ifThenElse(AExpr ifCondition, AQuestion thenQuestion, AQuestion ElseQuestion)
  | ifThen(AExpr ifCondition, AQuestion thenQuestion)
  ;

// Composition of all the different Abstract Expressions
// Analogous to the CST-grammar
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

// Defining an abstract representation of the three types
data AType(loc src = |tmp:///|)
  = boolean()
  | integer()
  | string();
  
