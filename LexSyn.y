%{
#include <stdio.h>
#include <stdlib.h> 
#include "table.h"

// Declare stuff from Flex that Bison needs to know about:
extern int yylex();
extern int yyparse();
extern FILE *yyin;
// extern int line_num;
extern int yylineno;

/* Function definitions */
void yyerror(string input_Message);
%}

// Symbols.
%union {
	int ival;
	float fval;
	string sval;
  symtab_node_p symp;
}

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

// %type <fval> expression term factor
%type <ival> type
%type <fval> exp;
%type <fval> simple_exp;
%type <fval> term;
%type <fval> factor;
%type <symp> variable;

%right '='
%left '+' '-'
%left '*' '/'

%start program
/* beginning of rules section */
%%         
program:
	var_dec stmt_seq { printf("\nThe file is correct...\n"); }
	;
var_dec:
	var_dec single_dec
	| %empty /* epsilon */
	;
single_dec:
	type IDENTIFIER ';' {
		// 1. Create a new pointer
		symtab_node_p myNewSymbol = newSymbol($2);
		// 2. Set member num_type
		myNewSymbol->num_type = $1;
	}
	;
type:
	INTEGER { // You are an int if your type is 0;
		$$ = 1; // For testing purpose every type is a double ("float")
	}
	| FLOAT { // You are a float if your type is 1;
		$$ = 1;
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
		// if (!$1->num_type){
		// 		yyerror("Variable not declared: ");
		// 		exit(1);
		// } else {
		// 	$1->num_value.FLOAT_VALUE = $3;
		// }
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
		// $$ = $2;
	}
	;
simple_exp:
	simple_exp '+' term {
		// $$ = $1 + $3;
	}
	| simple_exp '-' term {
		// $$ = $1 - $3;
	}
	| term
	;
term:
	term '*' factor {
		// $$ = $1 * $3;
	}
	| term '/' factor {
		// if($3 == 0.0) yyerror("divide by zero");
		// else $$ = $1 / $3;
	}
	| factor {
		// $$ = $1;
	}
	;
factor:
	INTEGER_VALUE {
		$$ = $1;
	}
	| FLOAT_VALUE {
		$$ = $1;
	}
	| variable {
		// $$ = $1->num_value.FLOAT_VALUE;
	}
	;
variable:
	IDENTIFIER 	
	{
			$$ = symlook($1); /* This avoids the warning: type clash on default action: <symb> != <sval>*/
	}
	;
%%             /* beginning of subroutines section */

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
				exit(1);
		}
		yyin = file;
    fclose (file);	/* Close the input data file */
	}
	printf("Hash-Table creation: ");
	table = g_hash_table_new(g_str_hash, g_str_equal);
	// lex through the input:
	yyparse();
  printSymbolTable();
	exit(EXIT_SUCCESS);
}

void yyerror(string input_Message){
	fprintf(stderr, "Error: in line %d: %s\n:",  yylineno,/* line_num, */ input_Message);
	exit(-1);
}

symtab_node_p newSymbol(string symbol){
	// 1. Creation of a new pointer to node & malloc (size)
	symtab_node_p myNewSymbol = (symtab_node_p) malloc(sizeof(symbolTable_node));
	// 2. Set values and default ones.
	myNewSymbol->name_value = strdup(symbol);
	myNewSymbol->num_value.FLOAT_VALUE = 1;
	myNewSymbol->num_type = 1;
	// 3. Return pointer
	if (g_hash_table_insert(table, myNewSymbol->name_value, myNewSymbol)){
			return myNewSymbol;
	}else {
			printf("Error: at inserting to hash table");
			exit(1);
	}
}

symtab_node_p symlook(string symbol) {
	symtab_node_p table_ptr;
	string value, old_key, old_value;
	/* Try looking up this key. */
	symtab_entry_p res = g_hash_table_lookup(table, symbol);
    if (res == NULL){
        symtab_entry_p new_entry = malloc(sizeof(symtab_entry_));
        new_entry->name_value = strdup(symbol);
        new_entry->num_type = -1;
        return new_entry;
    }
    else {
        return res;
    }
} /* symlook */

/* Print Functions */
void printSymbolItem(gpointer key, gpointer value, gpointer user_data){
	// 1.  Get the node
	symtab_node_p aNode = (symtab_node_p) value;
	// 2. Print the values
	printf("%-10d %-10s %-10d \n",aNode->num_type,aNode->name_value,aNode->num_value.FLOAT_VALUE);
}

void printSymbolTable(){
    printf("### SYMBOL TABLE: \n");
    printf("%-10s %-10s %-10s \n","TYPE","NAME","VALUE");
    g_hash_table_foreach(table, (GHFunc)printSymbolItem, NULL);
}