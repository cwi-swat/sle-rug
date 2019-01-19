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
import Set;

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
VEnv interpreterInput(str fileName, list[Input] is) {
  AForm f = abstractSyntaxTree(fileName);
  VEnv v = initialEnv(f);
  for(Input i <- is) {
    v = eval(f, i, v);
  }
  return v;
}

VEnv runInterpreter() {
  return interpreterInput("tax", [
  	input("hasBoughtHouse", vbool(true)),
  	input("hasMaintLoan", vbool(true)),
  	input("hasSoldHouse", vbool(true)),
  	input("sellingPrice", vint(1000)),
  	input("privateDebt", vint(500))
  ]);
}

// Week 6: Compilation is done by saving a file
// Week 7: Transformation - Flattening a form
AForm flattenForm(str fileName)
  = flatten(abstractSyntaxTree(fileName));

void flattenCompile(str fileName)
  = compile(flattenForm(fileName));
  
// Week 7: Transformation - Renaming a variable
start[Form] renameRandomVar(str fileName)
  = rename(
      concreteSyntaxTree(fileName), 
      takeOneFrom(occurences(abstractSyntaxTree(fileName)))<0>,
      "newVariableName",
      resolve(abstractSyntaxTree(fileName))
    );