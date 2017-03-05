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
MAP    (map)
STRUCT (struct)
MAKE   (make)
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
ECURLY (;)

%x SEMIMODE

%%
<SEMIMODE>{NEWLINE}                    { BEGIN(INITIAL); return ';'; }
[}]/[\n]                               { BEGIN(SEMIMODE); return '}'; }
[]]/[\n]                               { BEGIN(SEMIMODE); return ']'; }
[)]/[\n]                               { BEGIN(SEMIMODE); return ')'; }

[{]/[\n]                               { yylval.sval = strdup(yytext); return ECURLY; }

{INC}/[\n]                             { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return INC; }
{DEC}/[\n]                             { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return DEC; }
{INC}                                  { yylval.sval = strdup(yytext); return INC; }
{DEC}                                  { yylval.sval = strdup(yytext); return DEC; }

{LEFT}                                 { yylval.sval = strdup(yytext); return LEFT; }
{DECL}                                 { yylval.sval = strdup(yytext); return DECL; }
{CONST}                                { yylval.sval = strdup(yytext); return CONST; }
{DOTS}                                 { yylval.sval = strdup(yytext); return DOTS; }
{FUNC}                                 { yylval.sval = strdup(yytext); return FUNC; }
{GO}                                   { yylval.sval = strdup(yytext); return GO; }
{MAP}                                  { yylval.sval = strdup(yytext); return MAP; }
{STRUCT}                               { yylval.sval = strdup(yytext); return STRUCT; }
{MAKE}                                 { yylval.sval = strdup(yytext); return MAKE; }

{RETURN}/[\n]                          { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return RETURN; }
{BREAK}/[\n]                           { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return BREAK; }
{CONT}/[\n]                            { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return CONT; }
{FALL}/[\n]                            { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return FALL; }

{RETURN}                               { yylval.sval = strdup(yytext); return RETURN; }
{BREAK}                                { yylval.sval = strdup(yytext); return BREAK; }
{CONT}                                 { yylval.sval = strdup(yytext); return CONT; }
{FALL}                                 { yylval.sval = strdup(yytext); return FALL; }

{GOTO}                                 { yylval.sval = strdup(yytext); return GOTO; }
{IF}                                   { yylval.sval = strdup(yytext); return IF; }
{ELSE}                                 { yylval.sval = strdup(yytext); return ELSE; }
{SWITCH}                               { yylval.sval = strdup(yytext); return SWITCH; }
{PACKGE}                               { yylval.sval = strdup(yytext); return PACKGE; }
{IMPORT}                               { yylval.sval = strdup(yytext); return IMPORT; }
{CASE}                                 { yylval.sval = strdup(yytext); return CASE; }
{DEFLT}                                { yylval.sval = strdup(yytext); return DEFLT; }
{SELECT}                               { yylval.sval = strdup(yytext); return SELECT; }
{TYPE}                                 { yylval.sval = strdup(yytext); return TYPE; }
{ISOF}                                 { yylval.sval = strdup(yytext); return ISOF; }
{FOR}                                  { yylval.sval = strdup(yytext); return FOR; }
{RANGE}                                { yylval.sval = strdup(yytext); return RANGE; }
{DEFER}                                { yylval.sval = strdup(yytext); return DEFER; }
{VAR}                                  { yylval.sval = strdup(yytext); return VAR; }

{LETTER}({LETTER}|{UNIDIGT})*/[\n]     { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return IDENT; }
0{OCTDIGT}*/[\n]                       { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return INT; }
0(x|X){HEXDIGT}+/[\n]                  { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return INT; }
[1-9]{DECDIGT}*/[\n]                   { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return INT; }
{DECIMAL}\.{DECIMAL}?{EXP}?/[\n]       { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return FLOAT; }
{DECIMAL}{EXP}/[\n]                    { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return FLOAT; }
\.{DECIMAL}{EXP}?/[\n]                 { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return FLOAT; }

{LETTER}({LETTER}|{UNIDIGT})*          { yylval.sval = strdup(yytext); return IDENT; }
0{OCTDIGT}*                            { yylval.sval = strdup(yytext); return INT; }
0(x|X){HEXDIGT}+                       { yylval.sval = strdup(yytext); return INT; }
[1-9]{DECDIGT}*                        { yylval.sval = strdup(yytext); return INT; }
{DECIMAL}\.{DECIMAL}?{EXP}?            { yylval.sval = strdup(yytext); return FLOAT; }
{DECIMAL}{EXP}                         { yylval.sval = strdup(yytext); return FLOAT; }
\.{DECIMAL}{EXP}?                      { yylval.sval = strdup(yytext); return FLOAT; }
\*                                     { yylval.sval = strdup(yytext); return STAR; }
\+|-|\^|\*|&                           { yylval.sval = strdup(yytext); return DUAL_OP; }
\+|-|!|\^|\*|&|{LEFT}                  { yylval.sval = strdup(yytext); return UN_OP; }
{OR}|{AND}|{REL_OP}|{ADD_OP}|{MUL_OP}  { yylval.sval = strdup(yytext); return BIN_OP; }
{ASN_OP}                               { yylval.sval = strdup(yytext); return ASN_OP; }

{RAW_ST}/[\n]                          { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return RAW_ST; }
{INR_ST}/[\n]                          { yylval.sval = strdup(yytext); BEGIN(SEMIMODE); return INR_ST; }
{RAW_ST}                               { yylval.sval = strdup(yytext); return RAW_ST; }
{INR_ST}                               { yylval.sval = strdup(yytext); return INR_ST; }

{COMMNT}                               { ; }
(\/\/.*)                               { ; }
[ \t\n]                                { ; }
.                                      { return yytext[0]; }
%%
