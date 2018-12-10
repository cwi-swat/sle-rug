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
      return computed("<s>", "<name>", cst2ast(t) , cst2ast(e), src=q2@\loc);
    case q3: (Question)`{ <Question* qs> }`:
      return block([ cst2ast(sample) | Question sample <- qs ], src=q3@\loc);
    case q4: (Question)`if (<Expr ex>) <Question q1> else <Question q2>`:
      return ifThenElse(cst2ast(ex), cst2ast(q1),cst2ast(q2), src=q4@\loc);
    case q5: (Question)`if(<Expr ex>) <Question q1>`:
      return ifThen(cst2ast(ex), cst2ast(q1), src=q5@\loc);
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case e1: (Expr)`<Id x>`: 
    	return ref("<x>", src=x@\loc);
    case e2: (Expr)`<Str s>`: 
    	return string("<s>", src=e2@\loc);
    case e3: (Expr)`<Bool b>`:
    	return boolean(fromString("<b>"), src=e3@\loc);
    case e4: (Expr)`<Int i>`:
    	return integer(toInt("<i>"), src=e4@\loc);
    case e5: (Expr)`(<Expr ex>)`:
    	return parentheses(cst2ast(ex), src=e5@\loc);
    case e6: (Expr)`!<Expr ex>`:
    	return negation(cst2ast(ex), src=e6@\loc);
    case e7: (Expr)`<Expr ex1> * <Expr ex2>`:
    	return multiply(cst2ast(ex1), cst2ast(ex2), src=e7@\loc);
    case e8: (Expr)`<Expr ex1> / <Expr ex2>`:
    	return divide(cst2ast(ex1), cst2ast(ex2), src=e8@\loc);
    case e9: (Expr)`<Expr ex1> + <Expr ex2>`:
    	return addition(cst2ast(ex1), cst2ast(ex2), src=e9@\loc); 
    case e10: (Expr)`<Expr ex1> - <Expr ex2>`:
    	return subtraction(cst2ast(ex1), cst2ast(ex2), src=e10@\loc);
    case e11: (Expr)`<Expr ex1> \> <Expr ex2>`:
    	return greaterThan(cst2ast(ex1), cst2ast(ex2), src=e11@\loc);
    case e12: (Expr)`<Expr ex1> \< <Expr ex2>`:
    	return lessThan(cst2ast(ex1), cst2ast(ex2), src=e12@\loc);
    case e13: (Expr)`<Expr ex1> \<= <Expr ex2>`:
    	return lessThanEq(cst2ast(ex1), cst2ast(ex2), src=e13@\loc);
    case e14: (Expr)`<Expr ex1> \>= <Expr ex2>`:
    	return greaterThanEq(cst2ast(ex1), cst2ast(ex2), src=e14@\loc);
    case e15: (Expr)`<Expr ex1> == <Expr ex2>`:
    	return equals(cst2ast(ex1), cst2ast(ex2), src=e15@\loc);
    case e16: (Expr)`<Expr ex1> != <Expr ex2>`:
    	return notEquals(cst2ast(ex1), cst2ast(ex2), src=e16@\loc);
    case e17: (Expr)`<Expr ex1> && <Expr ex2>`:
    	return and(cst2ast(ex1), cst2ast(ex2), src=e17@\loc);
    case e18: (Expr)`<Expr ex1> || <Expr ex2>`:
    	return or(cst2ast(ex1), cst2ast(ex2), src=e18@\loc);
   default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch (t) {
  	case t1: (Type)`boolean`:
  		return boolean(src=t1@\loc);
  	case t2: (Type)`integer`:
  		return integer(src=t2@\loc);
    case t3: (Type)`string`:
        return string(src=t3@\loc);
  default: throw "Unhandled Type: <t>";
  }
}
