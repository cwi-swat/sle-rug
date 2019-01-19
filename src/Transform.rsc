module Transform

import Syntax;
import Resolve;
import AST;
import List;
import Syntax;
import CST2AST;
import IO;
import ParseTree;

/* 
 * Transforming QL forms
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
 
 set[loc] eqClass(loc occ, UseDef ud) {
 	set[loc] class = {occ};
 	
 	class += {d | <occ, loc d> <- ud}
 		+ {u | <occ, loc d> <- ud, <loc u, d> <- ud};
 		
 	class += {u | <loc u, occ> <- ud};
 	return class;
 }
 
 set[loc] occurences(AForm f) {
    // Uses
    set[loc] occurences = uses(f)<0>;
    
    // Declarations
    occurences += defs(f)<1>;
    
    return occurences;

 } 

 
 // We check if the name is a valid Identifier, by using a try-catch construct
 bool validID(str name){
	try ([Id]name); catch: return false;
	return true;
}

// Rename a (computed) question and all occurences of it
 start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
 	
 	// We have to make sure that we are renaming a valid name.
 	assert useOrDef in occurences(cst2ast(f.top)): "not a name";
 	
 	// We have to make sure that the new name has the correct format
 	assert validID(newName): "Not a valid new name";
 	
 	// Get all Question-locations and Expression-locations
  	toRename = eqClass(useOrDef, useDef);
  	
  	// The new name will be an identifier, constructed from a string
  	Id newNameId = [Id] newName;
  	
  	// We are matching all (nested) constructs within the form
  	return visit(f){
  		// In case we have a question, of which the location is in toRename, we update the identifier
  		case q0: (Question)`<Str s> <Id name> : <Type t>` => (Question)`<Str s> <Id newNameId> : <Type t>`
  			when (q0@\loc) in toRename
  		// In case we have a computed question, of which the location is in toRename, we update the identifier
  		case q1: (Question)`<Str s> <Id name> : <Type t> = <Expr e>` => (Question)`<Str s> <Id newNameId> : <Type t> = <Expr e>`
  			when (q1@\loc) in toRename
  		// In case we have an identifier, of which the location is in toRename, we update it.
  		case q2: Id x => newNameId
  			when (q2@\loc) in toRename
  	};
}
 
 

