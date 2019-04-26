%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "table.h"
// An explanation more detailed about an Error if FLEX "Lexical Analyzer" found one.
#define YYERROR_VERBOSE

// Declare stuff from Flex that Bison needs to know about:
extern int yylex();
extern int yyparse();
extern FILE *yyin;
// extern int line_num;
extern int yylineno;

/* Function definitions */
void yyerrorCritical(char const * input_Message);
void yyerror(char const * input_Message);
void warning(char const * input_Message);

/* Constants */
char error_str[256];
char constant_str[30]; // As it is a toy, I will keep number constants with a length of 30.
bool boolean_use = false;
%}

// Symbols.
%union {
	int ival;
	float fval;
	string sval;
  symtab_node_p symp;
}
// %token of Terminals
%token <sval> IDENTIFIER
%token <ival> INTEGER_VALUE
%token <fval> FLOAT_VALUE

%token INTEGER
%token FLOAT
%token IF
%token THEN
%token ELSE
%token WHILE
%token DO
%token READ
%token WRITE

%token ASSIGN

%token LOE
%token MOE
%token DIFFERENT

// %type of Non-Terminals
%type <ival> type
%type <symp> exp;
%type <symp> simple_exp;
%type <symp> term;
%type <symp> factor;
%type <symp> variable;

// %right '='
// %left '+' '-'
// %left '*' '/'

%start program
/* beginning of rules section */
%%         
program:
	var_dec stmt_seq { /* printf("\n\t%-10s\n", "### The FILE is correct..."); */ }
	;
var_dec:
	var_dec single_dec
	| %empty /* epsilon */
	;
single_dec:
	type IDENTIFIER ';' {
		// 1. Create a new symbol pointer in Symbol Table
		symtab_node_p myNewSymbol = newSymbol($2);
		// 2. Set member num_type, either TYPE_INTEGER or TYPE_FLOAT
		myNewSymbol->num_type = $1;
	}
	;
type:
	INTEGER { // You are an int if your type is 0 = TYPE_INTEGER;
		$$ = TYPE_INTEGER;
	}
	| FLOAT { // You are a float if your type is 1 = TYPE_FLOAT;
		$$ = TYPE_FLOAT;
	}
	;
stmt_seq:  
	stmt_seq stmt
	| %empty /* epsilon */
	;
stmt:
	IF exp THEN stmt
	| IF exp THEN stmt ELSE stmt
	| WHILE exp DO stmt
	| variable ASSIGN simple_exp ';' {/* Edited */
		// if type is NULL, you haven't declared the variable
		if ($1->num_type == TYPE_EMPTY) {
			sprintf(error_str, "Variable not declared: %s", $1->name_value);
			yyerrorCritical(error_str);
		} else {
			// $1->num_value.FLOAT_VALUE_SAVED = $3;
			// gen();
			// boolean_use = conversionTest($1, $3);
			conversionTest($1, $3);
			// if(boolean_use) {
			// 	$1->num_value.FLOAT_VALUE_SAVED = $3;
			// }
		}
	}
	| READ '(' variable ')' ';'
	| WRITE '(' exp ')' ';'
	| block
	;
block:  '{' stmt_seq '}'
	;
exp:
	simple_exp '>' simple_exp 
	| simple_exp '<' simple_exp
	| simple_exp '=' simple_exp
	| '(' exp ')' {
		/* Added so (simple_exp) */
		$$ = $2;
	}
	;
simple_exp:
	simple_exp '+' term {
		// $$ = $1 + $3;
		symtab_node_p myNewConstant = (symtab_node_p) malloc(sizeof(symbolTable_node));
		equivalenceTest(OP_SUM, $1, $3, myNewConstant);
		$$ = myNewConstant;
	}
	| simple_exp '-' term {
		// $$ = $1 - $3;
		symtab_node_p myNewConstant = (symtab_node_p) malloc(sizeof(symbolTable_node));
		equivalenceTest(OP_SUB, $1, $3, myNewConstant);
		$$ = myNewConstant;
	}
	| term
	;
