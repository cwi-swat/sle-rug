# Software Engineering Language
This project shows the building of a DSL for questionnaires, called QL. QL allows you to define simple forms with conditions and computed value. The programming language of this project is Rascal.

## Example of QL
An example of how a questionnaire in QL looks like:
```
form taxOfficeExample { 
  "Did you sell a house in 2010?"
    hasSoldHouse: boolean
  "Did you buy a house in 2010?"
    hasBoughtHouse: boolean
  "Did you enter a loan?"
    hasMaintLoan: boolean
    
  if (hasSoldHouse) {
    "What was the selling price?"
      sellingPrice: integer
    "Private debts for the sold house:"
      privateDebt: integer
    "Value residue:"
      valueResidue: integer = 
        (sellingPrice - privateDebt)
  }
  
}
```

## Further explanation of the code

### Syntax
The class of the Concrete Syntax of QL (using Rascal's grammar formalism).

### AST
The class of the Abstract Syntax of QL.

### CST2AST
The class that converts Concrete syntax trees to abstract syntax trees of QL.

### Resolve
The class for the name resolution of QL.

### Check
The class that checks the questionnaires QL on the following: 
1. Declaring questions with the same name but different types.
2. Duplicate labels
3. The declared type computed questions should match the type of the expression.

### Eval
The class that evaluates the values of the Value Environment of a questionnaire.


### Compile
The class that compiles the questionnaire to an HTML file and it’s corresponding JavaScript file, that handles the actions of the HTML script.

It was recommended to use a checkbox for the Boolean prompts (questions), however
we decided to use a select box which we also saw in a given example. We preferred this look and it also gave an easy implementation of a default value. The user can choose `Yes`, `No` or `-` (default).
Therefore the if or else statement does not pop up immediately. For that the happen the user should click on the `Submit (form name)` button. 

The `Submit (form name)` button executes the function refresh() implemented in the JavaScript file, which preform the functions setValues() and  popUpExpression() , which updates the values of the prompts and  showing the sections with the question of the if or else statements respectively.


### Transform
The class that flattens the questionnaire QL form from this:
```
q0: "" int; 
if (a) { 
if (b) { 
q1: "" int; 
} 
q2: "" int; 
}
```
To this form:

```
if (true) q0: "" int;
if (true && a && b) q1: "" int;
if (true && a) q2: "" int;
```

And the class handles the rename refactoring.
