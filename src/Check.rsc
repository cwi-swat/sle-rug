module Check

import AST;
import Resolve;
import Message; // see standard library

import IO;

/* All types including terror() which is used for error checking */
data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  | terror()
  ;

/* the type environment consisting of defined questions in the form */
alias TEnv = rel[loc def, str name, str label, Type \type];

/* Converts an AType to a Type which can be used in TEnv */
Type Atype2Type(AType aType) {
  switch(aType.typeName) {
    case "integer": return tint();
    case "boolean": return tbool();
    case "str":     return tstr();

    default: return tunknown();
  }
}

/*
 * To avoid recursively traversing the form, use the `visit` construct
 * or deep match (e.g., `for (/question(...) := f) {...}` ) 
 */
TEnv collect(AForm f) {
  return{< prompt.id.src, prompt.id.name, name, Atype2Type(prompt.aType) > | /question(str name, APrompt prompt) := f};
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  /* 
   * Loop through all questions
   * add error/warning message per question if applicable
   */
  for (AQuestion q <- f.questions ){
    msgs += check( q ,tenv, useDef);
  }

  return msgs; 
}

/*
 * - produce an error if there are declared questions with the same name but different types.
 * - duplicate labels should trigger a warning 
 * - the declared type computed questions should match the type of the expression.
 */
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch(q){
    /* Regular question */
    case question(str name, APrompt prompt): {
        /* Warning: duplicate labels */
        msgs += {warning("Duplicate label", q.src) | <loc d, _, name, _> <- tenv, <loc d2, _, name, _> <- tenv, d != d2};
        /* Error: there are declared questions with the same name but different types. */
        msgs += {error("Duplicate label TTTTTT", q.src) | <loc d, _, name, _> <- tenv, <loc d2, _, name, _> <- tenv, d != d2, <_, _, name, Type t> <- tenv, <_, _, name, Type t2> <- tenv, t != t2};
        
        /* Check prompt */
        msgs += check(prompt, tenv, useDef);
    }
    /* If statement */
    case question(AExpr expr,  list[AQuestion] questions, list[AElseStatement] elseStat): {
      msgs += {error("Guard is not valid", q.src) | !checkGuard(expr, tenv, useDef) };
      for(AQuestion q <- questions) {
        msgs += check(q, tenv, useDef);
      }
      /* Loop through all questions from the else statement if there is one */
      for(AElseStatement els <- elseStat) {
        for(AQuestion q <- els.questions) {
          msgs += check(q, tenv, useDef);
        }
      }

    }
  }
  return msgs; 
}

bool checkGuard(AExpr guard, TEnv tenv, UseDef useDef){
  switch(guard){
    case expr(ATerm aterm):  
      return typeOf(aterm, tenv, useDef) == tbool();
    default: return checkRest(guard, tenv, useDef);
  }
}

bool checkRest(AExpr guard, TEnv tenv, UseDef useDef){ 
  switch(guard){
    case expr(ATerm aterm):
      return true;
    case exprPar(AExpr expr1):
      return checkGuard(expr1, tenv, useDef);
    case not(AExpr rhs):
      return checkGuard(rhs, tenv, useDef);
    case binaryOp(ABinaryOp bOp): {
      if(checkGuard(bOp, tenv, useDef)){  //If operator is compare operator
      
        if(typeOf(bOp.lhs, tenv, useDef) == terror() || typeOf(bOp.rhs, tenv, useDef) == terror()    ) {
          return false;
        }
        if(typeOf(bOp.lhs, tenv, useDef) != typeOf(bOp.rhs, tenv, useDef)) {
          return false;
        }
        else {
          return (checkRest(bOp.lhs, tenv, useDef) && checkRest(bOp.rhs, tenv, useDef));
        }
      }
      else{           //Add, mul, div, sub operator
        return false;
      }
    }
  }
  return true;
}


bool checkGuard(ABinaryOp bOp, TEnv tenv, UseDef useDef) {
  switch(bOp) {
    case mul(_, _): {
      return false;
    }
    case div(_, _): {
      return false;
    }
    case add(_, _): {
      return false;
    }
    case sub(_, _): {
      return false;
    }
  }
  return true;
}

