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

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
	TEnv tenv =  {};
	for(/question(str label, AId id, AType typ) := f) {
		switch(typ) {
			case string(): tenv += {<id.src, label, id.name, tstr()>};
			case boolean(): tenv += {<id.src, label, id.name, tbool()>};
			case integer(): tenv += {<id.src, label, id.name, tint()>};
			default: tenv += {<id.src, id.name, label, tunknown()>};			
		};
	};
		
	for(/computed(str label, AId id, AType typ,_) := f) {
		switch(typ) {
			case string(): tenv += {<id.src, label, id.name, tstr()>};
			case boolean(): tenv += {<id.src, label, id.name, tbool()>};
			case integer(): tenv += {<id.src, label, id.name, tint()>};
			default: tenv += {<id.src, id.name, label, tunknown()>};			
		};
	};
  return tenv; 
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
	set[Message] msgs = {};
	visit(f) {
		case q:question(_,_,_): msgs += check(q, tenv, useDef);
		case q:computed(_,_,_,_): msgs += check(q, tenv, useDef);
		case ifblock(AExpr condition, list[AQuestion] _): msgs += { error("Condition should be boolean", condition.src) 
			| tbool() != typeOf(condition, tenv, useDef)}
			+ check(condition, tenv, useDef);	
		case ifelseblock(AExpr condition, list[AQuestion] _, list[AQuestion] _): msgs += { error("Condition should be boolean", condition.src) 
			| tbool() != typeOf(condition, tenv, useDef)}
			+ check(condition, tenv, useDef);	
	}
	
  return msgs; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
	set[Message] msgs = {};
	str name = q.id.name;
	str label = q.label;
	loc loca = q.id.src;
	Type typQ = typeOf(q.typ);

	if(<d, label, _, _> <- tenv && d != loca)  {
    	msgs += { warning("Duplicate label", q.src) };
	}
	
	if(<d, _, name, t> <- tenv && typQ != t)  {
		msgs += { error("Question with double name, but different type", d) };
	}		
	
	switch(q) {
		case computed(_, _, _, AExpr expr):
			msgs += { error("Declared type does not match type of expression", expr.src) | typQ != typeOf(expr, tenv, useDef)}
				 + check(expr, tenv, useDef);
	};

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
    case not(AExpr _):
      msgs += { error("Can only do not for boolean", e.src) | typeOf(e, tenv, useDef) != tbool() };
    case multi(AExpr _, AExpr _):
      msgs += { error("Can only multiply integers", e.src) | typeOf(e, tenv, useDef) != tint() };
    case div(AExpr _, AExpr _):
      msgs += { error("Can only divide integers", e.src) | typeOf(e, tenv, useDef) != tint() };
    case plus(AExpr _, AExpr _):
      msgs += { error("Can only add integers", e.src) | typeOf(e, tenv, useDef) != tint() };
    case min(AExpr _, AExpr _):
      msgs += { error("Can only minus integers", e.src) | typeOf(e, tenv, useDef) != tint() };
    case less(AExpr _, AExpr _):
      msgs += { error("Can only compare integers", e.src) | typeOf(e, tenv, useDef) != tbool() };
    case leq(AExpr _, AExpr _):
      msgs += { error("Can only compare integers", e.src) | typeOf(e, tenv, useDef) != tbool() };
    case great(AExpr _, AExpr _):
      msgs += { error("Can only compare integers", e.src) | typeOf(e, tenv, useDef) != tbool() };
    case geq(AExpr _, AExpr _):
      msgs += { error("Can only compare integers", e.src) | typeOf(e, tenv, useDef) != tbool() };
    case neq(AExpr _, AExpr _):
      msgs += { error("Can only compare integers", e.src) | typeOf(e, tenv, useDef) != tbool()};
    case eql(AExpr _, AExpr _):
      msgs += { error("Can only compare integers", e.src) | typeOf(e, tenv, useDef) != tbool()};
    case and(AExpr _, AExpr _):
      msgs += { error("Can only && boolean", e.src) | typeOf(e, tenv, useDef) != tbool() };
    case or(AExpr _, AExpr _):
      msgs += { error("Can only || boolean", e.src) | typeOf(e, tenv, useDef) != tbool() };
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, _, _, Type t> <- tenv) {
        return t;
      }
    case strConst(_): return tstr();
    case intConst(_): return tint();
    case boolConst(_): return tbool();
    case not(AExpr expr): return typeOf(expr, tenv, useDef);
    case multi(AExpr lhs, AExpr rhs): return typeOf(lhs, rhs, tenv, useDef);
    case div(AExpr lhs, AExpr rhs): return typeOf(lhs, rhs, tenv, useDef);
    case plus(AExpr lhs, AExpr rhs): return typeOf(lhs, rhs, tenv, useDef);
    case min(AExpr lhs, AExpr rhs): return typeOf(lhs, rhs, tenv, useDef);
    
    case less(AExpr lhs, AExpr rhs): return typeOfCom(lhs, rhs, tenv, useDef);
    case leq(AExpr lhs, AExpr rhs): return typeOfCom(lhs, rhs, tenv, useDef);
    case great(AExpr lhs, AExpr rhs): return typeOfCom(lhs, rhs, tenv, useDef);
    case geq(AExpr lhs, AExpr rhs): return typeOfCom(lhs, rhs, tenv, useDef);
    case neq(AExpr lhs, AExpr rhs): return typeOfCom(lhs, rhs, tenv, useDef);
    case eql(AExpr lhs, AExpr rhs): return typeOfCom(lhs, rhs, tenv, useDef);
    
    case and(AExpr lhs, AExpr rhs): return typeOf(lhs, rhs, tenv, useDef);
    case or(AExpr lhs, AExpr rhs): return typeOf(lhs, rhs, tenv, useDef);
  }
  return tunknown(); 
}

Type typeOf(AExpr lhs, AExpr rhs, TEnv tenv, UseDef useDef) {
	Type temp = typeOf(lhs, tenv, useDef);
	if(temp == typeOf(rhs, tenv, useDef)) {
		return temp;
	};
	return tunknown();
}

Type typeOfCom(AExpr lhs, AExpr rhs, TEnv tenv, UseDef useDef) {
	Type temp = typeOf(lhs, tenv, useDef);
	if(temp == typeOf(rhs, tenv, useDef) && temp == tint()) {
		return tbool();
	};
	return tunknown();
}

Type typeOf(AType typ) {
	switch(typ) {
		case string(): return tstr();
		case boolean(): return tbool();
		case integer(): return tint();
		default: return tunknown();
	};
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