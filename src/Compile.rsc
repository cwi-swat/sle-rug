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

/* Global variables for the labels of the if/else sections */
int countIfElseHTML = 1;
int countIfElseJS = 1;

/* Global varaibales for checking the type of a prompt */
int IS_INT = 0;
int IS_BOOL = 1;
int IS_STRING = 2;


/* 
 * Main function for creating .hmtl and .js file from AForm file 
 */
void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, writeHTMLString(form2html(f)));
}

/* 
 * Code for the HTML script
 */


/* 
 * Returns HTML Element of the whole AFrom
 */
HTMLElement form2html(AForm f) {
  list[HTMLElement] elements = [];

  elements += head([text(f.name.name)]);
  
  /* Adds list of HTML Elements of each question to the list of HTML Elements */
  for (AQuestion q <- f.questions ){
    elements += question2html(q);
  }

  elements += button([text("Submit " + f.name.name)] \onclick = "refresh()"); 
  list[HTMLElement] parts = [];
  parts += body(elements);
  parts += giveScript(f);
  return html(parts);
}

/* 
 * Returns HTML Element script of the js file that is linked to the AForm, and therefore the HTML file
 */
HTMLElement giveScript(AForm f) {
  return script([], \src=f.src[extension="js"].file);
}

/* 
 * Returns a list of HTML Elements of a question
 */
list[HTMLElement] question2html(AQuestion q) {
  list[HTMLElement] elementQuestion = [];
  list[HTMLElement] ifQuestion = [];
  list[HTMLElement] elseQuestion = [];

  str elseId;
  str ifId;

  switch(q){
    case question(str name, APrompt prompt): {
      /* Adds HTML Elements of prompt to the list */
      elementQuestion += p([text(name)]);
      elementQuestion += prompt2html(prompt);
    }

    case question(AExpr expr,  list[AQuestion] questions, list[AElseStatement] elseStat): {
      /* Creates labels for div-section HTML of if/else statement */
      ifId = "IfStatement" + "<countIfElseHTML>";
      elseId = "elseStatement" + "<countIfElseHTML>";

      /* Increase the amount of labels*/ 
      countIfElseHTML = countIfElseHTML + 1;
    
      /* The HTML Elements of each question in if-statement added to if-list */
      for(AQuestion q <- questions) {
        ifQuestion += question2html(q);
      }
      /* The HTML Elements of each question in else-statement added to else-list */
      for(AElseStatement els <- elseStat) {
        for(AQuestion q <- els.questions) {
          elseQuestion += question2html(q);
        }
      }
      
    }
  }

  if(ifQuestion != []){
    /* Adds div HTML Element to if statement */ 
    elementQuestion += div(ifQuestion, \id =ifId, \style = "display:none");
    if(elseQuestion != []){
      /* Adds div HTML Element to else statement */ 
      elementQuestion += div(elseQuestion, \id = elseId, \style = "display:none");
    }
  }

  return elementQuestion;
}

/* 
 * Returns a list of HTML Elements of a prompt
 */
