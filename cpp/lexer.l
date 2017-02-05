%{
#include <iostream>
#include "../../cpp/node.h"
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
NL  (\n)
OR  (\|\|)
AND (&&)
LE  (<=)
GE  (>=)
EQ  (==)
NE  (!=)
LS  (<<)
RS  (>>)
AO  (&^)
LA  (<-)
REL_OP ({EQ}|{NE}|<|>|{GE}|{LE})
ADD_OP (\+|\-|\||\^)
MUL_OP (\*|\/|%|{LS}|{RS}|&|{AO})
%%
[ \t\n] ;
{LETTER}({LETTER}|{UNIDIGT})+ { yylval.sval = strdup(yytext); return IDENT; }
0{OCTDIGT}*                   { yylval.sval = strdup(yytext); return INT; }
0(x|X){HEXDIGT}+              { yylval.sval = strdup(yytext); return INT; }
[1-9]{DECDIGT}*               { yylval.sval = strdup(yytext); return INT; }
{DECIMAL}\.{DECIMAL}?{EXP}?   { yylval.sval = strdup(yytext); return FLOAT; }
{DECIMAL}{EXP}                { yylval.sval = strdup(yytext); return FLOAT; }
\.{DECIMAL}{EXP}?             { yylval.sval = strdup(yytext); return FLOAT; }
\+|-|\^|\*|&                  { yylval.sval = strdup(yytext); return DUAL_OP; }
\+|-|!|\^|\*|&|{LA}           { yylval.sval = strdup(yytext); return UN_OP; }
{OR}|{AND}|{REL_OP}|{ADD_OP}|{MUL_OP} { yylval.sval = strdup(yytext); return BIN_OP; }
.                                     { yylval.sval = strdup(yytext); return LITERAL; }
%%
