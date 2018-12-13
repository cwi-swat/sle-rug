module Pipeline

import ParseTree;
import vis::ParseTree;
import Syntax;
import CST2AST;
import Check;
import Resolve;
import Message;
import IO;
import Eval;

VEnv main() {
    // File to parse
	concrete_pt = parse(#start[Form], |project://QL/examples/tax.myql|);
	abstract_pt = cst2ast(concrete_pt);
	
	// Check for warnings before errors, and print them	
	for(warning(str msg, loc at) <- check(abstract_pt, collect(abstract_pt), resolve(abstract_pt))) {
	  println("WARNING: " + msg + " at: <at>");
	}
	
	// Check for errors now, and print them	
	for(error(str msg, loc at) <- check(abstract_pt, collect(abstract_pt), resolve(abstract_pt))) {
	  println("ERROR: " + msg + " at: <at>");
	}
	
	// Testing the resolve functions
	VEnv venv = eval(abstract_pt, input("hasSoldHouse", vbool(true)), initialEnv(abstract_pt));
	venv = eval(abstract_pt, input("sellingPrice", vint(42)), venv);
	
	return venv;
}