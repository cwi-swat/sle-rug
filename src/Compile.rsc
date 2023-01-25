module Compile

import AST;
import Resolve;
import IO;
import lang::html::AST; // see standard library
import lang::html::IO;

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTMLElement type and the `str writeHTMLString(HTMLElement x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

int countIfElseHTML = 1;
int countIfElseJS = 1;

int IS_INT = 0;
int IS_BOOL = 1;
int IS_STRING = 2;

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, writeHTMLString(form2html(f)));
}

/* HTMLElement e = text("Hello World!"); 
writeHTMLString(e);
str: "\<html\>\n    \<head\>\</head\>\n    \<body\>\n        Hello World!\n    \</body\>\n\</html\>"
---
<html>
    <head></head>
    <body>
        Hello World!
    </body>
</html>
---
*/


HTMLElement form2html(AForm f) {
  list[HTMLElement] elements = [];

  elements += head([text(f.name.name)]);
  
  for (AQuestion q <- f.questions ){
    elements += question2html(q);
  }

  elements += button([text("Submit " + f.name.name)] \onclick = "popUpExpression()"); 
  list[HTMLElement] parts = [];
  parts += body(elements);
  parts += giveScript(f);
  return html(parts);
}

HTMLElement giveScript(AForm f) {
  return script([], \src=f.src[extension="js"].file);
}

list[HTMLElement] question2html(AQuestion q) {
  list[HTMLElement] elementQuestion = [];
  list[HTMLElement] ifQuestion = [];
  list[HTMLElement] elseQuestion = [];

  str elseId;
  str ifId;

  switch(q){
    case question(str name, APrompt prompt): {

      elementQuestion += p([text(name)]);
      elementQuestion += prompt2html(prompt);
    }

    case question(AExpr expr,  list[AQuestion] questions, list[AElseStatement] elseStat): {
      ifId = "IfStatement" + "<countIfElseHTML>";
      elseId = "elseStatement" + "<countIfElseHTML>";
      countIfElseHTML = countIfElseHTML + 1;
      
      ifQuestion += h2([text("IF Statement")]);
      
      //If statemment Guard action
      switch(expr){
      case expr(ATerm aterm): {
        // If guard is a one term expression (Example: "hasSold")
        println("test5");
        println(aterm);
        
        }
      }

      
      // Questions in if-statement
      for(AQuestion q <- questions) {
        ifQuestion += question2html(q);
      }
      // Questions in else-statement
      for(AElseStatement els <- elseStat) {
        for(AQuestion q <- els.questions) {
          elseQuestion += h2([text("ELSE Statement")]);
          elseQuestion += question2html(q);
        }
      }
      
    }
  }

  if(ifQuestion != []){
    elementQuestion += div(ifQuestion, \id =ifId, \style = "display:none");
    if(elseQuestion != []){
      elementQuestion += div(elseQuestion, \id = elseId, \style = "display:none");
    }
  }

  return elementQuestion;
}

list[HTMLElement] prompt2html(APrompt prompt) {
  list[HTMLElement] elements = [];
  bool readOnly = false;

  /* There is an expression so it should be read and not written */
  //println(prompt.expressions);

  if(prompt.expressions != []) {
    readOnly = true;
  }

  switch(prompt.aType.typeName) {
    case "integer": {
      HTMLElement numberInput;
      if(readOnly) {
        numberInput = input(\type = "number", readonly = "readonly", \id = prompt.id.name, \value = "0");
      }
      else {
        numberInput = input(\type = "number", \id = prompt.id.name, \value = "0");
      }
      elements += form([numberInput]);
      //HTMLElement action = "intSubmission";
    }
    case "boolean": {
      HTMLElement boolInput;
      if(readOnly) {
        boolInput = input(\type = "checkbox", disabled = "disable", \id = prompt.id.name, \onclick = "popUpBool(this.id)");
      }
      else {
        boolInput = input(\type = "checkbox", \id = prompt.id.name, \value = "false", \onclick = "popUpBool(this.id)");
      }
      elements += form([boolInput]);
    }
    case "str": {
      HTMLElement textInput;
      if(readOnly) {
        textInput = input(\type = "text", readonly = "readonly", \id = prompt.id.name);
      }
      else {
        textInput = input(\type = "text", \id = prompt.id.name);
      }
      elements += form([textInput]);
    }

  }

  return elements;
}

// For Javascript script

str form2js(AForm f) {
  str code = 
  "valueMap = new Map();
  '
  '
  '
  '
  '
  '
  '
  'function popUpBool(id){
  ' <makePopUpBool(f)>
  '}
  '
  'function popUpExpression(){ 
  '
  ' <makePopUpExpression(f)>
  '}
  '
  ";

  /*
  code += "valueMap = new Map();\n";

  for (AQuestion q <- f.questions ){
    code += question2js(q);
  }*/

  return code;
}

str makePopUpBool(AForm f){
  str code = "";

  code += "if(document.getElementById(id).value == \"false\") {\n  document.getElementById(id).value = \"true\";\n}\n";
  code += "else if(document.getElementById(id).value == \"true\") {\n   document.getElementById(id).value = \"false\";\n}\n";
  code += "popUpExpression();\n";

  return code;
}


str makePopUpExpression(AForm f){
  str code = "";
  
  for (AQuestion q <- f.questions ){
    switch(q){
      case question(AExpr expr, list[AQuestion] questions, list[AElseStatement] elseStat):  {
        str ifId = "IfStatement" + "<countIfElseJS>";
        str elseId = "elseStatement" + "<countIfElseJS>";
        bool hasElse = (elseStat != []);
        countIfElseJS = countIfElseJS + 1;
        code += "if(" + expr2js(expr, IS_BOOL);
          code +="){
                 '    document.getElementById(\"";
                 
          code += ifId;
          
          code += "\").style.display = \"block\";";
          
          if(hasElse) {
            code += "    document.getElementById(\"";         
            code += elseId;
            code += "\").style.display = \"none\";";
          }
                 
          code += " 
                  '} 
                  'else {
                  '    document.getElementById(\"";
          code += ifId;
          code += "\").style.display = \"none\";";
          
          if (hasElse) {
            code += "document.getElementById(\"";
            code += elseId;
            code += "\").style.display = \"block\";";            
          }
          
          code += " 
                  '}
                  ' 
                  '"; 
          

      }
    }
  }

  return code;

}

str expr2js(AExpr e, int ofType) {
  str code = "";

  switch(e) {
    case expr(ATerm aterm):
      code += term2js(aterm, ofType);

    case exprPar(AExpr expr):
      code += "(" + expr2js(expr, ofType) + ")";

    case not(AExpr rhs):
      code += "!" + expr2js(rhs, IS_BOOL);
    
    case umin(AExpr rhs):
      code += "-" + expr2js(rhs, IS_INT);

    case binaryOp(ABinaryOp bOp):
      code += binaryOp2js(bOp);
  }
  return code;
}

str term2js(ATerm t, int ofType) {
  str code = "";

  switch(t) {
    case term(id(str name)): {
      code += "document.getElementById(\"" + name + "\").value";
        if(ofType == IS_BOOL) {
          code += " == \"true\"";
        }
    } 
    case termInt(str integer): {
      code += "\"" + integer + "\"";
    }
    case termBool(str boolean): { 
      code += "\"" + boolean + "\"";
    }
    case termStr(str string): {
      code += string;
    }
  }

  return code;
}

str binaryOp2js(ABinaryOp bOp) {
  str code = "";

  switch (bOp) {
    case mul(AExpr lhs, AExpr rhs):{
      code += expr2js(lhs, IS_INT);
      code += " * ";
      code += expr2js(rhs, IS_INT);
    }
    case div(AExpr lhs,  AExpr rhs):{
      code += expr2js(lhs, IS_INT);
      code += " / ";
      code += expr2js(rhs, IS_INT);
    }
    case add(AExpr lhs,  AExpr rhs):{
      code += expr2js(lhs, IS_INT);
      code += " + ";
      code += expr2js(rhs, IS_INT);
    }
    case sub(AExpr lhs,  AExpr rhs):{
      code += expr2js(lhs, IS_INT);
      code += " - ";
      code += expr2js(rhs, IS_INT);
    }
    case greth(AExpr lhs,  AExpr rhs):{
      code += expr2js(lhs, IS_INT);
      code += " \> ";
      code += expr2js(rhs, IS_INT);
    } 
    case leth(AExpr lhs,  AExpr rhs):{
      code += expr2js(lhs, IS_INT);
      code += " \< ";
      code += expr2js(rhs, IS_INT);
    }
    case geq(AExpr lhs,  AExpr rhs):{
      code += expr2js(lhs, IS_INT);
      code += " \>= ";
      code += expr2js(rhs, IS_INT);
    }
    case leq(AExpr lhs,  AExpr rhs): {
      code += expr2js(lhs, IS_INT);
      code += " \<= ";
      code += expr2js(rhs, IS_INT);
    }
    case eqls(AExpr lhs,  AExpr rhs): {
      code += expr2js(lhs, IS_STRING);
      code += " == ";
      code += expr2js(rhs, IS_STRING);
    }
    case neq(AExpr lhs,  AExpr rhs): {
      code += expr2js(lhs, IS_STRING);
      code += " != ";
      code += expr2js(rhs, IS_STRING);
    }
    case and(AExpr lhs,  AExpr rhs): {
      code += expr2js(lhs, IS_BOOL);
      code += " && ";
      code += expr2js(rhs, IS_BOOL);
    }
    case or(AExpr lhs,  AExpr rhs): {
      code += expr2js(lhs, IS_BOOL);
      code += " || ";
      code += expr2js(rhs, IS_BOOL);
    }
  }

  return code;
}


str prompt2js(APrompt prompt) {
  str code = "";

  switch(prompt.aType.typeName) {
    case "integer": {
      return "";
    }
    case "boolean": {
      return "";
    }
    case "str": {
      return "";
    }
  }

  return code;
}

void testing() {
  HTMLElement el = form([], \type = "number");
  println(writeHTMLString(el));
}
