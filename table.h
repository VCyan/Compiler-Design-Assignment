/**
 * @file table.h
 * @author Victor Eduardo 
 * @brief  table.h declares the definitions used for the Symbol Table and 
 * the Glib library. See the Glib documentation at:
 * https://developer.gnome.org/glib/stable/glib-Hash-Tables.html
 *
 * @version 0.1
 * @date 2019-02-09
 * 
 * @copyright Copyright (c) 2019
 * 
 */
#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * @typedef string
 * 
 * @brief String definition as a char pointer (char *)
 * 
 */
typedef char * string;

/**
 * @brief Used to identify the value that a a variable will hold.
 * 
 */
union number_value
{
	int INTEGER_VALUE;
	double FLOAT_VALUE;
};

/**
 * @struct symtab
 *
 * @brief This is the basic node-defined element of the hash table
 *
 * The user-defined data structure is an @c int and a @c string. These
 * are used just to show how to implement user-defined structures.
 *
 */
struct symtab {
  string name_value;				/**< theString: The name of the variable, The name is just the string */
  union number_value num_value; /**< number_value: The value of the variable either int or float */ 
} symbolTable_node;

/**
 * @typedef symtab_node_p
 *
 * @brief Declares a pointer type of Symbol-Table-defined data structure
 *
 */
typedef struct symtab * symtab_node_p;  /**< Simplify declaration of ptr to node */

/**
 * @GHashTable
 * 
 * @brief The Hash Table structure to abstract the Symbol Table, this is automatically generated by Glib.h
 * 
 */
GHashTable *table = NULL;


symtab_node_p newSymbol(string s);

/**
@brief 
 * This function looks for a name in the symbol table, if it is
 * not there it store it in the next available space.
 * 
 * @param s : The key name to look in the symbol table
 * 
 * @return symtab_node_p : Pointer to the element in the hash table that matches the value.
 *  NULL if no match was found.
 */
symtab_node_p symlook(string s);

/**
 * @brief fdsfsdf fsd sf sd
 * df sdf sdf
 * 
 */
void printSymbolTable();
