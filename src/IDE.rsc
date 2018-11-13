module IDE

import QL;
import AST;
import CST2AST;
import Resolve;
import Check;
import Compile;

import Message;
import ParseTree;


private str TQL ="Tutorial QL";

anno rel[loc, loc] Tree@hyperlinks;

void main() {
  registerLanguage(TQL, "tql", Tree(str src, loc l) {
    return parse(#start[Form], src, l);
  });
  
  contribs = {
    annotator(Tree(Tree t) {
      if (start[Form] pt := t) {
        AForm ast = cst2ast(pt);
        UseDef useDef = resolve(ast);
        set[Message] msgs = check(ast, collect(ast), useDef);
        return t[@messages=msgs][@hyperlinks=useDef];
      }
      return t[@message={error("Not a form", t@\loc)}];
    }),
    
    builder(set[Message] (Tree t) {
      if (start[Form] pt := t) {
        AForm ast = cst2ast(pt);
        UseDef useDef = resolve(ast);
        set[Message] msgs = check(ast, collect(ast), useDef);
        if (msgs == {}) {
          compile(ast);
        }
        return msgs;
      }
      return {error("Not a form", t@\loc)};
    })
  };
  
  registerContributions(TQL, contribs);
}
