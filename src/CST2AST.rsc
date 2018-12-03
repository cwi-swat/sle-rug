  module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;
import Boolean;

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
  return cst2ast(sf.top);
}

AForm cst2ast(f:(Form) `form <Id id> { <Question* qs> }`)
  = form("<id>", [cst2ast(q) | Question q <- qs]);

AQuestion cst2ast(Question q) {
  switch (q) {
    case q1: (Question)`<Str s> <Id name> : <Type t>`: 
      return question("<s>", "<name>", cst2ast(t), src=q1@\loc);
    case q2: (Question)`<Str s> <Id name> : <Type t> = <Expr e>`:
      return questionComputed("<s>", "<name>", cst2ast(t) , cst2ast(e), src=q2@\loc);
    case q3: (Question)`{ <Question* qs> }`:
      return questionBlock([ cst2ast(sample) | Question sample <- qs ], src=q3@\loc);
    case q4: (Question)`if (<Expr ex>) <Question q1> else <Question q2>`:
      return questionIfThenElse(cst2ast(ex), cst2ast(q1),cst2ast(q2), src=q4@\loc);
    case q5: (Question)`if(<Expr ex>) <Question q1>`:
      return questionIfThen(cst2ast(ex), cst2ast(q1), src=q5@\loc);
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case e1: (Expr)`<Id x>`: 
    	return ref("<x>", src=x@\loc);
    case e2: (Expr)`<Str s>`: 
    	return exprStr("<s>", src=e2@\loc);
    case e3: (Expr)`<Bool b>`:
    	return exprBool(fromString("<b>"), src=e3@\loc);
    case e4: (Expr)`<Int i>`:
    	return exprInt(toInt("<i>"), src=e4@\loc);
    case e5: (Expr)`(<Expr ex>)`:
    	return exprParentheses(cst2ast(ex), src=e5@\loc);
    case e6: (Expr)`!<Expr ex>`:
    	return exprNegation(cst2ast(ex), src=e6@\loc);
    case e7: (Expr)`<Expr ex1> * <Expr ex2>`:
    	return exprMultiply(cst2ast(ex1), cst2ast(ex2), src=e7@\loc);
    case e8: (Expr)`<Expr ex1> / <Expr ex2>`:
    	return exprDivide(cst2ast(ex1), cst2ast(ex2), src=e8@\loc);
    case e9: (Expr)`<Expr ex1> + <Expr ex2>`:
    	return exprAdd(cst2ast(ex1), cst2ast(ex2), src=e9@\loc); 
    case e10: (Expr)`<Expr ex1> - <Expr ex2>`:
    	return exprSubtract(cst2ast(ex1), cst2ast(ex2), src=e10@\loc);
    case e11: (Expr)`<Expr ex1> \> <Expr ex2>`:
    	return exprGreaterThan(cst2ast(ex1), cst2ast(ex2), src=e11@\loc);
    case e12: (Expr)`<Expr ex1> \< <Expr ex2>`:
    	return exprLessThan(cst2ast(ex1), cst2ast(ex2), src=e12@\loc);
    case e13: (Expr)`<Expr ex1> \<= <Expr ex2>`:
    	return exprLessThanEq(cst2ast(ex1), cst2ast(ex2), src=e13@\loc);
    case e14: (Expr)`<Expr ex1> \>= <Expr ex2>`:
    	return exprGreaterThanEq(cst2ast(ex1), cst2ast(ex2), src=e14@\loc);
    case e15: (Expr)`<Expr ex1> == <Expr ex2>`:
    	return exprEquals(cst2ast(ex1), cst2ast(ex2), src=e15@\loc);
    case e16: (Expr)`<Expr ex1> != <Expr ex2>`:
    	return exprNotEquals(cst2ast(ex1), cst2ast(ex2), src=e16@\loc);
    case e17: (Expr)`<Expr ex1> && <Expr ex2>`:
    	return exprAnd(cst2ast(ex1), cst2ast(ex2), src=e17@\loc);
    case e18: (Expr)`<Expr ex1> || <Expr ex2>`:
    	return exprOr(cst2ast(ex1), cst2ast(ex2), src=e18@\loc);
   default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch (t) {
  	case t1: (Type)`boolean`:
  		return typeBool(src=t1@\loc);
  	case t2: (Type)`integer`:
  		return typeInt(src=t2@\loc);
  default: throw "Unhandled Type: <t>";
  }
}
