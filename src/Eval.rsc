module Eval

import AST;
import Resolve;
import IO;

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
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
	VEnv venv = ();
	for (/guarded(_,AId id, AType typ, _) := f) {
		switch(typ) {
			case var("string") :	venv += (id.name : vstr(""));
			case var("integer") : venv += (id.name : vint(0));
			case var("boolean") : venv += (id.name : vbool(false));
			};
	};
	for (/question(_,AId id, AType typ) := f) {
		switch(typ) {
			case var("string") :	venv += (id.name : vstr(""));
			case var("integer") : venv += (id.name : vint(0));
			case var("boolean") : venv += (id.name : vbool(false));
			};
	};
  return venv;
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) { //Right like this?
	for(/q:question(_,_,_) := f) {
		venv = eval(q, inp, venv);
	};
	
	for(/guarded(_,AId id,_,AExpr expr) <- f.questions) {
		venv[id.name] = eval(expr, venv);
	};
  return venv; 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  if(q.id.name == inp.question) {
  		switch(q.typ.name) {
  	  		case "string" : venv[q.id.name] = vstr(inp.\value.s);
  	  		case "integer" : venv[q.id.name] = vint(inp.\value.n);
  	  		case "boolean" : venv[q.id.name] = vbool(inp.\value.b);
  		};
  };
  return venv; 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case ref(AStr x): return vstr(x.string);
    case ref(AInt x): return vint(x.integer);
    case ref(ABool x): return vbool(x.boolean);    
	    
    case not(AExpr expr): return vbool(!eval(expr, venv).b);
    case multi(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n * eval(rhs, venv).n);
    case div(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n / eval(rhs, venv).n);
    case plus(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n + eval(rhs, venv).n);
    case min(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n - eval(rhs, venv).n);
    
    case less(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n < eval(rhs, venv).n);
    case leq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n <= eval(rhs, venv).n);
    case great(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n > eval(rhs, venv).n);
    case geq(AExpr lhs, AExpr rhs):  return vbool(eval(lhs, venv).n >= eval(rhs, venv).n);
    case neq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n != eval(rhs, venv).n);
    case eql(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n == eval(rhs, venv).n);
    case and(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b && eval(rhs, venv).b);
    case or(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b || eval(rhs, venv).b);
    
    default: throw "Unsupported expression <e>";
  }
}