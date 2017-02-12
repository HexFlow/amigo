#include <cstdio>
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

string escape_json(const string &s);

int main(int argc, char **argv) {
    yydebug = 1;
    yy_flex_debug = 1;
    // open a file handle to a particular file:
    FILE *myfile = fopen(argv[1], "r");
    // make sure it's valid:
    if (!myfile) {
        cout << "I can't open input file. Exiting." << endl;
        return -1;
    }
    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;

    // parse through the input until there is no more:
    int k;
    do {
        cout << (k = yylex()) << '\t';
        printf("%s\n", escape_json(std::string(yytext)).c_str());
    } while (k != 0);
}

void yyerror(const char *s) {
    cout << "Parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}
