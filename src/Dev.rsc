module Dev

import ParseTree;
import vis::ParseTree;
import Syntax;
import CST2AST;
import Check;
import Resolve;
import Message;
import IO;

void main() {
    // File to parse
	concrete_pt = parse(#start[Form], |project://QL/examples/errors.myql|);
	abstract_pt = cst2ast(concrete_pt);
	
	// Check for warnings before errors, and print them	
	for(warning(str msg, loc at) <- check(abstract_pt, collect(abstract_pt), resolve(abstract_pt))) {
	  println("WARNING: " + msg + " at: <at>");
	}
	
	// Check for errors now, and print them	
	for(error(str msg, loc at) <- check(abstract_pt, collect(abstract_pt), resolve(abstract_pt))) {
	  println("ERROR: " + msg + " at: <at>");
	}
	
	return;
}