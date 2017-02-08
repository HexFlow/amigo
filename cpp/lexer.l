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
UNI_VAL ([^"]|{LITUVAL}|{BIGUVAL}|{ESCCHAR})
BYT_VAL ({OCTBVAL}|{HEXBVAL})
OCTBVAL (\\{OCTDIGT}{OCTDIGT}{OCTDIGT})
HEXBVAL (\\x{HEXDIGT}{HEXDIGT})
LITUVAL (\\u{HEXDIGT}{HEXDIGT}{HEXDIGT}{HEXDIGT})
BIGUVAL (\\U{HEXDIGT}{HEXDIGT}{HEXDIGT}{HEXDIGT}{HEXDIGT}{HEXDIGT}{HEXDIGT}{HEXDIGT})
ESCCHAR (\\(a|b|f|n|r|t|v|\\|\'|\"))
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
REL_OP ({EQ}|{NE}|<|>|{GE}|{LE})
ADD_OP (\+|\-|\||\^)
MUL_OP (\*|\/|%|{LS}|{RS}|&|{AO})
RAW_ST (`([^`]|{NEWLINE})*`)
INR_ST (\"({UNI_VAL}|{BYT_VAL})*\")
COMMNT (\/\*((\*[^\/])|{NEWLINE}|[^*])*\*\/)
ASN_OP (({ADD_OP}|{MUL_OP})?=)
LEFT   (<-)
INC    "++"
DEC    "--"
DECL   ":="
CONST  "const"
DOTS   "..."
FUNC   (func)
GO     (go)
RETURN (return)
BREAK  (break)
CONT   (continue)
GOTO   (goto)
FALL   (fallthrough)
IF     (if)
ELSE   (else)
SWITCH (switch)
CASE   (case)
DEFLT  (default)
SELECT (select)
PACKGE (package)
IMPORT (import)
TYPE   (type)
ISOF   (::)
FOR    (for)
RANGE  (range)
DEFER  (defer)
VAR    (var)
%%
[ \t\n] ;
{LEFT}                        { yylval.sval = strdup(yytext); return LEFT; }
{INC}                         { yylval.sval = strdup(yytext); return INC; }
{DEC}                         { yylval.sval = strdup(yytext); return DEC; }
{DECL}                        { yylval.sval = strdup(yytext); return DECL; }
{CONST}                       { yylval.sval = strdup(yytext); return CONST; }
{DOTS}                        { yylval.sval = strdup(yytext); return DOTS; }
{FUNC}                        { yylval.sval = strdup(yytext); return FUNC; }
{GO}                          { yylval.sval = strdup(yytext); return GO; }
{RETURN}                      { yylval.sval = strdup(yytext); return RETURN; }
{BREAK}                       { yylval.sval = strdup(yytext); return BREAK; }
{CONT}                        { yylval.sval = strdup(yytext); return CONT; }
{GOTO}                        { yylval.sval = strdup(yytext); return GOTO; }
{FALL}                        { yylval.sval = strdup(yytext); return FALL; }
{IF}                          { yylval.sval = strdup(yytext); return IF; }
{ELSE}                        { yylval.sval = strdup(yytext); return ELSE; }
{SWITCH}                      { yylval.sval = strdup(yytext); return SWITCH; }
{PACKGE}                      { yylval.sval = strdup(yytext); return PACKGE; }
{IMPORT}                      { yylval.sval = strdup(yytext); return IMPORT; }
{CASE}                        { yylval.sval = strdup(yytext); return CASE; }
{DEFLT}                       { yylval.sval = strdup(yytext); return DEFLT; }
{SELECT}                      { yylval.sval = strdup(yytext); return SELECT; }
{TYPE}                        { yylval.sval = strdup(yytext); return TYPE; }
{ISOF}                        { yylval.sval = strdup(yytext); return ISOF; }
{FOR}                         { yylval.sval = strdup(yytext); return FOR; }
{RANGE}                       { yylval.sval = strdup(yytext); return RANGE; }
{DEFER}                       { yylval.sval = strdup(yytext); return DEFER; }
{VAR}                         { yylval.sval = strdup(yytext); return VAR; }
{LETTER}({LETTER}|{UNIDIGT})* { yylval.sval = strdup(yytext); return IDENT; }
0{OCTDIGT}*                   { yylval.sval = strdup(yytext); return INT; }
0(x|X){HEXDIGT}+              { yylval.sval = strdup(yytext); return INT; }
[1-9]{DECDIGT}*               { yylval.sval = strdup(yytext); return INT; }
{DECIMAL}\.{DECIMAL}?{EXP}?   { yylval.sval = strdup(yytext); return FLOAT; }
{DECIMAL}{EXP}                { yylval.sval = strdup(yytext); return FLOAT; }
\.{DECIMAL}{EXP}?             { yylval.sval = strdup(yytext); return FLOAT; }
\+|-|\^|\*|&                  { yylval.sval = strdup(yytext); return DUAL_OP; }
\+|-|!|\^|\*|&|{LEFT}         { yylval.sval = strdup(yytext); return UN_OP; }
{OR}|{AND}|{REL_OP}|{ADD_OP}|{MUL_OP} { yylval.sval = strdup(yytext); return BIN_OP; }
{ASN_OP}                      { yylval.sval = strdup(yytext); return ASN_OP; }
{RAW_ST}                      { yylval.sval = strdup(yytext); return RAW_ST; }
{INR_ST}                      { yylval.sval = strdup(yytext); return INR_ST; }
{COMMNT}                      { ; }
.                                     { return yytext[0]; }
<<EOF>>     return 1272535465;
%%
