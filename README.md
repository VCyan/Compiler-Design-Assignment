# Compiler Design Assigment

### Phase 0: Lexical Analyzer (Scanner)

 This part of the translator takes the input program, extracts and encodes the relevant information required for the rest of the translation process. You need to decide the representation of the tokens using regular expressions. Refer to the tiny-C language definition later on this document that describes the tokens of the language.

 A lexical generator (flex) is suggested for this section of your project. During the first month of the course, several examples on how to use flex will be given. This is the easiest part of the project and should be enough for you to make you comfortable with the development tools.

During this phase it is recommended that you also implement the symbol table management routines of your code. Use of dynamic data structures, such as hash tables, is required but you can use static tables to make this part of your project work. Full credit will be given at the end of the syntactical analyzer if you use dynamic data structures.

### Phase 1:  Syntactical Analyzer (Parser)

Based on the stream of tokens from the lexical analyzer and on the grammar of the language, the syntactical analyzer will decide if the input program is syntactically correct. The output of this stage should detect any errors found in the input program. Although error correction is preferred, you should focus your efforts on error detection first.

During the course a parser generator (bison) will be covered. Based on the grammar definition you should convert it to a format amenable to bison. This part of the project is more complicated if you decide to use error correction. Extra credit will be given if you use error correction.

 

### Phase 2 and 3.1: Semantic Analysis and Code generation

 In this course we will use syntax-oriented translation to generate intermediate code for the interpreter, thus the semantic analysis and code generation are done at the same time.

The semantic analysis is responsible for type checking and type conversion as well as checking for correct declaration of identifiers. This will require extensive symbol table management so make sure you have implemented your symbol table management routines before you start working on the semantic analysis.

The intermediate code generation is the most time-consuming part of the project so please don’t underestimate it. This part of the project will generate quadruples for each of the code segments analyzed so far. You can use back patching to generate correct jump addresses or you can generate an output file and then process the jump targets separately. The output file of this process should contain a list of valid quadruples, defined by you, and serve as input to the interpreter. The class notes propose a format for the quadruples, but feel free to modify them to suit your own needs.

 

### Phase 3.2: Interpreter

This is the final stage of your project. You must execute the output of the intermediate code generation in a pseudo virtual machine. This virtual machine must be capable of reading from the keyboard and displaying the information on the screen. Rudimentary memory management should also be implemented. 

This part of the project is not that complex and can be done in a short time, provided you fully understand what your quadruples do. Unfortunately in past projects this portion is rarely done because teams start the project late.

## Getting Started
Clone this repository and follow the instructions.

### Prerequisites
In order to compile this project you need preferto install the following dependencies: 
```
sudo apt-get update 
sudo apt-get upgrade 
sudo apt-get install flex bison
sudo apt-get install libgtk-3-dev
```

### How to Compile
To compile, run the script:

```
./Makefile.sh
```

or perform manually the actions inside the Makefile.sh

```
bison -d LexSyn.y
flex LexSyn.l
gcc -O2 -o LexSyn -DYACC LexSyn.tab.c `pkg-config --cflags --libs glib-2.0` -lfl
```

In order to run the program do:

```
./LexSyn < "input file name here"
```

Example:

```
./LexSyn < input.c
```


## Built With

* [Flex](https://www.gnu.org/software/flex/) and [Bison](https://www.gnu.org/software/bison/manual/html_node/index.html#SEC_Contents)
* [Glib](https://developer.gnome.org/glib/) - a utility library that can simplify programming in C, especially for projects involving the languages GNOME and GTK+

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## References & cool knowledge:

* This awesome README.md template is brought by you thanks to 
[PurpleBooth](https://github.com/PurpleBooth)

* [How to use a Hash Table with GLib](https://gist.github.com/bert/265933/a583fe4ec3e383499d86ea446c6db750412d611a) - **[Bert Timmerman](https://github.com/bert)**

* [Symbol Table in Compiler](https://www.geeksforgeeks.org/symbol-table-compiler/) - **Ankit87**

* [Compiler Design - Symbol Table](https://www.tutorialspoint.com/compiler_design/compiler_design_symbol_table.htm) - **tutorialspoint.com**
