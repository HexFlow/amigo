# AMIGO (A Memory Inefficient GO compiler)
Go Compiler written for CS335 course, 2017 Spring semester.

# Running

## Dependencies
* GNU flex
* GNU bison
* GNU make

## Build
```
make
```
This should generate binaries inside the folder `bin`.

Alternatively, the following commands are also available:
```
make lexer
make parser
```

# Usage
```
./bin/lexer <filename> -o <outfile>
./bin/parser <filename> -o <outfile>
```
The `-o` flag is optional, and if omitted, the output will be on stdout.

# Tests
Drawing the graphs for the test cases can be done as follows:
```
make test1
make test2
make test3
```

This will create PostScript files in the main folder which you can then view with Evince/Zathura etc.