set[Message] check(APrompt p, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (p) {
    case prompt(AId id, AType aType, list[AExpr] expressions): {
        for(AExpr e <- expressions) {
          //msgs += { error("Expression does not match type", p.src) | AExpr, t != tbool() };
          msgs +=  check(e, tenv, useDef);
          msgs += { error("Question has another type than the expression", e.src) | Atype2Type(p.aType) != typeOf(e, tenv, useDef) };
        }

    }
  }
  
  return msgs; 
}


// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch (e) {
    case binaryOp(ABinaryOp bOp): {
      if(typeOf(bOp.lhs, tenv, useDef) == terror() || typeOf(bOp.rhs, tenv, useDef) == terror()) {
        msgs += { error("Incompatible type with operator", e.src) };
      }
      if(typeOf(bOp.lhs, tenv, useDef) != typeOf(bOp.rhs, tenv, useDef)) {
        msgs += { error("Types of binary operator are inequal", e.src) };
      }
      else {
        msgs += check(bOp.lhs, tenv, useDef);
        msgs += check(bOp.rhs, tenv, useDef);
      }
    }

  }
  
  return msgs; 
}

Type typeOf(ABinaryOp bOp, TEnv tenv, UseDef useDef) {
  switch (bOp) {
    case mul(AExpr lhs, _):{
      //Type is of int, otherwise error
      if(typeOf(lhs, tenv, useDef) != tint()) {
        return terror();
      }
      return typeOf(lhs, tenv, useDef);
    }
    case div(AExpr lhs, _):{
      //Type is of int, otherwise error
      if(typeOf(lhs, tenv, useDef) != tint()) {
        return terror();
      }
      return typeOf(lhs, tenv, useDef);
    }
    case add(AExpr lhs, _):{
      //Type is of int, otherwise error
      if(typeOf(lhs, tenv, useDef) != tint()) {
        return terror();
      }
      return typeOf(lhs, tenv, useDef);
    }
    case sub(AExpr lhs, _):{
      //Type is of int, otherwise error
      if(typeOf(lhs, tenv, useDef) != tint()) {
        return terror();
      }
      return typeOf(lhs, tenv, useDef);
    }
    case greth(AExpr lhs, _):{
      //Type is of int, otherwise error
      if(typeOf(lhs, tenv, useDef) != tint()) {
        return terror();
      }
      return tbool();
    } 
    case leth(AExpr lhs, _):{
      //Type is of int, otherwise error
      if(typeOf(lhs, tenv, useDef) != tint()) {
        return terror();
      }
      return tbool();
    }
    case geq(AExpr lhs, _):{
      //Type is of int, otherwise error
      if(typeOf(lhs, tenv, useDef) != tint()) {
        return terror();
      }
      return tbool();
    }
    case leq(AExpr lhs, _): {
      //Type is of int, otherwise error
      if(typeOf(lhs, tenv, useDef) != tbool()) {
        return terror();
      }
      return tbool(); 
    }
    case eqls(AExpr lhs, _): {
      //Bool, str and int
      if(typeOf(lhs, tenv, useDef) == terror()) {
        return terror();
      }
      return tbool();
    }
    case neq(AExpr lhs, _): {
      //Bool, str and int
      if(typeOf(lhs, tenv, useDef) == terror()) {
        return terror();
      }
      return tbool();
    }
    case and(AExpr lhs, _): {
      //Type is of bool, otherwise error
      if(typeOf(lhs, tenv, useDef) != tbool()) {
        return terror();
      }
      return tbool();
    }
    case or(AExpr lhs, _): {
      //Type is of bool, otherwise error
      if(typeOf(lhs, tenv, useDef) != tbool()) {
        return terror();
      }
      return tbool();
    }
  }

  return tunknown(); 
} 

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {pe typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case expr(ATerm aterm):  
      return typeOf(aterm, tenv, useDef);
    case exprPar(AExpr expr):
      return typeOf(expr, tenv, useDef);
    case not(AExpr rhs):
      return typeOf(rhs, tenv, useDef);
    case binaryOp(ABinaryOp bOp):
      return typeOf(bOp, tenv, useDef);
  }
  return tunknown(); 
}



Type typeOf(ATerm aterm, TEnv tenv, UseDef useDef) {
  switch (aterm) {
    case term(id(str name, src = loc u)): {
      if (<u, loc d> <- useDef, <d, name, _, Type t> <- tenv) {
        return t;
      }
    } 
    case termInt(str _): {
      return tint();
    }
    case termBool(str _): { 
      return tbool();
    }
    case termStr(str _): {
      return tstr();
    }
  }
  return tunknown(); 
}




/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

