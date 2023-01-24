module CST2AST

import Syntax;
import AST;

import ParseTree;

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
  switch (f) {
    case (Form)`form <Id name> { <Question* questions> }`: return form(id("<name>", src = name.src), [cst2ast(q) | Question q <- questions], src=f.src);
  
    default: throw "Unhandled form: <sf>";
  }
}


AQuestion cst2ast(Question q) {
  switch (q){
    case (Question)`<StrLiteral nameQ><Prompt promptQ>`: return question("<nameQ>", cst2ast(promptQ),src=q.src);
    case (Question)`if ( <Expr guard> ) { <Question* questions> } <ElseStatement? elseStat>`: return question(cst2ast(guard), [cst2ast(q) | Question q <- questions], [cst2ast(els) | ElseStatement els <- elseStat], src=q.src);
  

    default: throw "Unhandled question: <q>";
  }
}

AElseStatement cst2ast(ElseStatement e){
  switch(e){
    case(ElseStatement)`else { <Question* qs> }` : return elseStat([cst2ast(q) | Question q <- qs], src = e.src);

    default: throw "Unhandled else statement: <e>";
  }
}

APrompt cst2ast(Prompt p){
  switch(p){
    case (Prompt)`<Id x> : <Type t>`: 
      return prompt(id("<x>", src=x.src), cst2ast(t) ,[], src=p.src);
    case (Prompt)`<Id x> : <Type t> = <Expr es>`:
      return prompt(id("<x>", src=x.src), cst2ast(t) ,[cst2ast(es)], src=p.src);

    default: throw "Unhandled prompt: <p>";  
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Term x>`: return expr(cst2ast(x), src=e.src);
    case (Expr)`( <Expr x> )`: return exprPar(cst2ast(x), src=e.src);
    case (Expr)`!<Expr right>`: return not(cst2ast(right), src=e.src);
    case (Expr)`-<Expr right>`: return umin(cst2ast(right), src=e.src);
    case (Expr) `<BinaryOp bOp>`: return binaryOp(cst2ast(bOp), src=e.src);
    
    
    default: throw "Unhandled expression: <e>";
  }
}

ABinaryOp cst2ast(BinaryOp b) {
  switch(b) {
    case (BinaryOp)`<Expr left> * <Expr right>`: return mul(cst2ast(left), cst2ast(right), src=b.src);
    case (BinaryOp)`<Expr left> / <Expr right>`: return div(cst2ast(left), cst2ast(right), src=b.src);
    case (BinaryOp)`<Expr left> + <Expr right>`: return add(cst2ast(left), cst2ast(right), src=b.src); 
    case (BinaryOp)`<Expr left> - <Expr right>`: return sub(cst2ast(left), cst2ast(right), src=b.src);
    case (BinaryOp)`<Expr left> \> <Expr right>`: return greth(cst2ast(left), cst2ast(right), src=b.src);
    case (BinaryOp)`<Expr left> \< <Expr right>`: return leth(cst2ast(left), cst2ast(right), src=b.src);
    case (BinaryOp)`<Expr left> \>= <Expr right>`: return geq(cst2ast(left), cst2ast(right), src=b.src);
    case (BinaryOp)`<Expr left> \<= <Expr right>`: return leq(cst2ast(left), cst2ast(right), src=b.src);
    case (BinaryOp)`<Expr left> == <Expr right>`: return eqls(cst2ast(left), cst2ast(right), src=b.src); 
    case (BinaryOp)`<Expr left> != <Expr right>`: return neq(cst2ast(left), cst2ast(right), src=b.src); 
    case (BinaryOp)`<Expr left> && <Expr right>`: return and(cst2ast(left), cst2ast(right), src=b.src);
    case (BinaryOp)`<Expr left> || <Expr right>`: return or(cst2ast(left), cst2ast(right), src=b.src);

    default: throw "Unhandled binary operator: <b>";
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
    case(Term)`<Id x>`: return term(id("<x>", src=x.src), src = t.src); 
    case(Term)`<IntLiteral i>`: return termInt("<i>", src=t.src);    //integer
    case(Term)`<StrLiteral s>`: return termStr("<s>", src=t.src);    //string
    case(Term)`<BoolLiteral b>`: return termBool("<b>", src=t.src);   //bool

    default: throw "Unhandled type: <t>";
  }

}

AElseStatement cst2ast(ElseStatement e) {
  switch(e) {
    case(ElseStatement)`else { <Question* questions> }`: return elseStat([cst2ast(q) | Question q <- questions], src=e.src);

    default: throw "Unhandled else statement: <e>";
  }
}


