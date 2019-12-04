module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;
import IO;

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
  return form("<f.name>", [cst2ast(q) | q <- f.questions], src=f@\loc); 
}

AQuestion cst2ast(Question q) {
  switch(q) {
    case (Question)`<Str name> <Id i> : <Type t>`:
     return question("<name>", id("<i>", src=i@\loc), cst2ast(t), [], src=q@\loc);
    case (Question)`<Str name> <Id i> : <Type t> = <Expr e>`:
     return question("<name>", id("<i>", src=i@\loc), cst2ast(t), [cst2ast(e)], src=q@\loc);
    case (Question)`if ( <Expr expr> ) { <Question* x0> }`:
      return cond(cst2ast(expr), [cst2ast(q2) | q2 <- x0], [], src=q@\loc);
    case (Question)`if ( <Expr expr> ) { <Question* x0> } else { <Question* x1>}`:
      return cond(cst2ast(expr), [cst2ast(q2) | q2 <- x0], [cst2ast(q2) |Question q2 <- x1], src=q@\loc);
  }
  
  throw "Not yet implemented <q>";
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`(<Expr expr>)`: return brackets(cst2ast(expr), src=e@\loc);
    case (Expr)`! <Expr expr>` : return not(cst2ast(expr), src=e@\loc);
    case (Expr)`<Expr expr1> / <Expr expr2>`: return divide(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> * <Expr expr2>`: return multiply(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> + <Expr expr2>`: return add(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> - <Expr expr2>`: return subtract(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
	case (Expr)`<Expr expr1> \< <Expr expr2>`: return less(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> \> <Expr expr2>`: return gtr(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> \<= <Expr expr2>`: return leq(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> \>= <Expr expr2>`: return geq(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> == <Expr expr2>`: return eq(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> != <Expr expr2>`: return neq(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> && <Expr expr2>`: return and(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Expr expr1> || <Expr expr2>`: return or(cst2ast(expr1), cst2ast(expr2), src=e@\loc);
    case (Expr)`<Id x>`: return ref(id("<x>", src=x@\loc), src=x@\loc);
    case (Expr)`<Int i>`: return integer(toInt("<i>"), src=e@\loc);
    case (Expr)`<Bool b>`: return boolean(b, src=e@\loc);
    
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch(t) {
  	case (Type)`boolean`: return \type("boolean", src = t@\loc);
  	case (Type)`integer`: return \type("integer", src = t@\loc);
  }
  throw "Not yet implemented";
}