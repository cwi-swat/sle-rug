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
  writeFile(f.src[extension="html"].top, myToString(form2html(f)));
}

/**
  * Compile an Abstract Form to an HTML5Node
  */
HTML5Node form2html(AForm f) {
  return html(
    head(
      title("Simple Query Language"),
      script(src("https://cdn.jsdelivr.net/npm/vue"))
    ),
    body(
      div(id("app"),
        [question2html(q) | AQuestion q <- f.questions]
      )
    )
  );
}

/**
  * Compile an Abstract Question to a list of HTML5Nodes.
  * We use a list, because we can then return multiple HTML5Nodes, for example for the question block
  */
HTML5Node question2html(AQuestion q) {
  switch(q) {
    case question(str thequestion, str questionName, AType questionType):
      return div(
        label(\for("<questionName>"), thequestion),
        input(name(questionName), type2html(q.questionType))
      );
    case computed(str thequestion, str questionName, AType questionType, AExpr expression):
      return div(
        label(\for("<questionName>"), thequestion),
        input(name(questionName), type2html(q.questionType), readonly(""))
      );
    case block(list[AQuestion] qs):
      return div([question2html(q2) | AQuestion q2 <- qs]);
    case ifThenElse(AExpr ifCondition, AQuestion thenQuestion, AQuestion ElseQuestion):
      return 
        div(id(sourceLocationToIdentifier(ifCondition.src)), question2html(thenQuestion), question2html(ElseQuestion));
    case ifThen(AExpr ifCondition, AQuestion thenQuestion):
      return 
        div(id(sourceLocationToIdentifier(ifCondition.src)), question2html(thenQuestion));
  }
}

/*
 * Map the type of the expression to an HTML5 input type such as checkboxes, text-fields or integer inputs
 */
HTML5Attr type2html(boolean()) = \type("checkbox");
HTML5Attr type2html(string()) = \type("text");
HTML5Attr type2html(integer()) = \type("number");

/*
 * Abstract Expressions are not similar to Concrete Expressions.
 * Abstract Expressions are a tree, and we can therefore not use them directly in javascript and html
 * Instead, we create a mapping from the loc expression.src -> str htmlIdentifierOfExpression
 */
str sourceLocationToIdentifier(loc source)
  =  "expr-<source.offset>-<source.length>-<source.begin.line>-<source.begin.column>";


/**
  * We need to translate the entirety of the Query Language into a fully functional JS-Application
  * We will use VueJS to accomplish this
  */
str form2js(AForm f) {
  return "var app = new Vue({
         '  el: \'#app\',
         '  data: {
         '    <for (/AQuestion q := f) {>
         '    <if (q has name && !(q has expression)) {>
         '    <q.name>: <type2js(q.questionType)>,
         '    <}>
         '    <}>
         '  },
         '  computed: {
         '    // All computed questions
         '    <for (/AQuestion q := f) {>
         '    <if (q has name && q has expression) {>
         '    <q.name>:  function() {
         '      return <expr2js(q.expression)>;
         '    }
         '    <}>
         '    <}>
         '    // TODO: Hide or Show div elements based on the if-statement in the QL
         '  }
         '});
         ";
}

/**
  * Abstract Expressions should be compiled into javascript. Example: addition(AExpr a, AExpr b) -> expr2js(a) + expr2js(b)
  */
str expr2js(AExpr ex)
  = "";

str myToString(HTML5Node x) { 
  attrs = { k | HTML5Attr k <- x.kids };  
  kids = [ k | HTML5Node k <- x.kids ];  
  return nodeToString(x.name, attrs, kids); 
}

str type2js(boolean()) = "false";
str type2js(string()) = "\'\'";
str type2js(integer()) = "0";