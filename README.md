# Project Title

One Paragraph of project description goes here

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

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

	- Example:

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
