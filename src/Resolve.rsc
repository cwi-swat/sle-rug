module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

// the reference graph
alias UseDef = rel[loc use, loc def];

UseDef resolve(AForm f) = uses(f) o defs(f);

Use uses(AForm f) {
  // Use is a relational Set with tuples <reference location, question name>
  Use locationQuestionNameSet = {};
  
  // For each question REFERENCE, map it to its question name 
  // the / operator stands for descendant: 
  // http://tutor.rascal-mpl.org/Rascal/Expressions/Values/Tuple/Tuple.html#/Rascal/Patterns/Abstract/Descendant/Descendant.html
  for(/AExpr ex <- f.questions) {
    // Only add for the identifiers
    if(ex has name) {
      locationQuestionNameSet += { <ex.src, ex.name> };
    }
  }
  
  return locationQuestionNameSet; 
}

Def defs(AForm f) {

  // Def is a Set with tuples <question name, question location>
  Def defNameToLocation = {};

  // For each question in the form, add a mapping from q.name to its location
  // the / operator stands for descendant: 
  // http://tutor.rascal-mpl.org/Rascal/Expressions/Values/Tuple/Tuple.html#/Rascal/Patterns/Abstract/Descendant/Descendant.html
  for(/AQuestion q <- f.questions) {
    if(q has name) {
      defNameToLocation += { <q.name, q.src> };
    }  
  }
  
  // Return the relational set
  return defNameToLocation; 
}