/* 
   Linguagem XYZ
*/

%{

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yydebug = 0;

/* Flex */
extern int yylineno;

extern int yyerror (char const *msg, ...);
extern int yylex();
%}

/* Declaracoes bison */
%union {
        int d;
        double f;
        char* s;
}

%token <d> I64
%token <f> F64
%token <s> IDENTIFIER
%token FUNCTION VAR LBRACES RBRACES LPARENTHESIS RPARENTHESIS
%token IF ELSE WHILE RETURN
%token PLUS MINUS MULTI DIV REST GREATHERTHAN LESSTHAN EQL EQG IS DIFF AND OR EQ DIFFERENT INCREMENT DECREMENT NOT
%token ';' ','

/* Gramática */
%%
function_declaration :
        FUNCTION IDENTIFIER LPARENTHESIS parameters_declaration RPARENTHESIS LBRACES statement RBRACES
        | FUNCTION IDENTIFIER LPARENTHESIS RPARENTHESIS LBRACES statement RBRACES
        ;

parameters_declaration :
        parameter_declaration
        | parameter_list_declaration
        ;

parameter_declaration :
        VAR IDENTIFIER
        ;

parameter_list_declaration :
        parameter_declaration ',' parameter_declaration
        | parameter_declaration ',' parameter_declaration ',' parameter_declaration            

function_call :
        FUNCTION IDENTIFIER LPARENTHESIS parameters_call RPARENTHESIS ';'
        | FUNCTION IDENTIFIER LPARENTHESIS RPARENTHESIS ';'
        ;

parameters_call:
        IDENTIFIER
        | IDENTIFIER ',' IDENTIFIER
        | IDENTIFIER ',' IDENTIFIER ',' IDENTIFIER
        ; 

statement :
        variable_declaration
        | expression
        | assignment
        | increment
        | decrement
        | return_statement
        | function_call
        | if_statement
        | loop
        ;       

variable_declaration :
        VAR IDENTIFIER ':' I64 '=' expression ';'
        | VAR IDENTIFIER ':' F64 '=' expression ';'
        ;

number :
        I64
        | F64
        ;

id : 
        IDENTIFIER
        ;        
              
expression :
        number
        | number '+' number ';'
        | number '-' number ';'
        | number '*' number ';'
        | number '/' number ';'
        | number '%' number ';'
        ;

assignment : 
       IDENTIFIER IS expression ';'
       ;

increment :
        IDENTIFIER INCREMENT ';'
        ;

decrement :
        IDENTIFIER DECREMENT ';'
        ;

return_statement :
        RETURN number
        | RETURN expression
        ;

if_statement : 
        IF LPARENTHESIS comparison RPARENTHESIS LBRACES statement RBRACES
        | IF LPARENTHESIS NOT comparison RPARENTHESIS LBRACES statement RBRACES
        | IF LPARENTHESIS comparison RPARENTHESIS LBRACES statement RBRACES ELSE LBRACES statement RBRACES
        | IF LPARENTHESIS NOT comparison RPARENTHESIS LBRACES statement RBRACES ELSE LBRACES statement RBRACES
        ;

comparison : 
        expression EQ expression
        | expression GREATERTHAN expression
        | expression EQG expression
        | expression LESSTHAN expression
        | expression EQL expression
        | expression DIFF expression
        | comparison AND comparison
        | comparison OR comparison
        ;

loop :
        WHILE LPARENTHESIS comparison RPARENTHESIS LBRACES statement RBRACES
        ;  

%%
#include "calc.yy.c"

int yyerror(const char *msg, ...) {
	va_list args;

	va_start(args, msg);
	vfprintf(stderr, msg, args);
	va_end(args);

	exit(EXIT_FAILURE);
}

int main (int argc, char **argv) {
    return  yyparse();

}