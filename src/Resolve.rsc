module Resolve

import AST;


alias Def = rel[str name, loc def];

alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

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
  return {<i.name, i.src> | /question(str _, AId i, AType _) := f}
  		+ {<i.name, i.src> | /computed(str _, AId i, AType _, AExpr _) := f}; 
}