module Eval

import AST;
import Resolve;


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
  

VEnv initialEnv(AForm f) {
  VEnv venv = ();
  for (/question(_, id(str var), AType varType) := f) {
    switch (varType) {
      case integerType(): venv[var] = vint(0);
      case booleanType(): venv[var] = vbool(false);
      case strType(): venv[var] = vstr("");
      default: throw "Unsupported type <varType>";
    }
  }

  for (/question(_, id(str var), AType varType, AExpr expr) := f) {
    switch (varType) {
      case integerType(): venv[var] = vint(0);
      case booleanType(): venv[var] = vbool(false);
      case strType(): venv[var] = vstr("");
      default: throw "Unsupported type <varType>";
    }
  }

  return venv;
}


VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  venv[inp.question] = inp.\value;
  for (AQuestion question <- f) {
    venv = eval(question, inp, venv);
  }
  return venv;
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {

  switch (q) {
    case question(_, id(str var), _, AExpr e): {
      venv[var] = eval(e, venv);
    }

    case ifQuestions(AExpr expr, list[AQuestion] ifQuestions):
    {
      if (eval(expr, venv) == vbool(true)) {
        for (AQuestion question <- ifQuestions) {
          venv = eval(question, inp, venv);
        }
      }
    }

    case ifElseQuestions(AExpr expr, list[AQuestion] ifQuestions, list[AQuestion] elseQuestions):
    {
      if (eval(expr,venv) == vbool(true)) {
        for (AQuestion question <- ifQuestions) {
          venv = eval(question, inp, venv);
        }
      } else {
        for (AQuestion question <- elseQuestions) {
          venv = eval(question, inp, venv);
        }
      }
    }

  }
  return venv;
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case ref(int n): return vint(n);
    case ref(boolean(str truthVal)): return vbool(truthVal == "true");
    case not(AExpr expr): return vbool(!eval(expr, venv).b);
    case mul(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n * eval(rhs, venv).n);
    case div(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n / eval(rhs, venv).n);
    case plus(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n + eval(rhs, venv).n);
    case min(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n - eval(rhs, venv).n);
    case lessThan(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n < eval(rhs, venv).n);
    case leq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n <= eval(rhs, venv).n);
    case greaterThan(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n > eval(rhs, venv).n);
    case geq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n >= eval(rhs, venv).n);
    case equality(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n == eval(rhs, venv).n);
    case inequality(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n != eval(rhs, venv).n);
    case logicAnd(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b && eval(rhs, venv).b);
    case logicOr(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b || eval(rhs, venv).b);

    default: throw "Unsupported expression <e>";
  }
}