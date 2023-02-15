module CST2AST

import Syntax;
import AST;
import ParseTree;
import String;


AForm cst2ast(start[Form] sf) {
  return cst2ast(sf.top);
}

AForm cst2ast(f:(Form)`form <Id name> { <Question* questions> }`) {
  return form(cst2ast(name) , [cst2ast(q) | Question q <- questions], src=f.src);
}

AQuestion cst2ast(Question q) {
  switch(q) {
    case (Question)`<Str prompt> <Id answer> : <Type varType>` :
      return question(cst2ast(prompt), cst2ast(answer), cst2ast(varType), src=q.src);

    case (Question)`<Str prompt> <Id answer> : <Type varType> = <Expr expr>` :
      return question(cst2ast(prompt), cst2ast(answer), cst2ast(varType), cst2ast(expr), src=q.src);

    case (Question)`if ( <Expr expr> ) { <Question* questionList> }` :
      return ifQuestions(cst2ast(expr), [cst2ast(q) | Question q <- questionList]);

    case (Question)`if ( <Expr expr> ) { <Question* questionList> } else { <Question* elseQuestions> }` :
      return ifElseQuestions(cst2ast(expr), [cst2ast(q) | Question q <- questionList], [cst2ast(eq) | Question eq <- elseQuestions]);

    default:
      throw "Not yet implemented <q>";

  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(cst2ast(x), src=x.src);
    case (Expr)`<Int x>`: return ref(toInt("<x>"));
    case (Expr)`<Bool boo>`: return ref(cst2ast(boo), src=boo.src);
    case (Expr)`( <Expr expr> )`: return cst2ast(expr);
    case (Expr)`<Expr lhs> * <Expr rhs>`: return mul(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> + <Expr rhs>`: return plus(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> - <Expr rhs>`: return min(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> / <Expr rhs>`: return div(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> \< <Expr rhs>`: return lessThan(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> \<= <Expr rhs>`: return leq(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> \> <Expr rhs>`: return greaterThan(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> \>= <Expr rhs>`: return geq(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> == <Expr rhs>`: return equality(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> != <Expr rhs>`: return inequality(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> && <Expr rhs>`: return logicAnd(cst2ast(lhs), cst2ast(rhs),src=e.src);
    case (Expr)`<Expr lhs> || <Expr rhs>`: return logicOr(cst2ast(lhs), cst2ast(rhs),src=e.src);

    default: throw "Unhandled expression: <e>";
  }
}

default AType cst2ast(Type t) {
  switch(t) {
    case(Type)`integer`: return integerType();
    case(Type)`boolean`: return booleanType();
    case(Type)`string`: return strType();
  }

  throw "Not yet implemented <t>";
}

AId cst2ast(Id x) {
  return id("<x>", src=x.src);
}

AStr cst2ast(Str name) {
  return string(replaceAll("<name>", "\"", ""), src=name.src);
}

ABool cst2ast(Bool truthVal) {
  return boolean("<truthVal>", src=truthVal.src);
}