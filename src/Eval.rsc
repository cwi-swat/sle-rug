module Eval

import AST;
import Resolve;
import Check;
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
	for(/q:question(str _, AId id, AType at, list[AExpr] _) := f){
		t = AType2Type(at);
		if(t == tint()){
			venv += (id.name: vint(0));
		} else if (t == tbool()) {
			venv += (id.name: vbool(false));
		} else {
			assert false;
		}
	}
  return venv;
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  //
  
  
  // for(/aq:question(inp.question, AId id, AType _, list[AExpr] _) := f) {
  //	venv[aq.id] = input.\value;
  //}
  
  
  //
  
  
  for(question <- f.questions){
  	venv = eval(question, inp, venv);
  }
  return venv; 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  switch(q){
	 case question(str q, AId id, AType \type, list[AExpr] e): {
	 		if(e != []){
	 			venv[id.name] = eval(e, venv);
	 		}
	 		return venv;
	 	}
	 case cond(AExpr c, list[AQuestion] \if, list[AQuestion] \else):{
	 	b = eval(c, venv);
	 	if(b==vbool(true)){
	 		for(question <- \if){
	 			venv = eval(question, inp, venv);
	 		}
	 	} else {
	 		for(question <- \else){
	 			venv = eval(question, inp, venv);
	 		}
	 	}
	 	return venv;
	 }
  }
  return (); 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
  	case brackets(AExpr expr): return eval(expr, venv);
  	case not(AExpr expr): return eval(expr, venv)==vbool(true)?vbool(false):vbool(true);
  	case divide(AExpr expr1, AExpr expr2) :
  		return vint(eval(expr1, venv).n / eval(expr2, venv).n);
  	case multiply(AExpr expr1, AExpr expr2) :
  		return vint(eval(expr1, venv).n * eval(expr2, venv).n);
  	case add(AExpr expr1, AExpr expr2) :
  		return vint(eval(expr1, venv).n + eval(expr2, venv).n);
  	case subtract(AExpr expr1, AExpr expr2) :
  		return vint(eval(expr1, venv).n - eval(expr2, venv).n);
  	case less(AExpr expr1, AExpr expr2) :
  		return vbool(eval(expr1, venv).n < eval(expr2, venv).n);
  	case gtr(AExpr expr1, AExpr expr2) :
  		return vbool(eval(expr1, venv).n > eval(expr2, venv).n);
  	case leq(AExpr expr1, AExpr expr2) :
  		return vbool(eval(expr1, venv).n <= eval(expr2, venv).n);
  	case geq(AExpr expr1, AExpr expr2) :
  		return vbool(eval(expr1, venv).n >= eval(expr2, venv).n);
  	case eq(AExpr expr1, AExpr expr2) :
  		return vbool(eval(expr1, venv).n == eval(expr2, venv).n);
  	case neq(AExpr expr1, AExpr expr2) :
  		return vbool(eval(expr1, venv).n != eval(expr2, venv).n);
  	case and(AExpr expr1, AExpr expr2) : {
  		return vbool(eval(expr1, venv).b && eval(expr2, venv).b);
  		}
  	case or(AExpr expr1, AExpr expr2) :
  		return vbool(eval(expr1, venv).b || eval(expr2, venv).b);
    case ref(AId id): return venv[id.name];
    case integer(int n): return vint(n);
    case boolean(str \bool): {
    	if(\bool == "true"){
    		return vbool(true);
    	} else {
    		return vbool(false);
    	}
    }
    // etc.
    
    default: throw "Unsupported expression <e>";
  }
}