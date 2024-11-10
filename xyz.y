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
        char* type;
}

%token <d> INTEGER
%token <f> FLOAT
%token <s> IDENTIFIER
%token <type> I64 F64
%token FUNCTION VAR LBRACES RBRACES LPARENTHESIS RPARENTHESIS
%token IF ELSE WHILE RETURN
%token PLUS MINUS MULTI DIV REST GREATHERTHAN LESSTHAN EQL EQG IS DIFF AND OR EQ DIFFERENT INCREMENT DECREMENT NOT
%token SEMICOLLON COMMA COLON

/* Gramática */
%%

program : function_list FUNCTION MAIN LPARENTHESIS RPARENTHESIS LBRACE variable_declaration_list statements_list RBRACE

function :
        FUNCTION id LPARENTHESIS parameters_list RPARENTHESIS LBRACES variable_declaration_list statements_list RBRACES
   	;

function_list : 
        ε
        | function_list function
        ;

function_call :
        id LPARENTHESIS parameters_list RPARENTHESIS SEMICOLLON

parameter :    
        ε
        | parameter id type COMMA
        ;

final_parameter:
        id type
        ;

parameters_list:
        ε
        | parameter final_parameter
        ;

id : 
        IDENTIFIER
        ; 

type :
        I64
        | F64
        ;    

number :
        INTEGER
        | FLOAT
        ;               

variable_declaration :
        VAR id COLON type IS expression SEMICOLLON
        | VAR id COLON type IS expression SEMICOLLON
        ;    

variable_declaration_list :
        ε
        | variable_declaration_list variable_declaration

statements :
        assignment 
        | increment 
        | decrement 
        | if_statement 
        | loop 
        | function_call
        | return_statement
        ; 

statements_list :
        ε
        | statements_list statement 

expression :
        number                                  { $$ = $1; }
        | id                                    { $$ = $1; }
        | number PLUS number                    { $$ = $1 + $3; }
        | number MINUS number                   { $$ = $1 - $3; }
        | number MULTI number                   { $$ = $1 * $3; }
        | number DIV number                     { $$ = $1 / $3; }
        | number REST number                    { $$ = $1 % $3; }
        | LPARENTHESIS expression RPARENTHESIS  { $$ = $2; }
        ;

bool_expression : /* alterei o nome: comparision */
        expression EQ expression
        | expression GREATERTHAN expression
        | expression EQG expression
        | expression LESSTHAN expression
        | expression EQL expression
        | expression DIFF expression
        | bool_expression AND bool_expression
        | bool_expression OR bool_expression
        | NOT bool_expression
        ;

assignment : 
       id IS expression SEMICOLLON              { $$ = $3 }
       | id IS function_call SEMICOLLON         { $$ = $3 }
       ;

increment :
        id INCREMENT SEMICOLLON   { $$ = $1 + 1; }
        ;

decrement :
        id DECREMENT SEMICOLLON   { $$ = $1 - 1; }
        ;

return_statement :
        RETURN number SEMICOLLON   { printf("Return: %d\n", $2); }
        ;

if_statement : 
        IF LPARENTHESIS bool_expression RPARENTHESIS LBRACES statements_list RBRACES
        | IF LPARENTHESIS bool_expression RPARENTHESIS LBRACES statements_list RBRACES ELSE LBRACES statements_list RBRACES
        ;

loop :
        WHILE LPARENTHESIS bool_expression RPARENTHESIS LBRACES statements_list RBRACES
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