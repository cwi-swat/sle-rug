module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(AId name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(str name, APrompt prompt)
  | question(AExpr expr,  list[AQuestion] questions, list[AElseStatement] elseStatement)
  ; 

data AElseStatement(loc src = |tmp:///|)
  = elseStat(list[AQuestion] questions)
  ;

data APrompt(loc src = |tmp:///|)
  = prompt(AId id, AType aType, list[AExpr] expressions)
  ;

data AExpr(loc src = |tmp:///|)
  = expr(ATerm aterm)
  | exprPar(AExpr expr)
  | not(AExpr rhs)
  //| umin(AExpr rhs)
  | binaryOp(ABinaryOp binOperator)
  ;

data ABinaryOp(loc src = |tmp:///|)
  = mul(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | add(AExpr lhs, AExpr rhs)
  | sub(AExpr lhs, AExpr rhs)
  | greth(AExpr lhs, AExpr rhs)
  | leth(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | eq(AExpr lhs, AExpr rhs)
  | neq(AExpr lhs, AExpr rhs)
  | and(AExpr lhs, AExpr rhs)
  | or(AExpr lhs, AExpr rhs)
  ;

data AType(loc src = |tmp:///|)
  = atype(str typeName)
  ;

data ATerm(loc src = |tmp:///|)
  = term(AId x)
  | term(int integer)
  | term(str string)
  | term(bool boolean)
  ;

data AId(loc src = |tmp:///|)
  = id(str name)
  ;

