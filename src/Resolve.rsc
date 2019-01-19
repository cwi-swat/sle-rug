module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// A Definition is a Relational Set of tuples of (str) variableName and (loc) variableDefinitionLocation
// These are declarations of variables
alias Def = rel[str name, loc def];

// A Use is a Relational Set of tuples of (loc) variableUsageLocation and (str) variableName
// These are references to variables.
alias Use = rel[loc use, str name];

// A UseDef is a Relational Set of tuples of (loc) UseLocation of a variable and (loc) defining location of a variable
// In other words, a set of mappings from the referencing variable-locations to the defining variable-locations
alias UseDef = rel[loc use, loc def];

// Generate the UseDef by Relational Composition of the Use-set and the Defs-set
UseDef resolve(AForm f) = uses(f) o defs(f);

// Generate the Use set that maps reference-locations to the variable name
Use uses(AForm f) {
  Use locationQuestionNameSet = {};
  
  // Variable References in QL are only present in Abstract Expressions
  // the / operator stands for descendant, or deep-matching: 
  // http://tutor.rascal-mpl.org/Rascal/Expressions/Values/Tuple/Tuple.html#/Rascal/Patterns/Abstract/Descendant/Descendant.html
  for(/AExpr ex <- f.questions) {
    // We only want to add the location if the variable is an Identifier
    if(ex has name) {
      locationQuestionNameSet += { <ex.src, ex.name> };
    }
  }
  
  return locationQuestionNameSet; 
}

// Generate the Defs set that maps Variable-Names to the defining location
Def defs(AForm f) {
  Def defNameToLocation = {};

  // For each question in the form, add a mapping from q.name to its location
  // the / operator stands for descendant: 
  // http://tutor.rascal-mpl.org/Rascal/Expressions/Values/Tuple/Tuple.html#/Rascal/Patterns/Abstract/Descendant/Descendant.html
  for(/AQuestion q <- f.questions) {
    if(q has name) {
      defNameToLocation += { <q.name, q.src> };
    }  
  }
  
  return defNameToLocation; 
}