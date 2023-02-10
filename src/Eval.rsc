module Eval

import AST;
import Resolve;
import IO;
import String;
import Boolean;

/*
 * Implement big-step semantics for QL
 */
 
/* NB: Eval may assume the form is type- and name-correct. */


/* Semantic domain for expressions (values) */
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  | vunknown()
  ;

/* The value environment */
alias VEnv = map[str name, Value \value];

/* Modeling user input */
data Input
  = input(str question, Value \value);

/* default value for every type */
Value defaultValue(AType aType) {
  switch(aType.typeName) {
    case "integer": return vint(0);
    case "boolean": return vbool(false);
    case "str":     return vstr("");

    default: return vunknown();
  }
}

/* produce an environment which for each question has a default value
/  (e.g. 0 for int, "" for str etc.) */
VEnv initialEnv(AForm f) {
  return (prompt.id.name : defaultValue(prompt.aType) | /question(str name, APrompt prompt) := f);
}

/* creates an input which can be used for evaluation */
Input createInput(str question, Value \value){
  return input(question, \value);
}


/* Because of out-of-order use and declaration of questions
  we use the solve primitive in Rascal to find the fixpoint of venv. */
VEnv eval(AForm f, Input inp, VEnv venv) {
  venv[inp.question] = inp.\value;
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  /* Eval the questions */
  for (AQuestion q <- f.questions ){
    venv = eval( q, inp, venv);
  }
  return venv;
}
/* 
 * evaluate conditions for branching,
 * evaluate inp and computed questions to return updated VEnv 
 */
VEnv eval(AQuestion q, Input inp, VEnv venv) {
  switch(q) {
    /* regular question */
    case question(str name, APrompt prompt): {
      venv = eval(prompt, inp, venv);
    }
    /* if statement */
    case question(AExpr expr,  list[AQuestion] questions, list[AElseStatement] elseStat): {
      for(AQuestion q <- questions) {
        venv = eval(q, inp, venv);
      }
      for(AElseStatement els <- elseStat) {
        for(AQuestion q <- els.questions) {
          venv = eval(q, inp, venv);
        }
      }
    }
  }

  return venv; 
}

/*
 * Gives value to id in prompt
 */
VEnv eval(APrompt prompt, Input inp, VEnv venv) {
  switch(prompt) {
    case prompt(AId id, AType aType, list[AExpr] expressions): {
      /* Changes value of id if there is an expression */
      for(AExpr e <- expressions) {
        venv[prompt.id.name] = eval(e, venv);
      }
    }
  }
  return venv;
}

/* 
 * Evaluate expression
 */
Value eval(AExpr e, VEnv venv){
  switch(e){
    case expr(ATerm aterm):
      return eval(aterm, venv);

    case exprPar(AExpr expr):
      return eval(expr, venv);

    case not(AExpr rhs):
      return vbool(!eval(rhs, venv).b);
    
    case umin(AExpr rhs):
      return vint(-eval(rhs, venv).n);

    case binaryOp(ABinaryOp binOperator):
          return eval(binOperator, venv)  ;
  
  }

  return vunknown();

}

/* 
 * Evaluate binary operator
 */
Value eval(ABinaryOp bOp, VEnv venv){
  switch (bOp) {
    /* calculate int values */
    case mul(AExpr lhs, AExpr rhs):{
      return vint(eval(lhs, venv).n * eval(rhs, venv).n);
    }
    case div(AExpr lhs,  AExpr rhs):{
      return vint( (eval(lhs, venv).n) / (eval(rhs, venv).n) );
    }
    case add(AExpr lhs,  AExpr rhs):{
      return vint(eval(lhs, venv).n + eval(rhs, venv).n);
    }
    case sub(AExpr lhs,  AExpr rhs):{
      return vint(eval(lhs, venv).n - eval(rhs, venv).n);
    }
    /* compare operators */
    case greth(AExpr lhs,  AExpr rhs):{
      return vbool(eval(lhs, venv).n > eval(rhs, venv).n);
    } 
    case leth(AExpr lhs,  AExpr rhs):{
      return vbool(eval(lhs, venv).n < eval(rhs, venv).n);
    }
    case geq(AExpr lhs,  AExpr rhs):{
      return vbool(eval(lhs, venv).n >= eval(rhs, venv).n);
    }
    case leq(AExpr lhs,  AExpr rhs): {
      return vbool(eval(lhs, venv).n <= eval(rhs, venv).n);
    }
    case eqls(AExpr lhs,  AExpr rhs): {
      Value lhsVal = eval(lhs, venv);
      Value rhsVal = eval(rhs, venv);
      switch(lhsVal) {
        case vint(_):
          return vbool(lhsVal.n == rhsVal.n);
        case vbool(_): 
          return vbool(lhsVal.b == rhsVal.b);
        case vstr(_):
          return vbool(lhsVal.s == rhsVal.s);
      }
      return vunknown();
    }
    case neq(AExpr lhs,  AExpr rhs): {
      Value lhsVal = eval(lhs, venv);
      Value rhsVal = eval(rhs, venv);
      switch(lhsVal) {
        case vint(_):
          return vbool(lhsVal.n != rhsVal.n);
        case vbool(_): 
          return vbool(lhsVal.b != rhsVal.b);
        case vstr(_):
          return vbool(lhsVal.s != rhsVal.s);
      }
      return vunknown();
    }
    case and(AExpr lhs,  AExpr rhs): {
      Value lhsVal = eval(lhs, venv);
      Value rhsVal = eval(rhs, venv);
      switch(lhsVal) {
        case vbool(_): 
          return vbool(lhsVal.b && rhsVal.b);
      }
      return vunknown();
    }
    case or(AExpr lhs,  AExpr rhs): {
      Value lhsVal = eval(lhs, venv);
      Value rhsVal = eval(rhs, venv);
      switch(lhsVal) {
        case vbool(_): 
          return vbool(lhsVal.b || rhsVal.b);
      }
      return vunknown();
    }

  }
  return vunknown(); 
}

/*
 * Evaluate term
 */
Value eval(ATerm t, VEnv venv){
  switch (t) {
    /* return value that is in virtual environment */
    case term(id(str name)): {
      return venv[name];
    } 
    /* return literal values in their respective type */
    case termInt(str integer): {
      return vint(toInt(integer));
    }
    case termBool(str boolean): { 
      return vbool(fromString(boolean));
    }
    case termStr(str string): {
      return vstr(string);
    }
  }

  return vunknown();
}



