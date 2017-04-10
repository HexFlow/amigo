#include <cstdio>
#include <iostream>
#include "node.h"
#include "helpers.h"
using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern "C" void exit(int);
extern "C" int yydebug;

extern void inittables();
extern void printtables();

void yyerror(const char *s);

FILE *parseCLI(int argc, char **argv);

int main(int argc, char **argv) {
    inittables();

    yydebug = 1;

    FILE *myfile = parseCLI(argc, argv);

    yyin = myfile;

    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));

    printtables();
}

void yyerror(const char *s) {
    cout << "Parse error!  Message: " << s << endl;
    prettyError(global_loc->line, global_loc->col1, global_loc->col2);
    exit(-1);
}
