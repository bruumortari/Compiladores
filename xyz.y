/* Linguagem XYZ

 Bruna Bertolo Mortari - 11795892
 Larissa Magalhães Pereira - 13747904

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
char* currentFunction = "null";

struct Symbol {
    char* function; // função a qual pertence a variável
    char* name;  // nome da variável 
    char* type;  // tipo da variável
} Symbol;

struct Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;
int functionSymbolCount = 0;

void addSymbol(char* name, char* type) {
    if (symbolCount >= MAX_SYMBOLS) {
        printf("Erro: A tabela de simbolos está cheia.\n");
    }
    else {
        symbolTable[symbolCount].name = strdup(name);
        symbolTable[symbolCount].type = strdup(type);
        symbolTable[symbolCount].function = "null";
        symbolCount++;
    }
}

// Checa se uma variável ao ser usada, já foi declarada
void isDeclared(char* name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0 &&
            strcmp(symbolTable[i].function, "null") == 0) {
            return;
        }
    }
    fprintf(stderr, "Erro: Variavel '%s' sem declaracao\n", name);
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

/* Declarações bison */
%union {
        int d;
        double f;
        char* s;
        char* type;
}

%token <d> INTEGER
%token <f> FLOAT
%token <s> IDENTIFIER MAIN
%token <type> I64 F64
%token FUNCTION VAR LBRACE RBRACE LPARENTHESIS RPARENTHESIS
%token IF ELSE WHILE RETURN
%token PLUS MINUS MULTI DIV REST GREATERTHAN LESSTHAN EQL EQG IS AND OR EQ DIFFERENT INCREMENT DECREMENT NOT
%token SEMICOLON COMMA COLON

%type <s> id
%type <type> type

/* Lista de precedência */
%left MULTI DIV REST
%left PLUS MINUS
%nonassoc EQ DIFFERENT GREATERTHAN LESSTHAN EQL EQG
%nonassoc AND OR NOT

/* Gramática */
%%

program :
    function_list
    ;

function_list : 
    epsilon
    | function function_list
    ;

function :
    FUNCTION id LPARENTHESIS parameters_list RPARENTHESIS LBRACE variable_list statements_list RBRACE
    {
        currentFunction = strdup($2);
        for (int i = functionSymbolCount; i < symbolCount; i++) {
            symbolTable[i].function = currentFunction;
        }
        functionSymbolCount = symbolCount;
    }
    ;    

epsilon :  ;        

function_call :
        id LPARENTHESIS parameters_call_list RPARENTHESIS SEMICOLON
        | id IS id LPARENTHESIS parameters_call_list RPARENTHESIS SEMICOLON
        ;

parameters_call_list :
        epsilon
        | id non_empty_parameter_call
        ; 

non_empty_parameter_call :
        COMMA id non_empty_parameter_call
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
        ;

id : 
        IDENTIFIER
        | MAIN
        ; 

type :
        I64
        | F64
        ;                                        

variable_list :
        epsilon
        | VAR variable non_empty_variables_list SEMICOLON
        ;

variable :
        id COLON type IS expression { 
                addSymbol($1, $3); 
        } 
        ;

non_empty_variables_list :
        COMMA variable non_empty_variables_list
        | epsilon
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
        | IDENTIFIER { 
                isDeclared($1);
        }                     
        | expression PLUS expression            
        | expression MINUS expression           
        | expression MULTI expression           
        | expression DIV expression
        | bool_expression             
        | LPARENTHESIS expression RPARENTHESIS
        | expression REST expression
        ;

bool_expression : 
        expression EQ expression
        | expression GREATERTHAN expression
        | expression EQG expression
        | expression LESSTHAN expression
        | expression EQL expression
        | expression DIFFERENT expression
        | expression AND expression
        | expression OR expression
        | NOT expression
        ;

assignment : 
       id IS expression SEMICOLON
       { 
                isDeclared($1);
        }                     
       ;

increment :
        id INCREMENT SEMICOLON   
        ;

decrement :
        id DECREMENT SEMICOLON   
        ;

return_statement :
        RETURN expression SEMICOLON
        ;

if_statement :
        IF bool_expression LBRACE statements_list RBRACE
        | IF bool_expression LBRACE statements_list RBRACE ELSE LBRACE statements_list RBRACE
        ;

loop :
        WHILE expression LBRACE statements_list RBRACE
        ;  

%%

void yyerror(char *msg) {
    fprintf(stderr, "Erro: %s na linha %d\n", msg, yylineno);
}

int main () {

    // Abre o arquivo para leitura
    FILE* file = fopen("fat.txt", "r");

    if (!file) {
        fprintf(stderr, "Erro ao abrir o arquivo.\n");
        return 1;
    }

    yyin = file;

    // Chama a função de análise sintática
    yyparse();

    printSymbolTable();

    fclose(file);

    return 0;
}