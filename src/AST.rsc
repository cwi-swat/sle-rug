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
  = question(str label, AId id, AType typ)
  | guarded(str label, AId id, AType typ, AExpr expr)
  | guarded(AExpr condition, list[AQuestion] questions)
  | guarded(AExpr condition, list[AQuestion] questions, list[AQuestion] questionsSec)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | ref(AStr string)
  | ref(AInt integer)
  | ref(ABool boolean)
  | not(AExpr expr)
  | multi(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | plus(AExpr lhs, AExpr rhs)
  | min(AExpr lhs, AExpr rhs)
  | less(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | great(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | neq(AExpr lhs, AExpr rhs)
  | eql(AExpr lhs, AExpr rhs)
  | and(AExpr lhs, AExpr rhs)
  | or(AExpr lhs, AExpr rhs)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = var(str name);	
  
data AStr(loc src = |tmp:///|)
  = string(str string);  
  
data AInt(loc src = |tmp:///|)
  = integer(int integer);

data ABool(loc src = |tmp:///|)
  = boolean(bool boolean);