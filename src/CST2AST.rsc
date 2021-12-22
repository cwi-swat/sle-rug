module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return cst2ast(f); 
}

AForm cst2ast(fl: (Form)`form <Id x> { <Question* qq> }`)
	= form("<x>", [ cst2ast(q) | Question q <- qq], src=fl@\loc);

AQuestion cst2ast(ql: Question q) {
  switch (q) {
  	case (Question)`<Str x> <Id y> : <Type z>`: return question("<x>", id("<y>", src=y@\loc), cst2ast(z), src=ql@\loc);
  	case (Question)`<Str x> <Id y> : <Type z> = <Expr w>`: return guarded("<x>", id("<y>", src=y@\loc), cst2ast(z), cst2ast(w), src=ql@\loc);
  	case (Question)`if(<Expr c>){<Question* qq>}`: return guarded(cst2ast(c), [ cst2ast(q) | Question q <- qq], src=ql@\loc);
  	case (Question)`if(<Expr c>){<Question* qq>}else{<Question* qqs>}`: return guarded(cst2ast(c), [ cst2ast(q) | Question q <- qq], [ cst2ast(qs) | Question qs <- qqs], src=ql@\loc);  
  	default: throw "Unhandled question: <q>";
  }
}

AExpr cst2ast(el: Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x@\loc),  src=el@\loc);
    case (Expr)`<Str x>`: return ref(string("<x>", src=x@\loc),src=el@\loc);
    case (Expr)`<Int x>`: return  ref(integer("<x>", src=x@\loc),src=el@\loc);
    case (Expr)`<Bool x>`: return  ref(boolean("<x>", src=x@\loc),src=el@\loc);
    case (Expr)`(<Expr x>)`: return cst2ast(x);
    case (Expr)`!<Expr x>`: return not(cst2ast(x), src=el@\loc);
    case (Expr)`<Expr lhs>*<Expr rhs>`: return multi(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>/<Expr rhs>`: return div(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>+<Expr rhs>`: return plus(cst2ast(lhs), cst2ast(rhs), src=el@\loc);	
    case (Expr)`<Expr lhs>-<Expr rhs>`: return min(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>\<<Expr rhs>`: return less(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>\<=<Expr rhs>`: return leq(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>\><Expr rhs>`: return great(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>=\><Expr rhs>`: return geq(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>!=<Expr rhs>`: return neq(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>==<Expr rhs>`: return eql(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>&&<Expr rhs>`: return and(cst2ast(lhs), cst2ast(rhs), src=el@\loc);
    case (Expr)`<Expr lhs>||<Expr rhs>`: return or(cst2ast(lhs), cst2ast(rhs), src=el@\loc);    
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(typ: Type t) {
  switch (t) {
  	case (Type)`<Type x>`: return var("<x>", src=typ@\loc);
    default: throw "Unhandled type: <t>";
  }
}