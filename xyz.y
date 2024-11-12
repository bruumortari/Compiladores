/* 
   Linguagem XYZ
*/

%{

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yydebug = 0;

/* Tabela de Símbolos */
#define MAX_SYMBOLS 100

struct Symbol {
    char* function; // função a qual pertence a variável
    char* name;  // nome da variável 
    char* type;  // tipo da variável
} Symbol;

Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;
int functionSymbomCount = 0;

void addSymbol(char* name, char* type) {
    if (symbolCount >= MAX_SYMBOLS) {
        printf("Erro: A tabela de símbolos está cheia.\n");
        return;
    }
    symbolTable[symbolCount].name = name;
    symbolTable[symbolCount].type = type;
    symbolCount++;
}

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
%token <d> IDENTIFIER
%token <type> I64 F64
%token FUNCTION MAIN VAR LBRACE RBRACE LPARENTHESIS RPARENTHESIS
%token IF ELSE WHILE RETURN
%token PLUS MINUS MULTI DIV REST GREATERTHAN LESSTHAN EQL EQG IS DIFF AND OR EQ DIFFERENT INCREMENT DECREMENT NOT
%token SEMICOLON COMMA COLON

%type <d> integer_number assignment increment decrement return_statement function_call id
%type <f> float_number expression

/* Lista de precedência */
%right INCREMENT DECREMENT
%right NOT
%left MULTI DIV REST
%left PLUS MINUS
%nonassoc GREATERTHAN LESSTHAN EQL EQG DIFF
%nonassoc EQ DIFFERENT
%right IS
%left AND OR

/* Gramática */
%%

program : function_list FUNCTION MAIN LPARENTHESIS RPARENTHESIS LBRACE variable_declaration_list statements_list RBRACE
        {
                for (int i = index; i < symbol_count; i++) {
                        symbolTable[i].function = "main";
                }
        }

function :
        FUNCTION id LPARENTHESIS parameters_list RPARENTHESIS LBRACE variable_declaration_list statements_list RBRACE 
        {
                
                for (int i = index; i < symbol_count; i++) {
                        symbolTable[i].function = $2;
                }
        }
   	; 

epsilon :
        ;        

function_list : 
        epsilon
        | function_list function 
        ;

function_call :
        id LPARENTHESIS parameters_list RPARENTHESIS SEMICOLON

parameter :    
        epsilon
        | parameter id type COMMA       { addSymbol($2, $3); }
        ;

final_parameter:
        id type         { addSymbol($2, $3); }
        ;

parameters_list:
        epsilon
        | parameter final_parameter
        ;

id : 
        IDENTIFIER
        ; 

type :
        I64
        | F64
        ;    

integer_number :
        INTEGER
        ;

float_number :
        FLOAT
        ;                                    

variable :
        epsilon
        | id COLON type IS expression COMMA variable    { addSymbol($1, $3); } 
        ;

final_variable :
        id COLON type IS expression SEMICOLLON          { addSymbol($1, $3); } 
        ;

variable_list :
        epsilon
        | variable final_variable
        ;

variables_declaration :
        epsilon
        | VAR variable_list 
        ;    

statement :
        assignment 
        | increment 
        | decrement 
        | if_statement 
        | loop 
        | function_call
        | return_statement
        ; 

statements_list :
        epsilon
        | statements_list statement
        ;

expression :
        integer_number                          { $$ = $1; }
        | float_number                          { $$ = $1; }
        | id                                    { $$ = $1; }
        | expression PLUS expression            { $$ = $1 + $3; }
        | expression MINUS expression           { $$ = $1 - $3; }
        | expression MULTI expression           { $$ = $1 * $3; }
        | expression DIV expression             { $$ = $1 / $3; }
        | expression REST expression            { $$ = $1 % $3; }
        | LPARENTHESIS expression RPARENTHESIS  { $$ = $2; }
        ;

bool_expression : 
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
       id IS expression SEMICOLON             
    
       | id IS function_call SEMICOLON         
       ;

increment :
        id INCREMENT SEMICOLON   
        ;

decrement :
        id DECREMENT SEMICOLON   
        ;

return_statement :
        RETURN integer_number SEMICOLON   { printf("Return: %d\n", $2); }
        | RETURN float_number SEMICOLON    { printf("Return: %f\n", $2); }
        ;

if_statement : 
        IF LPARENTHESIS bool_expression RPARENTHESIS LBRACE statements_list RBRACE
        | IF LPARENTHESIS bool_expression RPARENTHESIS LBRACE statements_list RBRACE ELSE LBRACE statements_list RBRACE
        ;

loop :
        WHILE LPARENTHESIS bool_expression RPARENTHESIS LBRACE statements_list RBRACE
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