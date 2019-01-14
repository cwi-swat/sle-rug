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
 
 alias ifConditions = list[AExpr];
 alias QuestionCondition = tuple[AQuestion, ifConditions];
 alias QuestionConditionList = list[QuestionCondition];

AForm flatten(AForm f) {
  // For every question that's in the form,
  // recursively collect the if-conditions
  QuestionConditionList qscs = [];
  for (AQuestion q <- f.questions) {
    // collect for the next question in the list
    qscs += flatten(q, [])<1>;
  }
  
  // Now, reconstruct a new abstract form
  list[AQuestion] finalQuestions = [];
  for(QuestionCondition qsc <- qscs) {
      // We use a reducer / fold method to use && on all ifconditions that apply to that question. base case = true
      // Note that we need to preserve the src of the question, so that we are allowed to generate identifiers
      finalQuestions += ifThen( (boolean(true, src=qsc<0>.src) | and(it, e, src=qsc<0>.src) | AExpr e <- qsc<1>), qsc<0>, src=qsc<0>.src);
  }
  
  // return it
  return form(f.name, finalQuestions, src=f.src);
}

/*
 * Flatten the current question recursively,
 * Maintain a stack of ifconditions
 * and return that stack + the collected questions
 */
tuple[ifConditions, QuestionConditionList] flatten(AQuestion q, ifConditions stack) {
  switch(q) {
    case question(str thequestion, str questionName, AType questionType):
      return <stack, [<q, stack>]>;
    case computed(str thequestion, str questionName, AType questionType, AExpr expression):
      return <stack, [<q, stack>]>;
    case ifThen(AExpr ifCondition, AQuestion thenQuestion):
      return flatten(thenQuestion, push(ifCondition, stack));
    case ifThenElse(AExpr ifCondition, AQuestion thenQuestion, AQuestion ElseQuestion):
      return flatten(thenQuestion, push(ifCondition,stack)) +
        flatten(thenQuestion, push(not(ifCondition, src=ifCondition.src),stack));
    case block(list[AQuestion] qs):
      return <stack, ( [] | it + flatten(q, stack)<1> | AQuestion q <- qs)>;
  }
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 * Bonus: do it on concrete syntax trees.
 */
 
 
 
 set[loc] eqClass(locc occ, UseDef ud) {
 	set[loc] class = {occ};
 	
 	class += {d | <occ, loc d> <- ud}
 		+ {u | <occ, loc d> <- ud, <loc u, d> <- ud};
 		
 	class += {u | <loc u, occ> <- ud};
 	return class;
 }

 
 bool validID(str name){
	try ([Id]name); catch: return false;
	return true;
}

 Form rename(Form f, loc useOrDef, str newName, UseDef useDef) {
 	assert useOrDef in occurences(ud): "not a name";
 	
  	toRename = eqClass(useOrDef, useDef);
  	assert validId(x): "Not a valid new name";
  	
  	return visit(f) {
  		case Id y => [Id] newName
  			when y@\loc in toRename;
	}
}
 
 
 

