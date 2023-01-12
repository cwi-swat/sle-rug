module Check

import AST;
import Resolve;
import Message; // see standard library
import IO;

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

Type Atype2Type(AType aType) {
  switch(aType.typeName) {
    case "integer": return tint();
    case "boolean": return tbool();
    case "str":     return tstr();

    default: return tunknown();
  }
}

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  return{< prompt.id.src, prompt.id.name, name, Atype2Type(prompt.aType) > | /question(str name, APrompt prompt) := f};
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  
  ///msgs +=  {check(/question(str name, APrompt prompt) := f, tenv, useDef) } ; 

  for (AQuestion q <- f.questions ){
    msgs += check( q ,tenv, useDef);
  }

  println(msgs);
  
  return {}; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch(q) {
    case question(str name, APrompt prompt): {
      // Warning: duplicate labels
      msgs += {warning("Duplicate label", q.src) | <loc d, _, name, _> <- tenv, <loc d2, _, name, _> <- tenv, d != d2};
      // Error: there are declared questions with the same name but different types.
      msgs += {error("Duplicate label TTTTTT", q.src) | <loc d, _, name, _> <- tenv, <loc d2, _, name, _> <- tenv, d != d2, <_, _, name, Type t> <- tenv, <_, _, name, Type t2> <- tenv, t != t2};
      
      //Check prompt
      msgs += check(prompt, tenv, useDef);
    }


    case question(AExpr expr,  list[AQuestion] questions, list[AElseStatement] elseStat): {
      str name = expr.aterm.x.name;
      msgs += {error("Guard is not a boolean value", q.src) | <_, name, _, Type t> <- tenv, t != tbool() };
      for(AQuestion q <- questions) {
        check(q, tenv, useDef);
      }
      for(AElseStatement els <- elseStat) {
        for(AQuestion q <- els.questions) {
          check(q, tenv, useDef);
        }
      }
    }
  }
  //or

    // msgs += {error("Transisiton to undefined state", u)
    //     	| <loc u, _> <- g.defs, !(d <- g.useDef)} ;
          

  return msgs; 
}

set[Message] check(APrompt p, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch(p) {
    case prompt(AId id, AType aType, list[AExpr] expressions): {
      for(AExpr <- expressions) {
        //msgs += { error("Expression does not match type", p.src) |  t != tbool() };
        msgs += {};
      }
    }
  }

  return msgs;
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case binaryOp(ABinaryOp bOp): {
      if(typeOf(bOp.lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)) {
        msgs += { error("Types of binary operator are inequal", e.src) };
      }
      msgs += check(lhs, tenv, useDef);
      msgs += check(rhs, tenv, useDef);
    }

    // etc.
  }
  
  return msgs; 
}

// 1 +    ((x + y ) * 2) > check z* 2, z =,   ( ( (x + q)) + y ) + w 
// lhs = 1 , rhs =3
//typeof(1) > add 
// typeof(1) == typeof(3)
//typeof(1 + 3) > add typepof(lhs), 

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case expr(ATerm aterm):  
      return typeOf(aterm, tenv, useDef);
    case expr(AExpr expr1, AExpr _):
      return typeOf(expr1, tenv, useDef);
    case not(AExpr rhs):
      return typeOf(rhs, tenv, useDef);
    case binarOp(AExpr lhs, _):
      return typeOf(lhs, tenv, useDef);
    // etc.
  }
  return tunknown(); 
}

Type typeOf(ATerm aterm, TEnv tenv, UseDef useDef) {
  switch (aterm) {
    case term(id(str name, src = loc u)): {
      if (<u, loc d> <- useDef, <d, name, _, Type t> <- tenv) {
        return t;
      }
    } 
    case term(int _): {
      return tint();
    }
    case term(bool _): {
      return tbool();
    }
    case term(str _): {
      return tstr();
    }
  }
  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

