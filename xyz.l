/* Linguagem XYZ

 Bruna Bertolo Mortari - 11795892
 Larissa Magalhães Pereira - 13747904

*/
%{
    #include <stdlib.h>
    #include <string.h>
    #include "xyz.tab.h"
    extern void yyerror (char *msg);

%}

%option noyywrap yylineno

%%
"fn"                   { return FUNCTION; }
"main"                 { yylval.s = "main"; return MAIN; }
"var"                  { return VAR; }
"{"                    { return LBRACE; }
"}"                    { return RBRACE; }
"("                    { return LPARENTHESIS; } 
")"                    { return RPARENTHESIS; }                        
"if"                   { return IF; }
"else"                 { return ELSE; }
"while"                { return WHILE; }
"return"               { return RETURN; }
"+"                    { return PLUS; }
"-"                    { return MINUS; }
"*"                    { return MULTI; }
"/"                    { return DIV; }
">"                    { return GREATERTHAN; }
"<"                    { return LESSTHAN; }
"<="                   { return EQL; }
">="                   { return EQG; }
"="                    { return IS; }
"&&"                   { return AND; }
"||"                   { return OR; }
"=="                   { return EQ; }
"!="                   { return DIFFERENT; }
";"                    { return SEMICOLON; }
":"                    { return COLON; }
","                    { return COMMA; }
"i64"                  { yylval.type = "i64"; return I64; } 
"f64"                  { yylval.type = "f64"; return F64; }
"++"                   { return INCREMENT; }
"--"                   { return DECREMENT; } 
"!"                    { return NOT; } 
[a-zA-Z][a-zA-Z_]*     { yylval.s = strdup(yytext); return IDENTIFIER;} 
"-"?[0-9]+             { yylval.d = atoi(yytext); return INTEGER; }
"-"?[0-9]+(\.[0-9]+)   { yylval.f = atof(yytext); return FLOAT; }
[ \n\t\r]              {  } 
"//".*                 {  } 
"/*"[a-zA-Z0-9\n\t\r_"*"]*"*/"      {  } 
.                      { yyerror("unknown token %s\n"); }
%%