term:
	term '*' factor {
		// $$ = $1 * $3;
		// 1. Create a new symbol pointer
		symtab_node_p myNewConstant = (symtab_node_p) malloc(sizeof(symbolTable_node));
		// 2. Declare type based on previous Expressions
		equivalenceTest(OP_MUL, $1, $3, myNewConstant);
		$$ = myNewConstant;
	}
	| term '/' factor {
		// if($3->num_value.INT == (0.0)||(0)) yyerror("Division by zero");
		if(0){} // Expecting to implement the above comment
		else {
			// $$ = $1 / $3;
			// 1. Create a new symbol pointer
			symtab_node_p myNewConstant = (symtab_node_p) malloc(sizeof(symbolTable_node));
			// 2. Declare type based on previous Expressions
			equivalenceTest(OP_DIV, $1, $3, myNewConstant);
			// 3. Perform operation
			// myNewConstant->num_value.FLOAT_VALUE_SAVED = $1->num_value.FLOAT_VALUE_SAVED / $3->num_value;
			$$ = myNewConstant;
		}
	}
	| factor {
		$$ = $1;
		/* if($1->num_type == TYPE_INTEGER){
		sprintf(constant_str, "%d", $1->num_value.INTEGER_VALUE_SAVED);
		printf("Factor: %s\n",constant_str);
		} else {
		sprintf(constant_str, "%f", $1->num_value.FLOAT_VALUE_SAVED);
		printf("Factor: %s\n",constant_str);
		} */
	}
	;
factor:
	INTEGER_VALUE {
		// $$ = $1;
		/* sprintf(constant_str, "%d", $1);
		printf("%s\n",constant_str); */
		// 1. Create a new constant pointer in Symbol Table
		symtab_node_p myNewConstant = lookSymbol(constant_str);
		// 2. Set member num_type
		myNewConstant->num_type = TYPE_INTEGER;
		// 3. Set member number value
		myNewConstant->num_value.INTEGER_VALUE_SAVED = $1;
		// 4. Return pointer
		$$ = myNewConstant;
	}
	| FLOAT_VALUE { // printf("FLOAT VALUE: %f",$1);
		// $$ = $1;
		/* sprintf(constant_str, "%f", $1);
		printf("%s\n",constant_str); */
		symtab_node_p myNewConstant = lookSymbol(constant_str);
		myNewConstant->num_type = TYPE_FLOAT;
		myNewConstant->num_value.FLOAT_VALUE_SAVED = $1;
		$$ = myNewConstant;
	}
	| variable {
		// $$ = $1->num_value.FLOAT_VALUE_SAVED;
		$$ = $1;
	}
	;
variable:
	IDENTIFIER 	
	{
		$$ = lookSymbol($1); /* This avoids the warning: type clash on default action: <symb> != <sval>*/
	}
	;
%%
/* beginning of subroutines section */

/* This is where the flex is included */
#include "lex.yy.c"

/*************************************************************************
 *                           Main entry point                            *
 *************************************************************************/
int main(int argc, char** argv){
	FILE   *file;                                      // Pointer to the file
	// GHashTable *table = NULL;           // Used to test the list operations
	// GList * item_p = NULL;                    // Used in the find operation
	// node_p  aNode_p;                       // Pointer to a node in the list
	// int     nodeValue;         // Test integer for arbitrary integer search

	if (argc > 1)	{
		file = fopen(argv[1], "r");
		if (!file)
		{
				fprintf(stderr, "Could not open %s\n", argv[1]);
				exit(EXIT_FAILURE);
		}
		yyin = file;
    fclose (file);	/* Close the input data file */
	}
	// printf("Hash-Table creation: ");
	table = g_hash_table_new(g_str_hash, g_str_equal);
	// lex through the input:
	yyparse();
  printSymbolTable();

	exit(EXIT_SUCCESS);
}

/* Error & Warning Functions */
/**
 * @brief Critical error. This function will print a minor error found and will STOP the compilation.
 * 
 * @param input_Message 
 */
void yyerrorCritical(char const * input_Message){
	// yylineno++;
	fprintf(stderr, "CRITICAL ERROR: in line %d: %s\n", yylineno,/* line_num, */ input_Message);
	printf("Stopping Compilation\n");
	exit(EXIT_FAILURE);
}
/**
 * @brief Minor error. This function will print a minor error found and will CONTINUE the compilation.
 * 
 * @param input_Message change commit
 */
void yyerror(char const * input_Message){
	fprintf(stderr, "ERROR: in line %d: %s\n", yylineno, input_Message);
}

void warning(char const * input_Message){
	fprintf(stderr, "WARNING: in line %d: %s\n", yylineno, input_Message);
}

symtab_node_p newSymbol(string symbolKey){
	// 1. Creation of a new pointer to node & malloc (size)
	symtab_node_p myNewSymbol = (symtab_node_p) malloc(sizeof(symbolTable_node));
	// 2. Set values and default ones.
	myNewSymbol->name_value = g_strdup(symbolKey);
	// myNewSymbol->num_value.FLOAT_VALUE = -1;
	// myNewSymbol->num_type = -1;
	// 3. Return pointer
	if (g_hash_table_insert(table, myNewSymbol->name_value, myNewSymbol)){
			return myNewSymbol;
	}else {
			yyerrorCritical("Something destroy the Hash Table?");
	}
} /* newSymbol */

