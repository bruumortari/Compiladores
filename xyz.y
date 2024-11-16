/* 
   Linguagem XYZ
*/
%{

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lex.yy.c"

void yyerror(char *msg);

/* Tabela de Símbolos */
#define MAX_SYMBOLS 100
char* currentFunction = NULL;

struct Symbol {
    char* name;  // nome da variável 
    char* type;  // tipo da variável
    char* function; // função a qual pertence a variável
} Symbol;

struct Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;
int functionSymbolCount = 0;

void addSymbol(char* name, char* type) {
    if (symbolCount >= MAX_SYMBOLS) {
        printf("Erro: A tabela de símbolos está cheia.\n");
        return;
    }
    symbolTable[symbolCount].name = strdup(name);
    symbolTable[symbolCount].type = strdup(type);
    symbolCount++;
}

void printSymbolTable() {
    printf("Tabela de Simbolos:\n");
    printf("----------------------------------------\n");

    for (int i = 0; i < symbolCount; i++) {
        printf("%s.%s [%s]\n", symbolTable[i].function, symbolTable[i].name, symbolTable[i].type);
    }
}

/* Flex */
extern int yylineno;
extern int yylex();
extern FILE *yyin;
%}

/* Declarções bison */
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
%token FUNCTION MAIN VAR LBRACE RBRACE LPARENTHESIS RPARENTHESIS
%token IF ELSE WHILE RETURN
%token PLUS MINUS MULTI DIV GREATERTHAN LESSTHAN EQL EQG IS DIFF AND OR EQ DIFFERENT INCREMENT DECREMENT NOT
%token SEMICOLON COMMA COLON

%type <s> id
%type <type> type

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

program :
        function_list FUNCTION MAIN LPARENTHESIS RPARENTHESIS LBRACE variable_list statements_list RBRACE 
        {
                currentFunction = "main";
                for (int i = functionSymbolCount; i < symbolCount; i++) {
                        symbolTable[i].function = currentFunction;
                }
                functionSymbolCount = symbolCount;
                printSymbolTable();
        }
   	;

function_list: 
        epsilon
        | function_list function
        ;        

function :
        FUNCTION id LPARENTHESIS parameters_list RPARENTHESIS LBRACE variable_list statements_list RBRACE 
        {
                currentFunction = strdup($2);
                for (int i = functionSymbolCount; i < symbolCount; i++) {
                        symbolTable[i].function = currentFunction;
                }
                functionSymbolCount = symbolCount;
                printSymbolTable();
        }
   	; 

epsilon :  ;        

function_call :
        id LPARENTHESIS parameters_call_list RPARENTHESIS SEMICOLON
        ;

parameters_call_list :
        epsilon
        | parameter_call non_empty_parameter_call
        ;

parameter_call :
        id
        ; 

non_empty_parameter_call :
        COMMA parameter_call non_empty_parameter_call
        | epsilon
        ;                       

parameter :    
        id type { 
                addSymbol($1, $2); 
        }
        ;

parameters_list:
        epsilon
        | parameter non_empty_parameters
        ;

non_empty_parameters:
        epsilon
        | COMMA parameter non_empty_parameters

id : 
        IDENTIFIER
        ; 

type :
        I64
        | F64
        ;                                        

variable :
        id COLON type IS expression { 
                addSymbol($1, $3); 
        } 
        ;

variable_list :
        epsilon
        | VAR variable non_empty_variables_list
        ;

non_empty_variables_list :
        SEMICOLON
        | COMMA variable non_empty_variables_list
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
        | statement statements_list
        ;

expression :
        INTEGER                          
        | FLOAT
        | IDENTIFIER                          
        | expression PLUS expression            
        | expression MINUS expression           
        | expression MULTI expression           
        | expression DIV expression
        | bool_expression             
        | LPARENTHESIS expression RPARENTHESIS  
        ;

bool_expression : 
        expression EQ expression
        | expression GREATERTHAN expression
        | expression EQG expression
        | expression LESSTHAN expression
        | expression EQL expression
        | expression DIFF expression
        | expression AND expression
        | expression OR expression
        | NOT expression
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
        RETURN expression SEMICOLON
        | RETURN SEMICOLON
        ;

if_statement :
        IF expression LBRACE statements_list RBRACE
        | IF expression LBRACE statements_list RBRACE ELSE LBRACE statements_list RBRACE
        ;

loop :
        WHILE expression LBRACE statements_list RBRACE
        ;  

%%

void yyerror(char *msg) {
    fprintf(stderr, "Erro: %s na linha %d\n", msg, yylineno);
}

int main () {
    FILE* file = fopen("fat.txt", "r"); // Abre o arquivo para leitura

    if (!file) {
        fprintf(stderr, "Erro ao abrir o arquivo.\n");
        return 1;
    }

    yyin = file;

    // Chama a função de análise sintática
    yyparse();

    fclose(file);

    // Imprimir a tabela de símbolos após a análise
    // printSymbolTable();

    return 0;
}