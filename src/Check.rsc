module Check
import IO;
import AST;
import Resolve;
import Message; // see standard library
import Set;

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
		case \type("boolean"): return tbool();
		case \type("integer"): return tint();
		
		default: {return tunknown();}
	}
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef){
  set[Message] msgs = {};
  for(/q:question(str _, AId _, AType _, list[AExpr] _) := f){
  	msgs += check(q, tenv, useDef);
  }
  return msgs; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.

set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
	set[Message] msgs = {};
	// obtain label
	str label;
	Type tp;
	list[AExpr] aexpr = [];
	for(/question(str l, _, AType t, list[AExpr] axprs) := q){
		label = l;
		tp = AType2Type(t);
		aexpr = axprs;
	}
	// same label twice
	list[str] labels = [label | /<_, _, label, _> := tenv];
	
	if(labels != [label]){
		msgs += warning("<q.src>" + "Duplicate label");
	}
	
	// same label, different types
	set[Type] types = {t | <_, _, label, Type t> := tenv};
	if(types != {AType2Type(q.\type)}){
		msgs += error("<q.src>" + "Same label, different type");
	}
	
	// type of expression != type of question
	if(aexpr != []){
		Type etp = typeOf(aexpr[0], tenv, useDef);
		if(etp != tunknown() && etp != tp){
			msgs += error("<q.src>" + "Type of expression does not match type of question");
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
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };

    // etc.
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    
    // etc.
    case brackets(AExpr ex):
      return typeOf(ex, tenv, useDef);
    case not(AExpr ex):
      return tbool();
    case divide(AExpr expr1, AExpr expr2): {
    	return tunknown();
    }
    case multiply(AExpr expr1, AExpr expr2): {
    	return tint();
    }
    case add(AExpr expr1, AExpr expr2): {
    	return tint();
    }
    // case add(AExpr ex1, AExpr ex2): {
    //   if((typeOf(ex1, tenv, useDef) == tint()) 
    //    && (typeOf(ex2, tenv, useDef) == tint())){
    //  	return tint();
    //  } else {
    //  	return tunknown();
    //  }
    //}
    case subtract(AExpr expr1, AExpr expr2): {
    	return tint();
    }
    case less(AExpr expr1, AExpr expr2): {
    	return tbool();
    }
    case gtr(AExpr expr1, AExpr expr2): {
    	return tbool();
    }
    case leq(AExpr expr1, AExpr expr2): {
    	return tbool();
    }
    case geq(AExpr expr1, AExpr expr2): {
    	return tbool();
    }
    case eq(AExpr expr1, AExpr expr2): {
    	return tbool();
    }
    case neq(AExpr expr1, AExpr expr2): {
    	return tbool();
    }
    case and(AExpr expr1, AExpr expr2): {
    	return tbool();
    }
    case or(AExpr expr1, AExpr expr2): {
    	return tbool();
    }
    case ref(str x, src = loc u):  

      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    case integer(int n):
      return tint();
    case boolean(str \bool):
      return tbool();

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
 
 

