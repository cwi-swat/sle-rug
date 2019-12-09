module Check
import IO;
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
  return {< q.src, id.name, label, AType2Type(t)> | /q:question(str label, AId id, AType t, _) := f}; 
}

Type AType2Type(AType at){
	switch(at){
		case (AType)`type(integer)`: return tint();
		case (AType)`type(boolean)`: return tbool();
		default: {return tint();}
	}
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef){
  set[Message] msgs = {}; 
  //Undefined State
  //msgs += {error("Undefined State", u) |
  //		   <loc u, _> <- useDef.uses, 
  //		 	u notin useDef<use>};
  return msgs; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.

set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
	set[Message]msgs = {};
	
	msgs += { error("questions with the same name but different types", d)
	   			| <_, loc d> <- useDef.defs
	   			, d notin useDef<def>};  
	return msgs;
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(str x, src = loc u):
      msgs += { error("Undeclared question", u) | useDef[u] == {} };

    // etc.
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(str x, src = loc u):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    // etc.
    case brackets(AExpr ex):
      return typeOf(ex, tenv, useDef);
    case not(AExpr ex):
      return tbool();
    case add(AExpr ex1, AExpr ex2): {
      t1 = typeOf(ex1, tenv, useDef);
      t2 = typeOf(ex1, tenv, useDef);
    }

  }
  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(str x, src = loc u), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

