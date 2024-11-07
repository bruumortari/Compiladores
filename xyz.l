%option noyywrap

%{
    #include <stdlib.h>
    #include <string.h>
    #include "calc.tab.h"
    extern int yyerror (char const *msg, ...);

    /* Funcão para pegar o nome da variável que for criada no modelo: var nome_variável */
    char* getVarName(char *str) {
        int len = strlen(str);
        char *varName = malloc(len - 4 + 1);

        for(int i = 4; i < len; i++) {
            varName[i - 4] = str[i];
        }

        varName[len - 4] = '\0'; // Finaliza a string
        return varName;
    }
}%

%%
"fn"                   { return FUNCTION; }
"var"                  { return VAR; }
"{"                    { return LBRACES; }
"}"                    { return RBRACES; }
"("                    { return LPARENTHESIS; } 
")"                    { return RPARENTHESIS; }                        
"if"                   { return IF; }
"else"                 { return ELSE; }
"while"                { return WHILE; }
"+"                    { return PLUS; }
"-"                    { return MINUS; }
"*"                    { return MULTI; }
"/"                    { return DIV; }
"%"                    { return REST; }
">"                    { return GREATERTHAN; }
"<"                    { return LESSTHAN; }
"<="                   { return EQL; }
">="                   { return EQG; }
"="                    { return IS; }
"&&"                   { return AND; }
"||"                   { return OR; }
"=="                   { return EQ; }
"!="                   { return DIFFERENT; }
";"                    { return ';'; }
","                    { return ','; }
"i64"                  { return 'i64'; } 
"f64"                  { return 'f64'; }
"++"                   { return INCREMENT; }
"--"                   { return DECREMENT; } 
"!"                    { return NOT; } /* Expressao unária com o operador '!' */
[a-z_][a-zA-Z0-9_]*    { yylval.s = strdup(yytext); return IDENTIFIER;} 
[0-9]+                 { yylval.d = atoi(yytext); return INTEGER; }
[+-]?[0-9]+(\.[0-9]+)  { yylval.f = atof(yytext); return FLOAT; }
[ \n\t\r]              {  } /* Ignora */
"//".*                 {  } /* Ignora comentarios */
"/*"[a-zA-Z0-9\n\t\r_"*"]*"*/"   {  } /* Ignora comentários */
.                      { yyerror("unknown token %s\n", yytext); }
%%

int main(int argc, const char** argv) {
    // Verifica se o arquivo foi passado
    if(argc > 1) {
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }

    // Executa o programa
    yylex();
    return 0;
}