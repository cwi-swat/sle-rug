module IDE

/*
 * Import this module in a Rascal terminal and execute `main()`
 * to enable language services in the IDE.
 */

import util::LanguageServer;
import util::Reflective;

import IO;

import Syntax;
import AST;
import CST2AST;
import Resolve;
import Check;
import Compile;
import Message;
import ParseTree;


set[LanguageService] myLanguageContributor() = {
    parser(Tree (str input, loc src) {
        return parse(#start[Form], input, src);
    }),
    lenses(myLenses),
    executor(myCommands),
    summarizer(mySummarizer
        , providesDocumentation = true
        , providesDefinitions = true
        , providesReferences = false
        , providesImplementations = false)
};

str type2str(tint()) = "integer";
str type2str(tbool()) = "boolean";
str type2str(tstr()) = "string";
str type2str(tunknown()) = "unknown";

Summary mySummarizer(loc origin, start[Form] input) {
  AForm ast = cst2ast(input);
  RefGraph g = resolve(ast);
  TEnv tenv = collect(ast);
  set[Message] msgs = check(ast, tenv, g.useDef);

  rel[loc, Message] msgMap = {< m.at, m> | Message m <- msgs };
  
  rel[loc, str] docs = { <u, "Type: <type2str(t)>"> | <loc u, loc d> <- g.useDef, <d, _, _, Type t> <- tenv };
  return summary(origin, messages = msgMap, definitions = g.useDef, documentation = docs);
}

data Command
  = compileQL(start[Form] form);

rel[loc,Command] myLenses(start[Form] input) 
  = {<input@\loc, compileQL(input, title="Compile")>};


void myCommands(compileQL(start[Form] ql)) {
    compile(cst2ast(ql));
}

void main() {
    registerLanguage(
        language(
            pathConfig(srcs = [|std:///|, |project://sle-rug/src|]),
            "QL",
            "myql",
            "IDE",
            "myLanguageContributor"
        )
    );
}


