%{
%}

%%
[0-9]+ |
([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?           { 
                                               #ifndef GRAMMAR
		                                        yylval.dval = atof(yytext);
                                               #endif
		                                       return NUMBER;
	                                          }

[ \t]	;		 /* ignore white space */

[A-Za-z][A-Za-z0-9]*	                    {	/* return symbol pointer */
                                            #ifndef GRAMMAR
		                                       yylval.symp = symlook(yytext);
                                            #endif
		                                       return NAME;
	                                        }
\n |
.	                                        return yytext[0];
