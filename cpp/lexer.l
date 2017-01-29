%{
#include <iostream>
#include "gust.tab.h"
using namespace std;
#define YY_DECL extern "C" int yylex()
%}
NEWLINE [\n]
UNICHAR [^\n]
UNILETR [A-Za-z]
UNIDIGT [0-9]
LETTER  [A-Za-z_]
DECDIGT [0-9]
OCTDIGT [0-7]
HEXDIGT [0-9A-Fa-f]
DECIMAL [0-9]+
EXP     (e|E)(\+|\-)?{DECIMAL}
%%
[ \t\n] ;
{LETTER}({LETTER}|{UNIDIGT})+ { yylval.sval = strdup(yytext); return IDENT; }
0{OCTDIGT}*                   { yylval.lval = strtol(yytext, NULL, 8); return INT; }
0(x|X){HEXDIGT}+              { yylval.lval = strtol(yytext, NULL, 16); return INT; }
[1-9]{DECDIGT}*               { yylval.lval = strtol(yytext, NULL, 10); return INT; }
{DECIMAL}\.{DECIMAL}?{EXP}?   { yylval.fval = atof(yytext); return FLOAT; }
{DECIMAL}{EXP}                { yylval.fval = atof(yytext); return FLOAT; }
\.{DECIMAL}{EXP}?             { yylval.fval = atof(yytext); return FLOAT; }
.              ;
%%
