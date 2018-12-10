module Dev

import ParseTree;
import vis::ParseTree;
import Syntax;
import CST2AST;
import Check;
import Resolve;
import Message;

set[Message] main() {
    // File to parse
	concrete_pt = parse(#start[Form], |project://QL/examples/tax.myql|);
	abstract_pt = cst2ast(concrete_pt);
	
	// Check for errors
	return check(abstract_pt, collect(abstract_pt), resolve(abstract_pt));
}