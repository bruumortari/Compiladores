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
    char* function; // função a qual pertence a variável
    char* name;  // nome da variável 
    char* type;  // tipo da variável
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
    symbolTable[symbolCount].function = strdup(currentFunction);
    symbolCount++;
}

void printSymbolTable() {
    printf("Tabela de Símbolos:\n");
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

%type <d> integer_number return_statement_integer
%type <s> id assignment increment decrement parameter final_parameter variable function_call epsilon
%type <f> float_number expression return_statement_float
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

program : function_list FUNCTION MAIN LPARENTHESIS RPARENTHESIS LBRACE variable_list statements_list RBRACE
        {
                currentFunction = "main"; // Define o contexto como "main"
                for (int i = functionSymbolCount; i < symbolCount; i++) {
                        symbolTable[i].function = "main";
                }
                functionSymbolCount = symbolCount;
        }

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

function_list : 
        epsilon
        | function_list function 
        ;

function_call :
        id LPARENTHESIS parameters_list RPARENTHESIS SEMICOLON

parameter :    
        epsilon
        | parameter id type COMMA { 
                addSymbol($2, $3); 
        }
        ;

final_parameter:
        id type { 
                addSymbol($1, $2); 
        }
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
        | id COLON type IS expression COMMA variable { 
                addSymbol($1, $3); 
        } 
        ;

final_variable :
        id COLON type IS expression SEMICOLON { 
                addSymbol($1, $3); 
        } 
        ;

variable_list :
        epsilon
        | variable variable_list
        | final_variable
        ;   

statement :
        assignment 
        | increment 
        | decrement 
        | if_statement 
        | loop 
        | function_call
        | return_statement_integer
        | return_statement_float
        ; 

statements_list :
        epsilon
        | statements_list statement
        ;

expression :
        integer_number                          { $$ = $1; }
        | float_number                          { $$ = $1; }
        | expression PLUS expression            { $$ = $1 + $3; }
        | expression MINUS expression           { $$ = $1 - $3; }
        | expression MULTI expression           { $$ = $1 * $3; }
        | expression DIV expression             { $$ = $1 / $3; }
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

return_statement_integer :
        RETURN integer_number SEMICOLON   
        ;

return_statement_float :
        RETURN float_number SEMICOLON    
        ;

if_statement : 
        IF LPARENTHESIS bool_expression RPARENTHESIS LBRACE statements_list RBRACE
        | IF LPARENTHESIS bool_expression RPARENTHESIS LBRACE statements_list RBRACE ELSE LBRACE statements_list RBRACE
        ;

loop :
        WHILE LPARENTHESIS bool_expression RPARENTHESIS LBRACE statements_list RBRACE
        ;  

%%

void yyerror(char *msg) {
    fprintf(stderr, "Erro: %s\n", msg);
}

int main () {
    FILE* file = fopen("fat.xyz", "r"); // Abre o arquivo para leitura

    if (!file) {
        fprintf(stderr, "Erro ao abrir o arquivo.\n");
        return;
    }

    yyin = file;

    // Chama a função de análise sintática
    yyparse();

    fclose(file);

    // Imprimir a tabela de símbolos após a análise
    printSymbolTable();

    return 0;
}