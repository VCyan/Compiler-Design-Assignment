/*                                                              */
/*	   Header for the shared symbol table                       */
/*                                                              */

#define NSYMS 20	   /* Assume a maximum number of 20 symbols */

struct symtab {
  char *name;                    /* The name is just the string */
  float value;                          /* The value is a float */
} symtab[NSYMS];

typedef char * string;

/* Function prototype for the symbol table look up routine */
struct symtab *symlook(string);
