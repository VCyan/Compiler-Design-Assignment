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
%type <symp> exp;
%type <symp> simple_exp;
%type <symp> term;
%type <symp> factor;
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
		if (!$1->num_type){
				yyerror("Variable not declared: ");
				exit(1);
		} /* else {
		} */
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
		$$ = $1 + $3;
	}
	| simple_exp '-' term {
		$$ = $1 - $3;
	}
	| term
	;
term:
	term '*' factor {
		$$ = $1 * $3;
	}
	| term '/' factor {
		if($3 == 0.0) yyerror("divide by zero");
		else $$ = $1 / $3;
	}
	| factor {
		$$ = $1;
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
		$$ = $1->num_value;
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
	
	table = g_hash_table_new(g_str_hash, g_str_equal);
	// lex through the input:
	yyparse();
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
	myNewSymbol->num_value.INTEGER_VALUE = NULL;
	myNewSymbol->num_type = NULL;
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
	// if (g_hash_table_lookup_extended (table, symbol, &old_key, &old_value))
	// {
	// 		/* Insert the new value */
	// 		g_hash_table_insert (table, g_strdup (symbol), g_strdup (value));
	// 		/* Just free the key and value */
	// 		g_free (old_key);
	// 		g_free (old_value);
	// }
	// else
	// {
	// 		/* Insert into our hash table it is not a duplicate. */
	// 		g_hash_table_insert (table, g_strdup (symbol), g_strdup (value));
	// }
} /* symlook */

/* Print Functions */
void printSymbolItem(gpointer key, gpointer value, gpointer user_data){
// int PrintItem (const void *data_p){
// 	//aNode_p = myList_p->data;
// 	//printf("%d %s\n",aNode_p->number, aNode_p->theString);
// 	//myList_p = myList_p->next;
// 	node_p aNode_p = (node_p) data_p;
// 	printf("%d %s\n",aNode_p->number, aNode_p->theString);
	
	symtab_node_p item = (symtab_node_p) value;
    //printf("%s -> %s -> %f\n",item->name, printType(item->type), item->value);
    // printf("%5s  %10s\n",item->name, printType(item->type));
}

void printSymbolTable(){
    printf("\nSymbol Table: \n");
    printf("%-15s %-15s %-15s \n","Address","Name","Value");

    g_hash_table_foreach(table, (GHFunc)printSymbolItem, NULL);
}