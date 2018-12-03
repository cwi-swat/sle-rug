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
  = question(str query, str name, AType questionType)
  | questionComputed(str query, str name, AType questionType, AExpr expression)
  | questionBlock(list[AQuestion] questions)
  | questionIfThenElse(AExpr ifCondition, AQuestion thenQuestion, AQuestion ElseQuestion)
  | questionIfThen(AExpr ifCondition, AQuestion thenQuestion)
  ; 

data AExpr(loc src = |tmp:///|)
  = ref(str name)
  | exprStr(str string)
  | exprBool(bool b)
  | exprInt(int i)
  | exprParentheses(AExpr ex)
  | exprNegation(AExpr ex)
  | exprMultiply(AExpr ex1, AExpr ex2)
  | exprDivide(AExpr ex1, AExpr ex2)
  | exprAdd(AExpr ex1, AExpr ex2)
  | exprSubtract(AExpr ex1, AExpr ex2)
  | exprGreaterThan(AExpr ex1, AExpr ex2)
  | exprLessThan(AExpr ex1, AExpr ex2)
  | exprLessThanEq(AExpr ex1, AExpr ex2)
  | exprGreaterThanEq(AExpr ex1, AExpr ex2)
  | exprEquals(AExpr ex1, AExpr ex2)
  | exprNotEquals(AExpr ex1, AExpr ex2)
  | exprAnd(AExpr ex1, AExpr ex2)
  | exprOr(AExpr ex1, AExpr ex2)
  ;

data AType(loc src = |tmp:///|)
  = typeBool()
  | typeInt();
  
