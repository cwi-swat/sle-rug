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
  return body(elements);
}



list[HTMLElement] question2html(AQuestion q) {
  list[HTMLElement] elements = [];
  list[HTMLElement] ifElseQuestion = [];

  switch(q) {
    case question(str name, APrompt prompt): {
      elements += p([text(name)]);
      elements += prompt2html(prompt);
    }
    case question(AExpr expr, list[AQuestion] questions, list[AElseStatement] elseStat): {
      //If statemment Guard action
      
      // Questions in if-statement
      for(AQuestion q <- questions) {
        ifElseQuestion += question2html(q);
      }
      // Questions in else-statement
      for(AElseStatement els <- elseStat) {
        for(AQuestion q <- els.questions) {
          ifElseQuestion += question2html(q);
        }
      }
    }
  }

  if(ifElseQuestion != []){
    elements += div(ifElseQuestion);
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
  return "";
}

void testing() {
  HTMLElement el = form([], \type = "number");
  println(writeHTMLString(el));
}
