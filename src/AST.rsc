module AST

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(str label, AId id, AType typ)
  | computed(str label, AId id, AType typ, AExpr expr)
  | block(list[AQuestion] questions)
  | ifblock(AExpr condition, list[AQuestion] questions)
  | ifelseblock(AExpr condition, list[AQuestion] questions, list[AQuestion] questionsSec)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | strConst(str s)
  | intConst(int n)
  | boolConst(bool b)
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
  = string()
  | integer()
  | boolean()
  ;