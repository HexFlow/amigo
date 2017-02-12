#include <fstream>
#include <iostream>
#include <string.h>

using namespace std;

void help() {
    cerr << "No input files provided" << endl;
    cerr << "Usage: " << '\t' <<
        "./<lexer/parser> <input_file>" << endl;
    cerr << "Or: " << '\t' <<
        "./<lexer/parser> <input_file> -o <outfile>";
}

FILE *parseCLI(int argc, char **argv) {
    if (argc < 2) {
        help();
        exit(0);
    }

    FILE *infile = NULL;

    bool verbose = false;

    for (int i=1; i<argc; i++) {
        if (strcmp(argv[i], "-o") == 0) {
            if (i+1 < argc) {
                freopen(argv[i+1], "w", stdout);
                i++;
            } else {
                cerr << "No outfile file provided for -o flag" << endl;
            }
        } else if (strcmp(argv[i], "--help") == 0) {
            help();
        } else if (strcmp(argv[i], "-v") == 0) {
            verbose = true;
        } else {
            infile = fopen(argv[i], "r");
            if (!infile) {
                cerr << "Cannot open input file: " << argv[i] << endl;
                exit(0);
            }
        }
    }

    if (!verbose) {
        // Remove stderr
        freopen("/dev/null", "a", stderr);
    }

    if (!infile) {
        cerr << "No input file provided" << endl;
        exit(0);
    }
    return infile;
}
