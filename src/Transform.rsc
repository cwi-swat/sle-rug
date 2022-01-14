module Transform

import Syntax;
import Resolve;
import AST;
import IO;
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
	list[AQuestion] qs = [*flattenQs(q, []) | AQuestion q <- f.questions];
	println(qs);
  AForm k = form(f.name, qs); 
  println(k);
  return k; 
}

list[AQuestion] flattenQs(AQuestion q, list[AExpr] exprs) {
	println("ha");
	switch(q) {
		case question(str _, AId _, AType _): return [ifblock(combineExpr(exprs), [q])];
		case computed(str _, AId _, AType _, AExpr _): return [ifblock(combineExpr(exprs), [q])];
		case ifblock(AExpr condition, list[AQuestion] questions): return [*flattenQs(q, exprs + [condition]) | AQuestion q <- questions];
		case ifelseblock(AExpr condition, list[AQuestion] questions, list[AQuestion] questionsSec): return [*flattenQs(q, exprs + [condition]) | AQuestion q <- questions] 
			+ [*flattenQs(q, exprs + [not(condition)]) | AQuestion q <- questionsSec];
	}
	return [];
}

AExpr combineExpr(list[AExpr] exprs) {
	println("hi");
	AExpr res = boolConst(true);
	for(e <- exprs) {
		res = and(res, e);
	}
	return res;
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
 start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
 	
 	set[loc] toRename = {};
 	
 	if(useOrDef in useDef<1>){
 		toRename += useOrDef;
 		toRename += { u | <loc u, useOrDef> <- useDef};
 	} else if (useOrDef in useDef<1>){
 		if (<useOrDef, loc d> <- useDef) {
 			toRename += { u | <d, loc u> <- useDef};
 		}
 	} else {
 		return f;
 	}
 	
 	return visit(f) {
		case Id x => [Id] newName
			when x@\loc in toRename
 	} 
 } 
 
 
 

