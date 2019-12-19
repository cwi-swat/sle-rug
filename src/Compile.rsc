module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM; // see standard library

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTML5Node type and the `str toString(HTML5Node x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, "\<!doctype html\>\n" + toString(form2html(f)));
}

HTML5Node form2html(AForm f) {
  HEAD = head(title(f.name));
  BODY = body(
    form([form2html(question) | question <- f.questions] + [input(\type("submit"), \value("Submit"))]));
  return html([HEAD, BODY]);
}

HTML5Node form2html(AQuestion q) {
  switch(q){
  	case question(str question, AId identifier, AType t, list[AExpr] expr): {
  		divargs = [class("question"), id(identifier.name)] + [
  			question];
  		if(expr != []){
  			divargs += [hidden("true")];
  		}
  		
  		if(t.\type == "boolean"){
  		  divargs += [input(\type("radio"), name(identifier.name), \value("true"), checked("true")), 
  			"True",
  			input(\type("radio"), name(identifier.name), \value("false")), 
  			"False"
  			];
  		} else if (t.\type == "integer"){
  		  divargs += [input(\type("number"), name(identifier.name))];
  		} else if (t.\type == "string"){
  		  divargs += [input(\type("text"), name(identifier.name))];
  		}
  		return div(divargs);
  	}
  	case cond(AExpr c, list[AQuestion] \if, list[AQuestion] \else): {
  		return div([class("conditition")] + [form2html(h) | h <- \if] + [form2html(h) | h <- \else]);
  	}
  };
}

str form2js(AForm f) {
  return "";
}
