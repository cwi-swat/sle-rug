module Transform

import Syntax;
import Resolve;
import AST;
import IO;
import Tree;

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
	list[AQuestion] aqs = [];
	for(question <- f.questions){
		aqs += flatten(question, boolean("true"));
	}
	return form(f.name, aqs);
}

list[AQuestion] flatten(AQuestion question, AExpr condition){
	switch(question){
		case question(str q, AId id, AType \type, list[AExpr] expr):{
			if(boolean("true") == condition){
				return [question];
			}
			else{
				return [cond(condition, [question], [])];
			}
		}
		case cond(AExpr c, list[AQuestion] \if, list[AQuestion] \else) :{
			AExpr ifcon = and(c, condition);
			AExpr elsecon = and(not(c), condition);
			list[list[AQuestion]] result =  [flatten(qu, ifcon) | qu <- \if] +
											[flatten(qu, elsecon) | qu <- \else];
			list[AQuestion] final = [];
			for(res <- result){
				final += res;
			}
			return final;
		} 
	}
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
	//locations -> usedef
	//find all locations
	//print("\n");
	set[loc] locations = {};
	locations += {useOrDef};
	locations += {ud.use | ud <- useDef && ud.def == useOrDef};
	locations += {ud.def | ud <- useDef && ud.use == useOrDef};
	
	//print(locations);
	print("\n...............");
	//create a new form with the respective locations renamed
	print(f.top.questions);
	print("\n");
	return f; 
} 
 
 
 