symtab_node_p lookSymbol(string symbolKey) {
	/* Try looking up this key. */
	symtab_node_p mySymbol = g_hash_table_lookup(table, symbolKey);
    if (mySymbol != NULL){ /* if symbolKey is not NULL  */
      /* then it was found in Symbol Table */
			return mySymbol;
    }
    else { /* else */
			// 1. Create a new symbol pointer 
			symtab_node_p myNewSymbol = (symtab_node_p) malloc(sizeof(symbolTable_node));
				myNewSymbol->name_value = strdup(symbolKey);
				myNewSymbol->num_type = TYPE_EMPTY; // like -1 = empty
			return myNewSymbol;
    }
} /* lookSymbol */

/* Print Functions */

void printSymbolItem(gpointer key, gpointer value, gpointer user_data){
	// 1.  Get the node
	symtab_node_p aNode = (symtab_node_p) value;
	// 2. Print the values
	if(aNode->num_type == TYPE_INTEGER)	printf("\t%-10s %-10s %-10d\n","int",aNode->name_value,aNode->num_value.INTEGER_VALUE_SAVED);
	else printf("\t%-10s %-10s %-10.2f\n","float",aNode->name_value,aNode->num_value.FLOAT_VALUE_SAVED);
	return; 
}/* printSymbolItem */

void printSymbolTable(){
	printf("\n\t####### SYMBOL TABLE #######\n");
	printf("\t%-10s %-10s %-10s \n","TYPE","NAME","VALUE");
	g_hash_table_foreach(table, (GHFunc)printSymbolItem, NULL);
	return;
}/* printSymbolTable */



/* Operation Functions*/

void conversionTest(symtab_node_p arg1, symtab_node_p arg2){
	// if variable's type is INTEGER AND constant's type is FLOAT
	if ((arg1->num_type == TYPE_INTEGER) && (arg2->num_type == TYPE_INTEGER)){
			arg1->num_value.INTEGER_VALUE_SAVED = arg2->num_value.INTEGER_VALUE_SAVED;
			// return true;
	} else if((arg1->num_type == TYPE_FLOAT) && (arg2->num_type == TYPE_INTEGER)){
			sprintf(error_str, "Implicit Type Coercion: Assigment makes float from integer: At float %s with the int assigment value of %d", arg1->name_value, arg2->num_value.INTEGER_VALUE_SAVED);
			warning(error_str);
			arg1->num_value.FLOAT_VALUE_SAVED = (float)arg2->num_value.INTEGER_VALUE_SAVED;
			// return false;
	} else if((arg1->num_type == TYPE_INTEGER) && (arg2->num_type == TYPE_FLOAT)){
			sprintf(error_str, "Implicit Type Coercion: Assigment makes integer from float: At int %s with the float assigment value of %.2f", arg1->name_value, arg2->num_value.FLOAT_VALUE_SAVED);
			yyerror(error_str);
			arg1->num_value.INTEGER_VALUE_SAVED = (int)arg2->num_value.FLOAT_VALUE_SAVED;
			// return false;
	} else if((arg1->num_type == TYPE_FLOAT) && (arg2->num_type == TYPE_FLOAT)) {
			arg1->num_value.FLOAT_VALUE_SAVED = arg2->num_value.FLOAT_VALUE_SAVED;
			// return true;
	} else {
		yyerrorCritical("A shit assigment...");
	}
	return;
}

