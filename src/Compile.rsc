module Compile

import AST;
import Resolve;
import IO;
import util::Math;
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
  // documentation is great, so grabbing filename this way
  // will break horribly if file structure is changed :)
  filename = src(f.src[extension="js"].top.path[10..]);
  
  HEAD = head([meta(charset("UTF-8")), title(f.name), script(filename)]);
  BODY = body(
    		form([onsubmit("return false")] + [form2html(question) | question <- f.questions] +
    			[input(\type("submit"), \value("Submit"), onclick("onSubmit();"))]),
    		p(id("output"))
    	);
  return html([HEAD, BODY]);
}

HTML5Node form2html(AQuestion q) {
  switch(q){
  	case question(str question, AId identifier, AType t, list[AExpr] expr): {
  		divargs = [class("question")];
  		if(expr != []){
  			divargs += [id(identifier.name), html5attr("expr", pretty_print(expr[0]))];
  			if(t.\type == "boolean"){
  			  divargs += [html5attr("data-value", "false")];
  		  } else if (t.\type == "integer"){
  		    divargs += [html5attr("data-value", 0)];
  		  } else if (t.\type == "string"){
  		    divargs += [html5attr("data-value", "")];
  		  }
  		} else {
  		  divargs += [question];
  		  if(t.\type == "boolean"){
  			  divargs += [input(\type("checkbox"), id(identifier.name), \value("false"), onchange("ev(); updateVisibility();"))];
  		  } else if (t.\type == "integer"){
  		    divargs += [input(\type("number"), id(identifier.name), \value(0), onchange("ev(); updateVisibility();"))];
  		  } else if (t.\type == "string"){
  		    divargs += [input(\type("text"), id(identifier.name), \value(""), onchange("ev(); updateVisibility();"))];
  		  }
  		}
  		return div(divargs);
  	}
  	case cond(AExpr c, list[AQuestion] \if, list[AQuestion] \else): {
  		return div([class("conditition")] + [form2html(h) | h <- \if] + [form2html(h) | h <- \else]);
  	}
  };
}

str pretty_print(AExpr c){
	switch(c){
		case brackets(AExpr ex): return "(<pretty_print(ex)>)";
		case not(AExpr ex): return "!" + "(<pretty_print(ex)>)";
		case divide(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) / (<pretty_print(ex1)>)";
		case multiply(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) * (<pretty_print(ex1)>)";
		case add(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) + (<pretty_print(ex1)>)";
		case subtract(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) - (<pretty_print(ex1)>)";
		case less(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) \< (<pretty_print(ex1)>)";
		case gtr(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) \> (<pretty_print(ex1)>)";
		case leq(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) \<= (<pretty_print(ex1)>)";
		case geq(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) \>= (<pretty_print(ex1)>)";
		case eq(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) == (<pretty_print(ex1)>)";
		case neq(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) != (<pretty_print(ex1)>)";
		case and(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) && (<pretty_print(ex1)>)";
		case or(AExpr ex1, AExpr ex2): return "(<pretty_print(ex1)>) || (<pretty_print(ex1)>)";
		case ref(AId id): return "(document.getElementById(\"<id.name>\").value)";
		case integer(int n): return toString(n);
		case boolean(str \bool): return \bool;
	}
}

str form2js(AForm f) {	
	return "<genIds(f)>\n" +
	"<onSubmit(f)>\n" + 
	"<evaluate()>\n" + 
	"<evaluateOnce()>\n" + 
	"<getValue()>\n" + 
	"<updateVisibility(f)>\n";
}

//- global list of question ids
str genIds(AForm f){
	ids = "var ids = [";
	for(/question(_, id, _, _) := f){
		ids += "\"" + id.name + "\"" + ",";
	}
	return ids + "];\n";
}

