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
      //msgs += { error("Duplicate name with different type", prompt.id.src) | <_, _, name, Type t> <- tenv, t != Atype2Type(prompt.aType) };
      // println(tenv[_, _, name]);
      // println({Atype2Type(prompt.aType)});

      loc p = prompt.id.src;

      if(<_, _, name, Type t> <- tenv, <p, _, name, Type t2> <- tenv, t != t2) {
        println(prompt.aType);
        println(t);
        println(Atype2Type(prompt.aType));
        msgs += { error("Duplicate name with different type", prompt.id.src) };
      }

      if(<loc d, _, name, _> <- tenv, prompt.id.src != d) {
        msgs += {warning("Duplicate label", q.src)};
      }
    }


    case question(_,  list[AQuestion] questions, list[AElseStatement] elseStat): {
      for(AElseStatement els <- elseStat) {
        for(AQuestion q <- els.questions) {
          check(q, tenv, useDef);
        }
      }
      for(AQuestion q <- questions) {
        check(q, tenv, useDef);
      }
    }
  }
  //or

    // msgs += {error("Transisiton to undefined state", u)
    //     	| <loc u, _> <- g.defs, !(d <- g.useDef)} ;
          

  return msgs; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };

    // etc.
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    // etc.
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
 
 

