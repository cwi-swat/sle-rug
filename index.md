## Software Language Engineering

Software Language Engineering (SLE) is concerned with the principled techniques and concepts for the construction of software languages. Software languages come in many shapes and sizes, including programming languages, modeling languages, data format languages, specification languages etc. In this course you will get acquainted with the basic techniques and concepts of language engineering, and acquire the basic skills to define the syntax and semantics of software languages, as well as know the relevant tools and techniques for implementing various kinds of language processors. The course consists of a series of lectures based on the book on SLE by Ralf Lämmel. During the course you  will develop a simple domain-specific language (DSL) using the metaprogramming language Rascal, exercising both foundational and practical aspects of SLE. The final exam will test individual knowledge regarding the key concepts of SLE.


### General information

Contact: Tijs van der Storm [storm@cwi.nl](mailto:storm@cwi.nl)

This page: [https://cwi-swat.github.io/sle-rug/](https://cwi-swat.github.io/sle-rug/)

### Syllabus

Book: *Software Languages: Syntax, Semantics, and Metaprogramming*, by Ralf L&auml;mmel. The book is for sale here: [Springer](https://www.springer.com/gp/book/9783319907987), [Amazon](https://www.amazon.de/Software-Languages-Syntax-Semantics-Metaprogramming/dp/3319907980) *FREE E-book*: [https://rug.on.worldcat.org/oclc/1036771828](https://rug.on.worldcat.org/oclc/1036771828).

Detailed schedule: [rooster.rug.nl](http://rooster.rug.nl/?LayoutMode=Wide&nestorcode=WBCS18001.2018-2019)

- Week 1: Introduction (Chapters 1 & 2)
- Week 2: Concrete syntax (Chapters 6 & 7)
- Week 3: Abstract syntax (Chapters 3 & 4)
- Week 4: Checking (Chapter 9)
- Week 5: Interpretation (Chapters 5 & 8)
- Week 6: Code generation (Chapter 5)
- Week 7: Transformation (Chapters 5 & 12)
- Week 8: Wrap up & grading of lab starts

Exam: *Friday 25th of January*, 14:00-17:00

Re-examination: *Monday 25th of February*, 19:00–22:00

### Lab

Fork the [sle-rug](https://github.com/cwi-swat/sle-rug) repository, import the Eclipse project in the root directory, and see the provided modules in `src` for detailed instructions for the exercises from week 2 on. 

- Week 1: Install the *unstable* [Rascal Eclipse Plugin](https://www.rascal-mpl.org/start/); so use the following update URL [https://update.rascal-mpl.org/stable/](https://update.rascal-mpl.org/unstable/). Do the [Hack your Javascript](https://github.com/cwi-swat/hack-your-javascript) tutorial.
- Week 2: Concrete syntax of QL using Rascal's grammar formalism (module `Syntax`)
- Week 3: Abstract syntax and name analysis of QL (modules `AST`, `CST2AST` and `Resolve`)
- Week 4: Type checker for QL (module `Check`)
- Week 5: Interpreter for QL (module `Eval`)
- Week 6: Code generator compiling QL to executable HTML and Javascript (module `Compile`)
- Week 7: Normalization of QL and rename refactoring (module `Transform`)
- Week 8: Grading of lab starts