void equivalenceTest(int op, symtab_node_p arg1, symtab_node_p arg2, symtab_node_p result){
	if ((arg1->num_type == TYPE_INTEGER) && (arg2->num_type == TYPE_INTEGER)){
		result->num_type = TYPE_INTEGER;
		switch (op) {
			case OP_SUM:
				result->num_value.INTEGER_VALUE_SAVED = arg1->num_value.INTEGER_VALUE_SAVED + arg2->num_value.INTEGER_VALUE_SAVED;
				break;
			case OP_SUB:
				result->num_value.INTEGER_VALUE_SAVED = arg1->num_value.INTEGER_VALUE_SAVED - arg2->num_value.INTEGER_VALUE_SAVED;
				break;
			case OP_MUL:
				result->num_value.INTEGER_VALUE_SAVED = arg1->num_value.INTEGER_VALUE_SAVED * arg2->num_value.INTEGER_VALUE_SAVED;
				break;
			case OP_DIV:
				if(arg2->num_value.INTEGER_VALUE_SAVED == 0) {
				 warning("Division by zero");
				} else result->num_value.INTEGER_VALUE_SAVED = arg1->num_value.INTEGER_VALUE_SAVED / arg2->num_value.INTEGER_VALUE_SAVED;
				break;

			default:
				yyerrorCritical("Integer x Integer failed ?");
				break;
		}
	}	else if ((arg1->num_type == TYPE_INTEGER) && (arg2->num_type == TYPE_FLOAT)){
		warning("Implicit Type Coercion: Operation between integer and float will result in float");
		result->num_type = TYPE_FLOAT;
		switch (op) {
			case OP_SUM:
				result->num_value.FLOAT_VALUE_SAVED = (float)arg1->num_value.INTEGER_VALUE_SAVED + arg2->num_value.FLOAT_VALUE_SAVED;
				break;
			case OP_SUB:
				result->num_value.FLOAT_VALUE_SAVED = (float)arg1->num_value.INTEGER_VALUE_SAVED - arg2->num_value.FLOAT_VALUE_SAVED;
				break;
			case OP_MUL:
				result->num_value.FLOAT_VALUE_SAVED = (float)arg1->num_value.INTEGER_VALUE_SAVED * arg2->num_value.FLOAT_VALUE_SAVED;
				break;
			case OP_DIV:
				if(arg2->num_value.FLOAT_VALUE_SAVED == 0.0) {
				 warning("Division by zero");
				} else result->num_value.FLOAT_VALUE_SAVED = (float)arg1->num_value.INTEGER_VALUE_SAVED / arg2->num_value.FLOAT_VALUE_SAVED;
				break;

			default:
				yyerrorCritical("Integer x Float failed ?");
				break;
		}
	}	else if ((arg1->num_type == TYPE_FLOAT) && (arg2->num_type == TYPE_INTEGER)){
		result->num_type = TYPE_FLOAT;		
		warning("Implicit Type Coercion: Operation between float and integer will result in float");
		switch (op) {
			case OP_SUM:
				result->num_value.FLOAT_VALUE_SAVED = arg1->num_value.FLOAT_VALUE_SAVED + (float)arg2->num_value.INTEGER_VALUE_SAVED;
				break;
			case OP_SUB:
				result->num_value.FLOAT_VALUE_SAVED = arg1->num_value.FLOAT_VALUE_SAVED - (float)arg2->num_value.INTEGER_VALUE_SAVED;
				break;
			case OP_MUL:
				result->num_value.FLOAT_VALUE_SAVED = arg1->num_value.FLOAT_VALUE_SAVED * (float)arg2->num_value.INTEGER_VALUE_SAVED;
				break;
			case OP_DIV:
				if(arg2->num_value.INTEGER_VALUE_SAVED == 0) {
				 warning("Division by zero");
				} else result->num_value.FLOAT_VALUE_SAVED = arg1->num_value.FLOAT_VALUE_SAVED / (float)arg2->num_value.INTEGER_VALUE_SAVED;
				break;

			default:
				yyerrorCritical("Float x Integer failed ?");
				break;
		}
	}	else if ((arg1->num_type == TYPE_FLOAT) && (arg2->num_type == TYPE_FLOAT)){
		result->num_type = TYPE_FLOAT;
		switch (op) {
			case OP_SUM:
				result->num_value.FLOAT_VALUE_SAVED = arg1->num_value.FLOAT_VALUE_SAVED + arg2->num_value.FLOAT_VALUE_SAVED;
				break;
			case OP_SUB:
				result->num_value.FLOAT_VALUE_SAVED = arg1->num_value.FLOAT_VALUE_SAVED - arg2->num_value.FLOAT_VALUE_SAVED;
				break;
			case OP_MUL:
				result->num_value.FLOAT_VALUE_SAVED = arg1->num_value.FLOAT_VALUE_SAVED * arg2->num_value.FLOAT_VALUE_SAVED;
				break;
			case OP_DIV:
				if(arg2->num_value.FLOAT_VALUE_SAVED == 0.0) {
				 warning("Division by zero");
				} else result->num_value.FLOAT_VALUE_SAVED = arg1->num_value.FLOAT_VALUE_SAVED / arg2->num_value.FLOAT_VALUE_SAVED;
				break;
			default:
				yyerrorCritical("Integer x Float failed ?");
				break;
		}
	} else {
		yyerrorCritical("A shit number");
	}
	return;
}/* equivalenceTest */