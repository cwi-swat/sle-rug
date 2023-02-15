module Check

import AST;
import Resolve;
import Message; // see standard library

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  TEnv tenv = {};

  for (/question(AStr label, AId var, AType vartype) := f) {
    tenv += {<var.src, var.name, label.name, typeOf(vartype)>};
  }

  for (/question(AStr label, AId var, AType vartype, _) := f) {
    tenv += {<var.src, var.name, label.name, typeOf(vartype)>};
  }

  return tenv;
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  for (AQuestion q <- f.questions) {
    msgs += check (q, tenv, useDef);
  }
  return msgs;
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch (q) {
    case question(string(str label, src = loc labelSrc), id(str var, src = loc varSrc), AType varType):
      {
        msgs += {error("Variable redeclared with a different type", varSrc) | <_, var, _, Type otherType> <- tenv,
        otherType != typeOf(varType)};

        msgs += {warning("Duplicate label", labelSrc) | <loc otherSrc, _, label, _> <- tenv,
        otherSrc != varSrc};

        msgs += {warning("Same label for different variable", labelSrc) | <loc otherSrc, str otherVar, label, _> <- tenv,
        otherSrc != varSrc && otherVar != var};
      }

      case question(string(str label, src = loc labelSrc), id(str var, src = loc varSrc), AType varType, AExpr expr):
      {
        msgs += {error("Variable redeclared with a different type", varSrc) | <_, var, _, Type otherType> <- tenv,
        otherType != typeOf(varType)};

        msgs += {warning("Duplicate label", labelSrc) | <loc otherSrc, _, label, _> <- tenv,
        otherSrc != varSrc};

        msgs += {warning("Same label for different variable", labelSrc) | <loc otherSrc, str otherVar, label, _> <- tenv,
        otherSrc != varSrc && otherVar != var};

        msgs += {error("Incompatible types", varSrc) | typeOf(varType) != typeOf(expr, tenv, useDef)};

        msgs += check(expr, tenv, useDef);
      }

      case ifQuestions(AExpr expr, list[AQuestion] ifQuestions):
      {
        if (typeOf(expr,tenv,useDef) != tbool()) {
          msgs += {error("Guard must be of type boolean", expr.src)};
        }
        for (AQuestion q <- ifQuestions) {
          msgs += check(q, tenv, useDef);
        }
        msgs += check(expr, tenv, useDef);
      }

      case ifElseQuestions(AExpr expr, list[AQuestion] ifQuestions, list[AQuestion] elseQuestions):
      {
        if (typeOf(expr,tenv,useDef) != tbool()) {
          msgs += {error("Guard must be of type boolean", expr.src)};
        }
        for (AQuestion q <- ifQuestions) {
          msgs += check(q, tenv, useDef);
        }
        for (AQuestion q <- elseQuestions) {
          msgs += check(q, tenv, useDef);
        }
        msgs += check(expr, tenv, useDef);
      }
  }

  return msgs;
}

set[Message] check(AExpr expr, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch (expr) {

    case ref(AId id):
    {
      msgs += {error("Variable not declared", id.src) | useDef[id.src] == {}};
    }

    case not(AExpr e):
      {
        if (typeOf(e, tenv, useDef) != tbool()) {
          msgs += {error("Not operator expects a boolean expression", e.src)};
        }
        msgs += check(e, tenv, useDef);
      }

    case plus(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
          msgs += {error("Addition operator expects an integer expression", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }

    case mul(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
          msgs += {error("Multiplication operator expects an integer expression", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }

    case div(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
          msgs += {error("Division operator expects an integer expression", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }
    case min(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
          msgs += {error("Subtraction operator expects an integer expression", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }
    case lessThan(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
          msgs += {error("Less than operator expects an integer expression", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }

    case greaterThan(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
          msgs += {error("Greater than operator expects an integer expression", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }

    case leq(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
          msgs += {error("Less than or equal operator expects an integer expression", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }

    case geq(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
          msgs += {error("Greater than or equal operator expects an integer expression", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }

    case equality(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)) {
          msgs += {error("Equality operator expects expressions of the same type", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }

    case inequality(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)) {
          msgs += {error("Inequality operator expects expressions of the same type", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }

    case logicAnd(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tbool() || typeOf(rhs, tenv, useDef) != tbool()) {
          msgs += {error("And operator expects boolean expressions", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }

    case logicOr(AExpr lhs, AExpr rhs, src = loc l):
      {
        if (typeOf(lhs, tenv, useDef) != tbool() || typeOf(rhs, tenv, useDef) != tbool()) {
          msgs += {error("Or operator expects boolean expressions", l)};
        }
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
      }
  }

  return msgs;
}


Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    case ref(int _): return tint();
    case ref(ABool _): return tbool();
    case not(_): return tbool();
    case mul(_, _): return tint();
    case div(_, _): return tint();
    case plus(_,_): return tint();
    case min(_,_): return tint();
    case lessThan(_, _): return tbool();
    case greaterThan(_, _): return tbool();
    case leq(_, _): return tbool();
    case geq(_, _): return tbool();
    case equality(_, _): return tbool();
    case inequality(_, _): return tbool();
    case logicAnd(_, _): return tbool();
    case logicOr(_, _): return tbool();
  }
  return tunknown();
}

Type typeOf(AType t) = typeOf(t, {}, {});

Type typeOf(AType t, _, _) {
  switch (t) {
    case booleanType(): return tbool();
    case integerType(): return tint();
    case strType(): return tstr();
  }
  return tunknown();
}

default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();