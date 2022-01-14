module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM; // see standard library
import util::Math;

/*
 //* Implement a compiler for QL to HTML and Javascript
 //*
 //* - assume the form is type- and name-correct
 //* - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 //* - use the HTML5Node type and the `str toString(HTML5Node x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 //* - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 //* - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

int count = 0;
int countJs = 0;


void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, toString(form2html(f)));
}

HTML5Node form2html(AForm f) {
  return html(
  	head(
  		title("Form <f.name>"),
  		link(\rel("stylesheet"), href("style.css"))
  	), body (
  		onload("run()"),
  		script(src(f.src[extension="js"].file)), 		
		form(
			html5node("div", [ question2html(q) | q <- f.questions]),
			input(\type("Submit"), \value("Submit"))
		)
  	)
  );
}

HTML5Node question2html(AQuestion qs) {
	switch(qs) {
		case question(str label, AId id, AType typ): return question2form(qs);
		case computed(str label, AId id, AType typ, AExpr expr): return computed2form(qs);
	}
	
	count +=1;
	str countStr = toString(count);
	switch(qs) {
		case ifblock(AExpr condition, list[AQuestion] questions): return div([question2html(q) | q <- questions] + [id("If-Field-"+countStr)]);
		case ifelseblock(AExpr condition, list[AQuestion] questions, list[AQuestion] questionsSec): return div(div([question2html(q) | q <- questions] + [id("If-Field-"+countStr)]), 
			div([question2html(q) | q <- questionsSec] + [id("Else-Field-"+countStr)]));		
	}
	return p("error");
}




HTML5Node question2form(AQuestion qs) {
	switch(qs.typ) {
		case string(): return div(label(qs.label), input(\type("text"), id(qs.id.name)));
		case integer(): return div(label(qs.label), input(\type("number"), id(qs.id.name)));
		case boolean():  return div(label("<qs.label>"), input(\type("checkbox"), id(qs.id.name)));
	}
	return p("error");
}

HTML5Node computed2form(AQuestion qs) {
	switch(qs.typ) {
		case string(): return div(label(qs.label), input(\type("text"), disabled("disabled"), id(qs.id.name)));
		case integer(): return div(label(qs.label), input(\type("number"), disabled("disabled"), id(qs.id.name)));
		case boolean(): return div(label(qs.label), input(\type("checkbox"), disabled("disabled"), id(qs.id.name)));
	}
	return div("error");
}

str form2js(AForm f) {
  return "function run() {
  '	var $form = document.querySelector(\'form\');
  '	$form.addEventListener(\'change\', function() {
  '	<for(/c:computed(str label, AId id, AType typ, AExpr e) := f) {>
  '		<computed2js(c)> <}> 	
  ' 
  '		<hide2js(f.questions)>  
  '	});
  ' $form.dispatchEvent(new Event(\'change\'));
  '}";
}

str computed2js(AQuestion qs) {
	switch(qs.typ) {
		case string(): return "document.getElementById(\'<qs.id.name>\').value = <expr2js(qs.expr)>;";
		case integer(): return "document.getElementById(\'<qs.id.name>\').value = <expr2js(qs.expr)>;";
		case boolean(): return "document.getElementById(\'<qs.id.name>\').checked = String(<expr2js(qs.expr)>) == \'true\';";
	}
	return "";
}

str expr2js(AExpr e) {
  	switch (e) {
	    case ref(id(str x)): return "(document.getElementById(\'<x>\').checked ? true : document.getElementById(\'<x>\').value)";
	    case strConst(str s): return "<s>";
	    case intConst(int n): return "<n>";
	    case boolConst(bool b): return "<b>";    
		    
	    case not(AExpr expr): return "!<expr2js(expr)>;";
	    case multi(AExpr lhs, AExpr rhs): return "parseInt(<expr2js(lhs)>) * parseInt(<expr2js(rhs)>)";
	    case div(AExpr lhs, AExpr rhs): return "parseInt(<expr2js(lhs)>) / parseInt(<expr2js(rhs)>)";
	    case plus(AExpr lhs, AExpr rhs): return "parseInt(<expr2js(lhs)>) + parseInt(<expr2js(rhs)>)";
	    case min(AExpr lhs, AExpr rhs): return "parseInt(<expr2js(lhs)>) - parseInt(<expr2js(rhs)>)";
	    
	    case less(AExpr lhs, AExpr rhs): return "parseInt(<expr2js(lhs)>) \< parseInt(<expr2js(rhs)>)";
	    case leq(AExpr lhs, AExpr rhs): return "parseInt(<expr2js(lhs)>) \<= parseInt(<expr2js(rhs)>)";
	    case great(AExpr lhs, AExpr rhs): return "parseInt(<expr2js(lhs)>) \> parseInt(<expr2js(rhs)>)";
	    case geq(AExpr lhs, AExpr rhs):  return "parseInt(<expr2js(lhs)>) \>= parseInt(<expr2js(rhs)>)";
	    case neq(AExpr lhs, AExpr rhs): return "parseInt(<expr2js(lhs)>) != parseInt(<expr2js(rhs)>)";
	    case eql(AExpr lhs, AExpr rhs): return "parseInt(<expr2js(lhs)>) == parseInt(<expr2js(rhs)>)";
	    case and(AExpr lhs, AExpr rhs): return "(<expr2js(lhs)> == true) && (<expr2js(rhs)> == true)";
	    case or(AExpr lhs, AExpr rhs): return "(<expr2js(lhs)> == true) || (<expr2js(rhs)> == true)";
    }
	return "";
}

str hide2js(list[AQuestion] questions) {
	str js = "";
	
	for(AQuestion q <- questions) js += questionhide2js(q);

	return js;
}

str questionhide2js(AQuestion qs) {
	switch(qs) {
		case question(str label, AId id, AType typ): return "";
		case computed(str label, AId id, AType typ, AExpr expr): return "";
	}
	
	countJs += 1;
	switch(qs) {
		case ifblock(AExpr condition, list[AQuestion] questions): return "if(String(<expr2js(condition)>) == \'true\') {
		'		document.getElementById(\"If-Field-<toString(countJs)>\").style =\"visibility: show;display: inline;\"
		'	} else {
		'		document.getElementById(\"If-Field-<toString(countJs)>\").style =\"visibility: hidden;display: none;\"
		'	}
		" + hide2js(questions);
		
		case ifelseblock(AExpr condition, list[AQuestion] questions, list[AQuestion] questionsSec): return "if(String(<expr2js(condition)>) == \'true\') {
		'		document.getElementById(\"If-Field-<toString(countJs)>\").style =\"visibility: show;display: inline;\"
		'		document.getElementById(\"Else-Field-<toString(countJs)>\").style =\"visibility: hidden;display: none;\"
		'	} else {
		'		document.getElementById(\"Else-Field-<toString(countJs)>\").style =\"visibility: show;display: inline;\"
		'		document.getElementById(\"If-Field-<toString(countJs)>\").style =\"visibility: hidden;display: none;\"
		'	}
		" + hide2js(questions) + hide2js(questionsSec);
	}
	return "";
}
