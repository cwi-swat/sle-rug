module Pipeline

import ParseTree;
import vis::ParseTree;
import util::Math;
import Syntax;
import CST2AST;
import Check;
import Resolve;
import Message;
import IO;
import Eval;
import Compile;
import Transform;
import AST;
import String;
import List;

// Week 2: Syntax.rsc -> Parsing a QL-Source code file into a Concrete Syntax Tree
start[Form] concreteSyntaxTree(str fileName)
  = parse(#start[Form], toLocation("project://QL/examples/" + fileName + ".myql"));

// Week 2: Viewing a Concrete Syntax Tree
void viewCST(str fileName)
 = renderParsetree(concreteSyntaxTree(fileName));

// Week 3: Concrete Syntax Tree to Abstract Syntax Tree
AForm abstractSyntaxTree(str fileName)
  = cst2ast(concreteSyntaxTree(fileName));
  
// Week 3: Resolving all identifiers of questions to their locations
UseDef getUseDef(str fileName)
  = resolve(abstractSyntaxTree(fileName));
  
// Week 4: Checking the Form-model for Semantic Errors and Warnings
set[Message] checkFile(str fileName)
  = check(abstractSyntaxTree(fileName), collect(abstractSyntaxTree(fileName)), resolve(abstractSyntaxTree(fileName)));

// Week 5: Simulating an Interpreter

Input randomValue(AForm f) {
  // Possible question names
  int rand = arbInt(3);
  list[str] names = [ q.name | /AQuestion q <- f.questions, q has name];
  switch(rand) {
    case 0:
      return input(takeOneFrom(names)<0>, vint(arbInt(1000)));
    case 1:
      return input(takeOneFrom(names)<0>, vbool(takeOneFrom([true, false])<0>));
    case 2:
      return input(takeOneFrom(names)<0>, vstr(toString(arbInt(10000000))));
  }
}

VEnv runInterpreter(str fileName, int n) {
  AForm f = abstractSyntaxTree(fileName);
  VEnv v = initialEnv(f);
  for(int i <- [0..n]) {
    v = eval(f, randomValue(f), v);
  }
  return v;
}

AForm pipe() {
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
	VEnv venv = Eval::eval(abstract_pt, input("hasSoldHouse", vbool(true)), initialEnv(abstract_pt));
	venv = Eval::eval(abstract_pt, input("sellingPrice", vint(42)), venv);
	
    // Apply transformations
	abstract_pt = flatten(abstract_pt);
	//compile(abstract_pt);
	
	return abstract_pt;
}