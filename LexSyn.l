  /* Scanner for Tiny C TCC language */
%{
#include <stdlib.h>
#include <stdio.h>
#include "LexSyn.tab.h"  // to get the token types from Bison

int line_num = 0;

%}

INT	[1-9][0-9]*|[0]|0(c|C)[0-7]+|0(x|X)[0-9A-Fa-f]+
FLOAT	-?[0-9]*\.[0-9]+([eE][-+]?[0-9]+)?
ID	[A-Za-z_][A-Za-z0-9_]*

  /* This is the rule definition */
%%
{INT}+		{
			yylval.ival = atoi(yytext); return INTEGERVALUE;
		}

{FLOAT}*	{
            		yylval.fval = atof(yytext); return FLOATVALUE;
           	}
  /* Reserved words: */
int	{ return INTEGER; }
float	{ return FLOAT; }

if	{ return IF; }
then	{ return THEN; }
else	{ return ELSE; }
while	{ return WHILE; }
do	{ return DO; }
read	{ return READ; }
write	{ return WRITE; }
  /* printf( " TYPE: Reserved word;\tVALUE: %s\n", yytext );*/

{ID}	{
		// We have to strdup because we can't rely on yytext not changing underneath us:
    // yylval.symp = symlook(yytext);
    // yylval.str = yytext;
		yylval.sval = strdup(yytext);
		return IDENTIFIER;
	}

","|";"|"("|")"|"{"|"}"|"+"|"-"|"*"|"/"	{ return yytext[0]; }

"<"|">"|"="	{ return yytext[0]; }
"<="	{ return LOE; }
">="	{ return MOE; }
"!="	{ return DIFFERENT; }

":="   { return ASSIGN; }

\/\/.*$   //Do nothing // printf( " TYPE: Single Comment;\tVALUE: %s\n", yytext );

\/\*(((\*[^/])?)|[^*])*\*\/   //Do nothing // printf( " TYPE: Multiline Comment;\tVALUE: %s\n", yytext );

[\n]	{ ++line_num; }

[ \t\r\f]+          /* eat up whitespace */

.           printf( " Unrecognized character: %s\n", yytext );

%%