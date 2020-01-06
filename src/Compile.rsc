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
  HEAD = head([title(f.name), script(src(f.name + ".js"))]);
  BODY = body(
    form([form2html(question) | question <- f.questions] + [input(\type("submit"), \value("Submit"))]));
  return html([HEAD, BODY]);
}

HTML5Node form2html(AQuestion q) {
  switch(q){
  	case question(str question, AId identifier, AType t, list[AExpr] expr): {
  		divargs = [class("question")] + [
  			question];
  		if(expr != []){
  			divargs += [hidden("true")];
  		}
  		if(t.\type == "boolean"){
  		  divargs += [input(\type("radio"), id(identifier.name), \value("true"), checked("true")), 
  			"True",
  			input(\type("radio"), id(identifier.name), \value("false")), 
  			"False"
  			];
  		} else if (t.\type == "integer"){
  		  divargs += [input(\type("number"), id(identifier.name))];
  		} else if (t.\type == "string"){
  		  divargs += [input(\type("text"), id(identifier.name))];
  		}
  		return div(divargs);
  	}
  	case cond(AExpr c, list[AQuestion] \if, list[AQuestion] \else): {
  		return div([class("conditition")] + [form2html(h) | h <- \if] + [form2html(h) | h <- \else]);
  	}
  };
}

//- What do we want the js to look like?

str form2js(AForm f) {
	result = "";
	// generate list of question ids
	result += genIds(f);
	result += "\n";
	
	// generate onSubmit() logic
	result += genOnSubmit(f);
	result += "\n";
	
	// generate onChange() logic
	result += genOnChange(f);
	result += "\n";
	
	return result;
}

//- global list of question ids
str genIds(AForm f){
	ids = "ids = [";
	for(/question(_, id, _, _) := f){
		ids += id.name + ",";
	}
	return ids + "];";
}

//- function onSubmit()
// - send logic
// - create results list
// - iterate over question ids
//   - add value if question not hidden
// - send results
str genOnSubmit(AForm f){
	return "";
}

//- function onChange()
//  - copy list of question ids
//  - run compiled js
//    - remove question from copylist if:
//      - it's id is found
//  - hide all questions in your list
str genOnChange(AForm f){
	result = "list = ids;\n";
	// compile conditions here
	result += foo(f.questions);
	
	result += "function onChange(){\n" +
			"\tfor(id in list){\n" +
			"\t\tdocument.getElementById(id).display=\"none\";\n" +
			"\t}\n" + 
			"}";
	return result;
}

str foo(list[AQuestion] li){
	result = "";
	for(q <- li){
		switch(q){
			case cond(AExpr c, list[AQuestion] \if, list[AQuestion] \else): {
				// TODO: make pretty printer for expressions
  				result += "if ( " + "<c>" + ") {\n";
  				result += foo(\if) + "\n";
  				result += "}\n";
  				if(\else != []){
  					result += "else {";
  					result += foo(\else) + "\n";
  					result += "}";	
  				}
  			}
  			default :;
		};
	}
	
	return result;
}

// OLD CODE

// str form2js(AForm f) {
//  super_long_string = "";
//  for(question <- f.questions){
//   	super_long_string += form2js(question);
//  }
//  return super_long_string;
//}

//str form2js(AQuestion q) {
//	some_unique_name = "";
//	switch(q){
//		case question(str question, AId identifier, AType t, list[AExpr] expr): {
//  			;
//  		}
//  		case cond(AExpr c, list[AQuestion] \if, list[AQuestion] \else): {
//  		// return div([class("conditition")] + [form2html(h) | h <- \if] + [form2html(h) | h <- \else]);
//  			some_unique_name += "if(" + "<c>" + ") {\n" ;
//  			for (question_foo <- \if) {
//  				// recursively hide each question in else
//  				some_unique_name += form2js(question_foo);
//  			} 
//  			some_unique_name += "}\n else {\n";
//  			for (question_bar <- \else) {
//  				// recursively hide each question in if
//  				some_unique_name += form2js(question_bar);
//  			} 
//  			some_unique_name += "}";
//  		}
//	};
//	return some_unique_name + "boop";
//}
