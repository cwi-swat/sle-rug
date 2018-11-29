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
  return form("", [], src=f@\loc); 
}

AQuestion cst2ast(Question q) {
  switch (q) {
    case q1: (Question)`<Str s> <Id name> : <Type t>`: 
      return question("<s>", "<name>", cst2ast(t), src=q1@\loc);
    case q2: (Question)`<Str s> <Id name> : <Type t> = <Expr e>`:
      return questionComputed("<s>", "<name>", cst2ast(t) , cst2ast(e));
    case q3: (Question)`{ <Question* qs> }`:
      return questionBlock([ cst2ast(sample) | Question sample <- qs ]);
    case q4: (Question)`if (<Expr ex>) <Question q1> else <Question q2>`:
      return questionIfThenElse(cst2ast(ex), cst2ast(q1),cst2ast(q2));
    case q5: (Question)`if(<Expr ex>) <Question q>`:
      return questionIfThen(cst2ast(ex), cst2ast(q));
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref("<x>", src=x@\loc);
    
    // etc.
    
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  throw "Not yet implemented";
}
