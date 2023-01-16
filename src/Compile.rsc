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

void compile(AForm f) {
  //writeFile(f.src[extension="js"].top, form2js(f));
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

  elements += button([text("Submit " + f.name.name)]); 
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

  switch(q){
    case question(str name, APrompt prompt): {

      elementQuestion += p([text(name)]);
      elementQuestion += prompt2html(prompt);
    }

    case question(AExpr expr,  list[AQuestion] questions, list[AElseStatement] elseStat): {
      ifQuestion += h2([text("IF Statement")]);
      //If statemment Guard action

       switch(expr){
        case expr(ATerm aterm): {
          println("test5");
          println(aterm);
          
         }
        }


      // 1 ding (HasSold)
      // list[popUpbool] = <hasSold, IfsStametemnt1>

      //Expression
      //list[popUpexpression] = <Epression, IfsStametemnt2>
      //              > Expresiioin = id (.value) / value_int ("100") / bool (.checked) / str ("hello")  



      
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
    elementQuestion += div(ifQuestion);
    if(elseQuestion != []){
      elementQuestion += div(elseQuestion);
    }
  }

  return elements;
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
        numberInput = input(\type = "number", readonly = "readonly");
      }
      else {
        numberInput = input(\type = "number");
      }
      
      elements += form([numberInput]);
      //HTMLElement action = "intSubmission";
    }
    case "boolean": {
      HTMLElement boolInput;
      if(readOnly) {
        boolInput = input(\type = "checkbox", disabled = "disable");
      }
      else {
        boolInput = input(\type = "checkbox");
      }
      elements += form([boolInput]);
    }
    case "str": {
      HTMLElement textInput;
      if(readOnly) {
        textInput = input(\type = "text", readonly = "readonly");
      }
      else {
        textInput = input(\type = "text");
      }
      elements += form([textInput]);
    }

  }

  return elements;
}

str form2js(AForm f) {
  str code = "";

  code += "valueMap = new Map();\n";

  for (AQuestion q <- f.questions ){
    code += question2string(q);
  }

  return code;
}

str question2string(q) {
  str code = "";

  switch(q) {
    case question(str name, APrompt prompt): {
      return "";
    }
    case question(AExpr expr, list[AQuestion] questions, list[AElseStatement] elseStat):  {
      return "";
    }
  }

  return code;
}

void testing() {
  HTMLElement el = form([], \type = "number");
  println(writeHTMLString(el));
}
