module CST2AST

import Syntax;
import AST;

import ParseTree;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

/*AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return form("", [ ], src=f.src); 
}

/*default AQuestion cst2ast(Question q) {
  throw "Not yet implemented <q>";
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x.src), src=x.src);
    // etc.
    
    default: throw "Unhandled expression: <e>";
  }
}

default AType cst2ast(Type t) {
  throw "Not yet implemented <t>";
}*/


AQuestion cst2ast(Question q) {
  switch (q){
    case (Question)`<StrLiteral nameQ><Prompt promptQ>`: return question("<nameQ>", cst2ast(promptQ),src=q.src);
  

    default: throw "Unhandeled question: <q>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x.src), src=x.src);
    // etc.
    
    default: throw "Unhandled expression: <e>";
  }
}

APrompt cst2ast(Prompt p){
  switch(p){
    case (Prompt)`<Id x> : <Type t> = <Expr es>`: 
      return prompt(id("<x>", src=x.src), cst2ast(t) ,[cst2ast(e)| Expr e <- es], src=p.src);

    default: throw "Unhandled prompt: <p>";  
  }
}

AType cst2ast(Type t) {
  switch(t){
    case(Type)`<Str strType>`: return atype("<strType>", src=t.src);
    case(Type)`<Int strType>`: return atype("<strType>", src=t.src);
    case(Type)`<Bool strType>`: return atype("<strType>", src=t.src);
    
    default: throw "Unhandled type: <t>";
  }
}


ATerm cst2ast(Term t){
  switch(t){
    case(Term)`<Id x>`: return term(id("<x>", src=x.src));
    case(Term)`<StrLiteral s>`: return term("<s>", src=t.src);    //string
    case(Term)`<IntLiteral i>`: return term("<i>", src=t.src);    //integer
    case(Term)`<BoolLiteral b>`: return term("<b>", src=t.src);   //bool

    default: throw "Unhandled type: <t>";
  }

}


