module Transform

import Syntax;
import Resolve;
import AST;
import CST2AST;
import ParseTree;
import IO;

/* 
 * Transforming QL forms
 */
 
 
AForm flatten(AForm f) {
  list[AQuestion] questions = [];

  questions += flatten(f.questions, ref(boolean("true")));

  return form(f.name, questions);
}

list[AQuestion] flatten(list[AQuestion] questions, AExpr e) {
  list[AQuestion] result = [];

  for (AQuestion question <- questions) {
        println(e);
    switch (question) {
      case question(_,_,_):
        result += ifQuestions(e, [question]);
      case question(_,_,_,_):
        result += ifQuestions(e, [question]);
      case ifQuestions(AExpr expr, list[AQuestion] questions):
      {
        println(questions);
        result += flatten(questions, logicAnd(e, expr));
      }
      case ifElseQuestions(expr, questions1, questions2):
      {
        result += flatten(questions1, logicAnd(e, expr));
        result += flatten(questions2, logicAnd(e, not(expr)));
      }
    }
  }

  return result;
}

 
start[Form] rename(start[Form] f, loc name, str newName, UseDef useDef) {

  RefGraph refgraph = resolve(cst2ast(f));

  set[loc] toRename = {};

  if (name in refgraph.defs<1>) {
    toRename += {name};
    toRename += { u | <loc u, name> <- refgraph.useDef};
  }
  else if (name in refgraph.uses<0>) {
    if (<name, loc d> <- refgraph.useDef) {
      toRename += {d};
      toRename += {u | <loc u, d> <- refgraph.useDef};
    }
  } else {
    return f;
  }

  return visit (f) {
    case Id variable => [Id]newName when variable@\loc in toRename
  };
} 
 
 
 

