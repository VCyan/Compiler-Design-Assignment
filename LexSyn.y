%{
#include <stdio.h>
#include <stdlib.h> 
// Declare stuff from Flex that Bison needs to know about:
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int line_num;

void yyerror(const char *s);
%}

// Symbols.
%union {
	int ival;
	float fval;
	char *sval;
}

%token <ival> INTEGERVALUE
%token <fval> FLOATVALUE
%token <sval> IDENTIFIER

 /* Specify the attribute for those non-terminal symbols of interest */
// %type <fval> expression term factor

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

// %right '='
%left '+' '-'
%left '*' '/'

%start program
/* beginning of rules section */
%%         
program:  
	var_dec stmt_seq
	;
var_dec:
	var_dec single_dec  
	| /* epsilon */
	;
single_dec:  
	type IDENTIFIER ';'
	;
type:
	INTEGER
	| FLOAT
	;
stmt_seq:  
	stmt_seq stmt
	| /* epsilon */
	;
stmt:
	IF exp THEN stmt
	| IF exp THEN stmt ELSE stmt
	| WHILE exp DO stmt
	| variable ASSIGN simple_exp ';'
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
	| '(' exp ')'
	;
simple_exp:
	simple_exp '+' term 
	| simple_exp '-' term 
	| term
	;
term:
	term '*' factor  
	| term '/' factor
	| factor
	;
factor:
	| INTEGERVALUE
	| FLOATVALUE
	| variable
	;
variable:
	IDENTIFIER
	;
%%             /* beginning of subroutines section */

/* This is where the flex is included */
#include "lex.yy.c"

void yyerror(const char *s)
{
fprintf(stderr, "line %d: %s\n:", line_num, s);
exit(-1);
}
  /* This is the main program */
int main(argc, argv)
int argc;
char** argv;
{
if (argc > 1)
{
		FILE *file;
		file = fopen(argv[1], "r");
		if (!file)
		{
				fprintf(stderr, "Could not open %s\n", argv[1]);
				exit(1);
		}
		yyin = file;
}

	// lex through the input:
	yyparse();
	printf( "The file is correct...\n");

exit(0);
}
