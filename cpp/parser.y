%{
#include <cstdio>
#include <iostream>
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
 
void yyerror(const char *s);
%}
%union {
	int ival;
	float fval;
	char *sval;
	long long lval;
}

%token SNAZZLE TYPE
%token END
%token <ival> INT
%token <fval> FLOAT
%token <sval> IDENT

%%
program:
       int program
       | float program
       | int
       | float
       ;
int:
   INT { cout << "Int found: " << $1 << endl; }
   ;
float:
	 FLOAT { cout << "Float found: " << $1 << endl; }
	 ;
%%
