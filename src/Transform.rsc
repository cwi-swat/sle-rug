module Transform

import Syntax;
import Resolve;
import AST;
import IO;
import CST2AST;
import ParseTree;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  AForm aForm = form(f.name, flattenForm(f), src=f.src);
  println(aForm);
  return aForm;
}

/*
 * This function creates a list with questions which are no longer nested
 * also there are no else statements.
 */
list[AQuestion] flattenForm(AForm f) {
  list[AQuestion] questions = [];
  AExpr trueExpr = expr(termBool("true"));
  for(q <- f.questions) {
    questions += flattenQuestion(q, trueExpr);
  }
  return questions;
}

/*
 * Every question gets its own if statement so there are no 
 * nested ifs and no else statements
 * 
 * AExpr e is the guard which keeps recursively increasing
 */
list[AQuestion] flattenQuestion(AQuestion q, AExpr e) {
  list[AQuestion] questionsResult = [];
  switch(q) {
      /* regular question returned as question in if statement with e as guard */
      case question(str name, APrompt prompt): {
        return [question(e, [q], [])];
      }
      case question(AExpr expr, list[AQuestion] questions, list[AElseStatement] elseStat): {
        /* returns every question in the if statement as question in a single if statement */
        for(AQuestion question <- questions) {
          questionsResult += flattenQuestion(question, binaryOp(and(e, expr)));
        }
        /* returns every question in the else statement as question in a single if statement 
           this statement includes the negation of the original if statement*/
        for(AElseStatement els <- elseStat) {
          for(AQuestion question <- els.questions) {
            questionsResult += flattenQuestion(question, not(exprPar(binaryOp(and(e, expr)))));
          }
        }
      }
    }
  return questionsResult;
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
  /* Make set of locations */
  set[loc] toRename = {};
  
  /* Create refGraph for the sets of locations of all defintions and uses */
  AForm faf = cst2ast(f);
  RefGraph r = resolve(faf);

  
  /* Check if the given location(useOrDef) is in the definitions set */
  if(useOrDef in r.defs<1>){
      /* We have definition */
      println(useOrDef);                                    /* Add to set of locations */
      toRename += { useOrDef };
      toRename += { u | <loc u, useOrDef> <- r.useDef };    /* Adds all locations where the defintion is used > Used locations */
  }
  /* Or check for matching locations in set of all uses */
  else if(useOrDef in r.uses<0>){
    /*  We have to check first for defintion in order to find it */
    if(<useOrDef, loc d> <- r.useDef){
      toRename += {d};                                      /* Add defintion location */
      toRename += { u | <loc u, d> <- r.useDef };           /* Add more used locations */      
    }
  }
  else {
    return f;
  }

  /* renaming to the new name */
  return visit(f){
    case Id x => [Id]newName
      when x.src in toRename
  }  

}
 
 
 