list[HTMLElement] prompt2html(APrompt prompt) {
  list[HTMLElement] elements = [];
  bool readOnly = false;
  str insertValue = "0";

  /* There is an expression so it should be read and not written */
  if(prompt.expressions != []) {
    readOnly = true;
    for(expr <- prompt.expressions) {
      insertValue = expr2js(expr, IS_STRING);
    }
  }

  switch(prompt.aType.typeName) {
    case "integer": {
      HTMLElement numberInput;
      if(readOnly) {
        numberInput = input(\type = "number", readonly = "readonly", \id = prompt.id.name, \value = "<insertValue>");
      }
      else {
        numberInput = input(\type = "number", \id = prompt.id.name, \value = "0");
      }
      elements += form([numberInput]);
    }
    case "boolean": {
      HTMLElement boolInput;
      if(readOnly) {
        boolInput = select([option([text("-")], \value = "default"), option([text("Yes")], \value = "true"), option([text("No")], \value = "false")], \id = prompt.id.name, disabled = "disable");
      }
      else {
        boolInput = select([option([text("-")], \id = prompt.id.name, \value = "default"), option([text("Yes")], \value = "true"), option([text("No")], \value = "false")], \id = prompt.id.name);
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


/* 
 * Code for the Javascript script
 */

/* 
 * Creation of the javascript file
 */
str form2js(AForm f) {
  str code = 
  "
  'function popUpBool(id){
  ' <makePopUpBool(f)>
  '}
  '
  'function popUpExpression(){ 
  '
  ' <makePopUpExpression(f)>
  '}
  '
  '
  'function setValues(){
  ' <makeSetValues(f)>
  '}
  '
  '
  'function refresh(){
  ' setValues();
  ' popUpExpression();
  '}
  '
  'refresh();
  ";

  return code;
}

/* 
 * Javascript script for the popUpBool(id) function
 * popUpBool(id) handels the actions for the if and else statements
 */
str makePopUpBool(AForm f){
  str code = "";

  code += "if(document.getElementById(id).value == \"false\" || document.getElementById(id).value == \"default\") {\n  document.getElementById(id).value = \"true\";\n}\n";
  code += "else if(document.getElementById(id).value == \"true\") {\n   document.getElementById(id).value = \"false\";\n}\n";
  code += "popUpExpression();\n";

  return code;
}

/* 
 * Javascript script for the popUpExpression() function
 * popUpExpression() handels the actions for the expressions
 */
str makePopUpExpression(AForm f){
  str code = "";
  
  for (AQuestion q <- f.questions ){
    code += question2js(q);
  }

  return code;

}

/* 
 * Javascript script for the setValues() function
 * setValues() handels setting the values of the prompts 
 */
str makeSetValues(AForm f) {
  str code = "";
  
  for(/APrompt p := f) {
    /* Adds the code for setting values of each prompt */
    code += promptSetValue(p);
  }

  return code;
}

/* 
 * Javascript script for setting the values of the prompts 
 */
str promptSetValue(APrompt p) {
  str code = "";

  switch (p) {
    case prompt(AId id, AType aType, list[AExpr] expressions): {
        for(AExpr e <- expressions) {
          code += "document.getElementById(\"" + id.name + "\").value = ";
          code += expr2js(e, IS_STRING);
          code += "\n";
          if(aType.typeName == "boolean") {
            code += "if(document.getElementById(\"" + id.name + "\").value == \"true\")";
            code += "{
                  ' document.getElementById(\"" + id.name + "\").selected = \"true\";";
            code += "
                    '} \n";
            code += "else {
                    ' document.getElementById(\"" + id.name + "\").selected = \"false\";
                    '} \n";
          }
        }
    }
  }

  return code;
}

/* 
 * Javascript script for setting the values of the prompts 
 */
str question2js(AQuestion q) {
  str code = "";
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

          /* Loop over list of questions of if statement */
          for(AQuestion question <- questions) {
            code += question2js(question);
          }
                
          code += " 
                  '} 
                  'else if(!(" + expr2js(expr, IS_BOOL) + ") && (" + expr2js(expr, IS_STRING) + ") != \"default\") {
                  '    document.getElementById(\"";
          code += ifId;
          code += "\").style.display = \"none\";";
          
          /* Add javascript if else statement exists */
          if (hasElse) {
            code += "document.getElementById(\"";
            code += elseId;
            code += "\").style.display = \"block\";";            
          }

          /* Loop over list of questions of else statement*/
          for(AElseStatement els <- elseStat) {
            for(AQuestion question <- els.questions) {
              code += question2js(question);
            }
          }

          
          code += " 
                  '}
                  ' 
                  '"; 
      }
    }
    return code;
}

/* 
 * Javascript script for expressions
 */
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

/* 
 * Javascript script for term
 */
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
      code += integer;
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

/* 
 * Javascript script for expressions with binary operators
 */
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



