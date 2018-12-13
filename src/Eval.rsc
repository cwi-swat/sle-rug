module Eval

import AST;
import Resolve;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
Value sdValueOfType(boolean()) = vbool(false);
Value sdValueOfType(integer()) = vint(0);
Value sdValueOfType(string()) = vstr("");
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f)
  = ( q.name : sdValueOfType(q.questionType) | /AQuestion q := f && q has name);

// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}


// evalOnce(AForm f, Input inp, VEnv venv) 
//  = { v | AQuestion q := f && v = eval(q, inp, venv)} ; 
  
  
VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  for(AQuestion q <- f.questions) {
    venv = eval(q, inp, venv);
  }
  return venv;
}

 
VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  switch(q) {
    case question(str label, str name, AType questionType):
        if(inp.question == name) { venv[name] = inp.\value; }
    case computed(str label, str name, AType questionType, AExpr expression):
    	venv[name] = eval(expression, venv);
    case block(list[AQuestion] questions):
      for(AQuestion qq <- questions) { venv = eval(qq, inp, venv); }
    case ifThenElse(AExpr ifCondition, AQuestion thenQuestion, AQuestion elseQuestion):
    	return (eval(ifCondition, venv) == vbool(true)) ? (eval(thenQuestion, inp, venv)) : (eval(elseQuestion, inp, venv));
    case ifThen(AExpr ifCondition, AQuestion thenQuestion):
        if(eval(ifCondition, venv) == vbool(true)) { return eval(thenQuestion, inp, venv); }
  }
  return venv; 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(str x): return venv[x];
    case string(str s): return vstr(s);
    case boolean(bool b): return vbool(b);
    case integer(int i): return vint(i);
    case parentheses(AExpr ex): return eval(ex, venv);
    case negation(AExpr ex): return vbool(!eval(ex,venv).b);
    case multiply(AExpr ex1, AExpr ex2): return vint(eval(ex1, venv).n * eval(ex2,venv).n);
    case divide(AExpr ex1, AExpr ex2): return vint(eval(ex1, venv).n / eval(ex2,venv).n);
    case addition(AExpr ex1, AExpr ex2): return vint(eval(ex1, venv).n + eval(ex2,venv).n);
    case subtraction(AExpr ex1, AExpr ex2): return vint(eval(ex1, venv).n - eval(ex2,venv).n);
    case greaterThan(AExpr ex1, AExpr ex2): return vbool(eval(ex1, venv).n > eval(ex2,venv).n);
    case lessThan(AExpr ex1, AExpr ex2): return vbool(eval(ex1, venv).n < eval(ex2,venv).n);
    case lessThanEq(AExpr ex1, AExpr ex2): return vbool(eval(ex1, venv).n <= eval(ex2,venv).n);
    case greaterThanEq(AExpr ex1, AExpr ex2): return vbool(eval(ex1, venv).n >= eval(ex2,venv).n);
    case equals(AExpr ex1, AExpr ex2): return vbool(eval(ex1, venv).n == eval(ex2,venv).n);
    case notEquals(AExpr ex1, AExpr ex2): return vbool(eval(ex1, venv).n != eval(ex2,venv).n);
    case and(AExpr ex1, AExpr ex2): return vbool(eval(ex1, venv).b && eval(ex2,venv).b);
    case or(AExpr ex1, AExpr ex2): return vbool(eval(ex1, venv).b || eval(ex2,venv).b);
    default: throw "Unsupported expression <e>";
  }
}