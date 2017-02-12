#include <fstream>
#include <iostream>
#include <string.h>

using namespace std;

FILE *parseCLI(int argc, char **argv) {
    if (argc < 2) {
        cerr << "No input files provided" << endl;
        cerr << "Usage: " << '\t' <<
            "./<lexer/parser> <input_file>" << endl;
        cerr << "Or: " << '\t' <<
            "./<lexer/parser> <input_file> -o <outfile>";
        exit(0);
    }

    FILE *infile = NULL;

    for (int i=1; i<argc; i++) {
        if (strcmp(argv[i], "-o") == 0) {
            if (i+1 < argc) {
                freopen(argv[i+1], "w", stdout);
                i++;
            } else {
                cerr << "No outfile file provided for -o flag" << endl;
            }
        } else {
            infile = fopen(argv[i], "r");
            if (!infile) {
                cerr << "Cannot open input file: " << argv[i] << endl;
                exit(0);
            }
        }
    }

    if (!infile) {
        cerr << "No input file provided" << endl;
        exit(0);
    }
    return infile;
}
