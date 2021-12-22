module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  return {<i.src, i.name> | /ref(AId i) := f}; 
}

Def defs(AForm f) {
  return {<i.name, q.src> | /q:question(str _, AId i, AType _) := f}
  		+ {<i.name, c.src> | /c:guarded(str _, AId i, AType _, AExpr _) := f}; 
}