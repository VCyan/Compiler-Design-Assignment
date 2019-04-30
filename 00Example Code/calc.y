%{
#include "table.h"
#include <string.h>
#include <stdio.h>

  /* Function definitions */
void yyerror (string input);
%}

 /* Define the elements of the attribute stack */
%union {
  float dval;
  struct symtab *symp;
}
 /* NAME is used for identifier tokens */
 /* NUMBER is used or real numbers */
%token <symp> NAME
%token <dval> NUMBER

 /* To avoid ambiguities in the grammar assign associativity */
 /* and preference on the operators */
%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

 /* Specify the attribute for those non-terminal symbols of interest */
%type <dval> expression


%%
statement_list: statement '\n'       { /*Does nothing */}
    |   statement_list statement '\n'
    |   error { yyerror ("Error!"); }
    ;

statement:  NAME '=' expression       { $1->value = $3; }
    |   expression                    { printf("= %g\n", $1); }
    ;

expression: expression '+' expression { $$ = $1 + $3; }
    |   expression '-' expression     { $$ = $1 - $3; }
    |   expression '*' expression     { $$ = $1 * $3; }
    |   expression '/' expression     { if($3 == 0.0)
                                           yyerror("divide by zero");
                                        else
                                           $$ = $1 / $3;
                                      }
    |   '-' expression %prec UMINUS   { $$ = -$2; }
    |   '(' expression ')'            { $$ = $2; }
    |   NUMBER
    |   NAME                          { $$ = $1->value; }
    ;
%%

/* This is where the flex is included */
#include "lex.yy.c"

/* Bison does NOT implement yyerror, so define it here */
void yyerror (string input){
  printf ("%s",input);
}

/* This function looks for a name in the symbol table, if it is */
/* not there it store it in the next available space.           */
struct symtab *symlook(string s) {
    string p;
    struct symtab *sp;
    
    for(sp = symtab; sp < &symtab[NSYMS]; sp++) {
        /* is it already here? */
        if(sp->name && !strcmp(sp->name, s))
            return sp;
        
        /* is it free */
        if(!sp->name) {
            sp->name = strdup(s);
            return sp;
        }
        /* otherwise continue to next */
    }
    yyerror("Too many symbols");
    exit(1);    /* cannot continue */
} /* symlook */

/* Bison does NOT define the main entry point so define it here */
main (){
  yyparse();
}
