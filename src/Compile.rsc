module Compile

import AST;
import Resolve;
import IO;
import Transform;
import lang::html::AST; // see standard library
import lang::html::IO;
import vis::Text;


void compile(AForm f) {
  str name = f.src.file;
  AForm flattened = flatten(f);

  writeFile(f.src[extension="js"].top, form2js(flattened));
  writeFile(f.src[extension="html"].top, writeHTMLString(form2html(flattened, name)));
}


HTMLElement form2html(AForm f, str fileName) {
HTMLElement body = makeBody(f, fileName);


return html([body]);
}


HTMLElement makeBody(AForm f, str fileName) {
  list[HTMLElement] divList = [];
  println(f.src.file);

  for (AQuestion ifQuestion <- f.questions) {
    AQuestion question = ifQuestion.ifQuestions[0];

    // strings needed for the div
    str questionText = "";
    str varType = "";
    str varName = "";


    // label of the question
    questionText = question.question.name;

    // id used for the div
    varName = question.answer.name;

    HTMLElement hTwo = h2([text(questionText)]);

    // getting the type of the HTML element
    switch(question.answerType) {
      case booleanType(): varType = "checkbox";
      case strType(): varType = "text";
      case integerType(): varType = "number";
    }

    // if the question is has an AExpr its a computed question
    // therefore read only
    HTMLElement htmlInput;
    switch (question) {
      case question(_,_,_):
      {
        htmlInput = input(\type = varType, name = varName);
      }
      case question(_,_,_,_): {
        htmlInput = input(\type = varType, name = varName, readonly = "true");
      }
    }

      divList += div([hTwo, htmlInput]);
  }
  divList += script([], src = fileName);
  return body(divList);
}

str form2js(AForm f) {
  str js = "";
  str declerations = "";

  // declaring the declerations at the top;
  for (AQuestion ifQuestion <- f.questions) {

    AQuestion question = ifQuestion.ifQuestions[0];
    declerations += "const ";

    str varName = question.answer.name;

    declerations += varName;
    switch(question.answerType) {
      case booleanType(): declerations += "Checkbox";
      case strType(): declerations += "Input";
      case integerType(): declerations += "Input";
    }
    declerations += " = document.querySelector(\'input[name=\"";
    declerations += varName;
    declerations+= "\"]\');";
    declerations+= "\n";
  }

  js += declerations;
  js += "\n\n";

  for (AQuestion ifQuestion <- f.questions) {
    AQuestion question = ifQuestion.ifQuestions[0];
    if (ifQuestion.expr == ref(boolean("true"))) continue;
    for (/id(str name) := ifQuestion.expr) {
      js += name;
      js += "Checkbox.addEventListener(\'change\', function() {\n";
      js += "\tif (this.checked) {\n\t\t";

      str varName = question.answer.name;
      switch(question.answerType) {
        case booleanType(): varName += "Checkbox";
        default: varName += "Input";
      }
      js += varName;
      js += ".parentElement.style.display = \"block\";\n";
      js += "\t} else {\n\t\t";
      js += varName;
      js += ".parentElement.style.display = \"none\";\n";
      js += "\t}\n";
      js += "});\n\n";
    }
  }



  return js;
}