str onSubmit(AForm f){
	result = "function onSubmit(){\n" +
	"\tvar result = \"\";\n" +
	"\tfor(var i in ids){\n" +
	"\t\tvar em = document.getElementById(ids[i]);\n" +
	"\t\t// handle computed questions before normal questions\n" +
	"\t\tif(em.hasAttribute(\"data-value\") && em.visible){\n" +
	"\t\t\tresult += ids[i] + \" : \" + em.getAttribute(\"data-value\") + \"\\n\";\n" +
	"\t\t} else if(em.type == \"checkbox\"){\n" +
  	"\t\t\tresult += ids[i] + \" : \" + em.checked + \"\\n\"\n" +
	"\t\t} else if((! em.hasAttribute(\"class\")) && em.visible){\n" +
	"\t\t\tresult += ids[i] + \" : \" + em.value + \"\\n\";\n" +
	"\t\t}\n" +
	"\t}\n" +
	"\tdocument.getElementById(\"output\").innerHTML = result;\n" +
	"}\n";
	return result;
}

str evaluate(){
	return "function ev(){\n" + 
		"\tvar r = evOnce();\n" + 
		"\tvar s;\n" +
		"\twhile(true){\n" +
		"\t\ts = evOnce();\n" + 
		"\t\tif(r == s){\n" + 
		"\t\t\tbreak;\n" + 
		"\t\t}\n" + 
		"\t\tr = s;\n" + 
		"\t}\n" +
		"\treturn r\n" +
		"}\n";
}

str evaluateOnce(){ 
	return "function evOnce(){\n" +
		"\tvar result = \"\";\n" +
		"\tfor(var i in ids){\n" +
		"\t\tresult += ids[i] + \" : \" + recalculate(ids[i]) + \"\\n\";\n" +
		"\t}\n" +
		"\treturn result;\n" +
		"}\n";
}

str getValue(){
	return "function recalculate(id){\n" +
		"\tvar em = document.getElementById(id);\n" +
		"\tif(em.hasAttribute(\"expr\")) {\n" +
		"\t\tvar value = eval(em.expr);\n" +
		"\t\tem.setAttribute(\"data-value\", value);\n" +
		"\t\treturn value;\n" +
		"\t}\n"+
		"\tif(em.type == \"checkbox\"){\n" +
  		"\t\treturn em.checked;\n" +
		"\t}\n" +
		"\treturn em.value;\n" +
		"}\n";
}

str updateVisibility(AForm f){
	return "function updateVisibility(){\n" +
		"\t// mark every element as not visible\n" +
		"\tfor(i in ids){\n" +
		"\t\tdocument.getElementById(ids[i]).visible = false;\n" +
		"\t}\n\n" +
	
		"\t// mark visible elements as visible\n" +
		"<visibilityHelper(f.questions)>" +
	
		"\t// hide invisible elements, show visible elements\n" +
		"\tfor(i in ids){\n" +
		"\t\tvar em = document.getElementById(ids[i]);\n" +
		"\t\tif(!em.hasAttribute(\"expr\")){\n" +
		"\t\t\tif(em.visible){\n" +
		"\t\t\t\tif(em.parentElement.hasAttribute(\"hidden\")){\n" +
		"\t\t\t\t\tem.parentElement.removeAttribute(\"hidden\");\n" +
		"\t\t\t\t}\n" +
		"\t\t\t} else {\n" +
		"\t\t\t\tem.parentElement.setAttribute(\"hidden\", \"true\");\n" +
		"\t\t\t}\n" +
		"\t\t}\n" +
		"\t}\n" +
		"}\n";
}


str visibilityHelper(list[AQuestion] li){
	result = "";
	for(q <- li){
		switch(q){
			case cond(AExpr c, list[AQuestion] \if, list[AQuestion] \else): {
				result += "if ( eval(<pretty_print(c)>)) {\n";
  				result += "<visibilityHelper(\if)>\n";
  				result += "}\n";
  				if(\else != []){
  					result += "else {";
  					result += "<visibilityHelper(\else)>\n";
  					result += "}";	
  				}
  			}
  			case question(str question, AId identifier, AType t, list[AExpr] expr): {
  				result += "document.getElementById(\"<identifier.name>\").visible = true;\n";
  			} 
  			default :;
		};
	}
	return result;
}