module Eval

import AST;
import Resolve;
import IO;


data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

alias VEnv = map[str name, Value \value];

data Input
  = input(str question, Value \value);
  
VEnv initialEnv(AForm f) {
	VEnv venv = ();
	for (/computed(_,AId id, AType typ, _) := f) {
		venv += helper(id, typ);
	};
	for (/question(_,AId id, AType typ) := f) {
		venv += helper(id, typ);
	};
  return venv;
}

VEnv helper(AId id, AType typ) {
	switch(typ) {
		case string() : return (id.name : vstr(""));
		case integer() : return (id.name : vint(0));
		case boolean() : return (id.name : vbool(false));
	};
	return ();
}

VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
	for(AQuestion q <- f.questions) {
		switch(q) {
			case question(_,_,_): venv = eval(q, inp, venv);
			case computed(_,AId id,_,AExpr expr): venv[id.name] = eval(expr, venv);
			case block(list[AQuestion] questions): venv = evalOnce(form("", questions), inp, venv);
			case ifblock(AExpr condition, list[AQuestion] questions): eval(condition, venv).b ? venv = 
					evalOnce(form("", questions), inp, venv);
			case ifelseblock(AExpr condition, list[AQuestion] questions, list[AQuestion] questionsSec): venv = eval(condition, venv).b ? 
					evalOnce(form("", questions), inp, venv) : 
					evalOnce(form("", questionsSec), inp, venv);
		}
	}
  
  return venv; 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  if(q.id.name == inp.question) {
  		switch(q.typ) {
  	  		case string() : venv[q.id.name] = vstr(inp.\value.s);
  	  		case integer() : venv[q.id.name] = vint(inp.\value.n);
  	  		case boolean() : venv[q.id.name] = vbool(inp.\value.b);
  		};
  };
  return venv; 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case strConst(str s): return vstr(s);
    case intConst(int n): return vint(n);
    case boolConst(bool b): return vbool(b);    
	    
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