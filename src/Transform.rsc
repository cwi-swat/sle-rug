module Transform

import Resolve;
import AST;
import List;
import Syntax;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; if (a) { if (b) { q1: "" int; } q2: "" int; }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (a && b) q1: "" int;
 *     if (a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */

AForm flatten(AForm f) {
  list[AExpr] stack = [];
  for (AQuestion q <- f) {
    tuple[list[AExpr], tuple[AQuestion, list[AExpr]]] tup = flatten(q, stack);
  }
  return f;
}

tuple[list[AExpr], list[tuple[AQuestion, list[AExpr]]]] flatten(AQuestion q, stack) {
  switch(q) {
    case question(str thequestion, str questionName, AType questionType):
      return <stack, <q, stack>>;
    case computed(str thequestion, str questionName, AType questionType, AExpr expression):
      return <stack, <q, stack>>;
    case ifThen(AExpr ifCondition, AQuestion thenQuestion):
      return flatten(thenQuestion, push(ifCondition, stack));
    case ifThenElse(AExpr ifCondition, AQuestion thenQuestion, AQuestion ElseQuestion):
      return flatten(thenQuestion, push(ifCondition,stack));
  }
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 * Bonus: do it on concrete syntax trees.
 */
 
 AForm rename(Form f, loc useOrDef, str newName, UseDef useDef) {
   return f; 
 } 
 
 
 

