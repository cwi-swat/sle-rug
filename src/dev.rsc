module dev

import AST;
import Check;
import Compile;
import CST2AST;
import Eval;
import IDE;
import Resolve;
import Syntax;
import Transform;

// Function to run the whole pipeline.
//apt(parse(#start[Form], |project://QL/examples/errors.myql|));