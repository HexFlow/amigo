#include <cstdio>
#include <iostream>
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
}

void yyerror(const char *s) {
    cout << "Parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}
