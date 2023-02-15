module AST


data AForm(loc src = |tmp:///|)
  = form(AId name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(AStr question, AId answer, AType answerType)
  | question(AStr question, AId answer, AType answerType, AExpr expr)
  | ifQuestions(AExpr expr, list[AQuestion] ifQuestions)
  | ifElseQuestions(AExpr expr, list[AQuestion] ifQuestions, list[AQuestion] elseQuestions)
  ; 

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | ref(int x)
  | ref(ABool boo)
  | not(AExpr expr)
  | mul(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | plus(AExpr lhs, AExpr rhs)
  | min(AExpr lhs, AExpr rhs)
  | lessThan(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | greaterThan(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | equality(AExpr lhs, AExpr rhs)
  | inequality(AExpr lhs, AExpr rhs)
  | logicAnd(AExpr lhs, AExpr rhs)
  | logicOr(AExpr lhs, AExpr rhs)
  ;

data AId(loc src = |tmp:///|) = id(str name);

data AType(loc src = |tmp:///|)
  = booleanType()
  | integerType()
  | strType()
  ;

data AStr(loc src = |tmp:///|) = string(str name);

data ABool(loc src = |tmp:///|) = boolean(str boolValue);
