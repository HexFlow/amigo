#include <cstdio>
#include <fstream>
#include <iostream>

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern "C" void exit(int);
extern "C" int yydebug;
extern "C" int yy_flex_debug;
extern "C" char *yytext;

void yyerror(const char *s);

FILE *parseCLI(int argc, char **argv);
string escape_json(const string &s);

int main(int argc, char **argv) {
    yydebug = 1;
    yy_flex_debug = 1;

    FILE *myfile = parseCLI(argc, argv);

    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;

    // parse through the input until there is no more:
    int k;
    do {
        cout << (k = yylex()) << '\t';
        cout << escape_json(std::string(yytext)) << endl;
    } while (k != 0);
}

void yyerror(const char *s) {
    cout << "Parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}
