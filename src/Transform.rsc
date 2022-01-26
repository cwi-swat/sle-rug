module Transform

import Syntax;
import Resolve;
import AST;
import ParseTree;

 
AForm flatten(AForm f) {	
  return  form(f.name, [*flattenQs(q, []) | AQuestion q <- f.questions]);; 
}

list[AQuestion] flattenQs(AQuestion q, list[AExpr] exprs) {
	switch(q) {
		case question(str _, AId _, AType _): return [ifblock(combineExpr(exprs), [q])];
		case computed(str _, AId _, AType _, AExpr _): return [ifblock(combineExpr(exprs), [q])];
		case block(list[AQuestion] questions): return [block([*flattenQs(q, exprs) | AQuestion q <- questions])];
		case ifblock(AExpr condition, list[AQuestion] questions): return [*flattenQs(q, exprs + [condition]) | AQuestion q <- questions];
		case ifelseblock(AExpr condition, list[AQuestion] questions, list[AQuestion] questionsSec): return [*flattenQs(q, exprs + [condition]) | AQuestion q <- questions] 
			+ [*flattenQs(q, exprs + [not(condition)]) | AQuestion q <- questionsSec];
	}
	return [];
}

AExpr combineExpr(list[AExpr] exprs) {
	AExpr res = boolConst(true);
	for(e <- exprs) {
		res = and(res, e);
	}
	return res;
}

start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
 	
 	set[loc] toRename = {};
 	
 	if(useOrDef in useDef<1>){
 		toRename += useOrDef;
 		toRename += { u | <loc u, useOrDef> <- useDef};
 	} else if (useOrDef in useDef<0>){
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