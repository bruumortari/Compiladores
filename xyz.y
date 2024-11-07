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

%token <d> INTEGER
%token <f> FLOAT
%token <s> IDENTIFIER
%token FUNCTION VAR LBRACES RBRACES LPARENTHESIS RPARENTHESIS
%token IF ELSE WHILE RETURN
%token PLUS MINUS MULTI DIV REST GREATHERTHAN LESSTHAN EQL EQG IS DIFF AND OR EQ DIFFERENT INCREMENT DECREMENT NOT
%token ';' ','

/* Gramática */
%%

function :
       function_start LPARENTHESIS parameters RPARENTHESIS LBRACES statements RBRACES end
       ;

function_start :
        FUNCTION id /* Para declarar a função */
        | id        /* Para chamar a função */
        ;

parameters :
        ε            /* Função sem parâmetros */     
        | id type
        | id type ',' id type
        | id type ',' id type ',' id type
        ;

type :
        ε
        | 'i64'
        | 'f64'
        ;        

end :
        ε           /* Criação de função */
        | ';'       /* Chamada de função */
        ;        

statements :
        variable_declaration
        | expression
        | assignment
        | increment
        | decrement
        | return_statement
        | function
        | if_statement
        | loop
        ;       

variable_declaration :
        VAR id ':' 'i64' '=' expression ';'
        | VAR id ':' 'f64' '=' expression ';'
        ;

number :
        INTEGER
        | FLOAT
        ;

id : 
        IDENTIFIER
        ;        
              
expression :
        number                    { $$ = $1; }
        | number '+' number ';'   { $$ = $1 + $3; }
        | number '-' number ';'   { $$ = $1 - $3; }
        | number '*' number ';'   { $$ = $1 * $3; }
        | number '/' number ';'   { $$ = $1 / $3; }
        | number '%' number ';'   { $$ = $1 % $3; }
        ;

assignment : 
       id IS expression ';'   { $$ = $3 }
       ;

increment :
        id INCREMENT ';'   { $$ = $1 + 1; }
        ;

decrement :
        id DECREMENT ';'   { $$ = $1 - 1; }
        ;

return_statement :
        RETURN number    { printf("Return: %d\n", $2); }
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