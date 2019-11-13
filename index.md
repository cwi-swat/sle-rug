## Software Language Engineering

Software Language Engineering (SLE) is concerned with the principled techniques and concepts for the construction of software languages. Software languages come in many shapes and sizes, including programming languages, modeling languages, data format languages, specification languages etc. In this course you will get acquainted with the basic techniques and concepts of language engineering, and acquire the basic skills to define the syntax and semantics of software languages, as well as know the relevant tools and techniques for implementing various kinds of language processors. The course consists of a series of lectures based on the book on SLE by Ralf Lämmel. During the course you  will develop a simple domain-specific language (DSL) using the metaprogramming language Rascal, exercising both foundational and practical aspects of SLE. The final exam will test individual knowledge regarding the key concepts of SLE.


### General information

Contact: Tijs van der Storm [storm@cwi.nl](mailto:storm@cwi.nl)

This page: [https://cwi-swat.github.io/sle-rug/](https://cwi-swat.github.io/sle-rug/)

### Syllabus

Book: *Software Languages: Syntax, Semantics, and Metaprogramming*, by Ralf L&auml;mmel. The book is for sale here: [Springer](https://www.springer.com/gp/book/9783319907987), [Amazon](https://www.amazon.de/Software-Languages-Syntax-Semantics-Metaprogramming/dp/3319907980) *FREE E-book*: [https://rug.on.worldcat.org/oclc/1036771828](https://rug.on.worldcat.org/oclc/1036771828).

Detailed schedule: [rooster.rug.nl](https://rooster.rug.nl/#/nl/2019-2020/course/WBCS18001/timeRange=all)

- Week 1: Introduction (Chapters 1 & 2)
- Week 2: Concrete syntax (Chapters 6 & 7)
- Week 3: Abstract syntax (Chapters 3 & 4)
- Week 4: Checking (Chapter 9)
- Week 5: Interpretation (Chapters 5 & 8)
- Week 6: Code generation (Chapter 5)
- Week 7: Transformation (Chapters 5 & 12)
- Week 8: Wrap up & grading of lab starts


### Lab

Fork the [sle-rug](https://github.com/cwi-swat/sle-rug) repository, import the Eclipse project in the root directory, and see the provided modules in `src` for detailed instructions for the exercises from week 2 on. 



- Week 1: Install the *unstable* [Rascal Eclipse Plugin](https://www.rascal-mpl.org/start/); so use the following update URL [https://update.rascal-mpl.org/unstable/](https://update.rascal-mpl.org/unstable/). Do the [Rascal Introduction Tutorial](https://github.com/cwi-swat/rascal-wax-on-wax-off).
- Week 2: Concrete syntax of QL using Rascal's grammar formalism (module `Syntax`)
- Week 3: Abstract syntax and name analysis of QL (modules `AST`, `CST2AST` and `Resolve`)
- Week 4: Type checker for QL (module `Check`)
- Week 5: Interpreter for QL (module `Eval`)
- Week 6: Code generator compiling QL to executable HTML and Javascript (module `Compile`)
- Week 7: Normalization of QL and rename refactoring (module `Transform`)
- Week 8: Grading of lab starts

## QL

The lab assignment is based on the Language Workbench Challenge 2013. The goal of the assignment is to build a DSL for questionnaires, called QL. QL allows you to define simple forms with conditions and computed values.

Here is some more detail:

- The QL syntax consists of a form, containing questions. A question can be a normal question, or a computed question. A computed question has an associated expression which defines its value. Both kinds of questions have a label (to show to the user), an identifier, and a type. The conditional construct comes in two variants `if` and `if-else`. A block construct using `{}` can be used to group questions. 

- Questions are enabled and disabled when different values are
  entered, depending on their conditional context.
  
- The type checker detects:
   * reference to undefined questions
   * duplicate question declarations with different types
   * conditions that are not of the type boolean
   * operands of invalid type to operators
   * duplicate labels (warning)

- The language supports booleans, integers and string types .

- Different data types in QL map to different (default) GUI widgets.   

Here's a simple questionnaire in QL from the domain of tax filing:

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

