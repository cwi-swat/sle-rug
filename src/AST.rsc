module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |unknown://|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |unknown://|);

data AExpr(loc src = |unknown://|)
  = ref(str name);


