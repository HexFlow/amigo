.PHONY: try

BUILD=./target/cpp
BIN=./bin
DOTDIR=./target/dot
FLAGS=-g -std=c++14 -Wno-write-strings -I./cpp
CPP=./cpp

all:
	mkdir -p $(BUILD) $(BIN)
	make ast

# Rule for lexer and parser binaries
%: $(BUILD)/gust.yy.c $(BUILD)/gust.tab.c $(BUILD)/cli.o $(BUILD)/node.o $(BUILD)/helpers.o $(BUILD)/type.o $(BUILD)/%.o
	mkdir -p $(BIN)
	g++ $(FLAGS) $^ -lfl -o bin/$@

# Rule for creating .o files for files in /cpp
$(BUILD)/%.o: $(CPP)/%.cpp
	g++ -c $(FLAGS) $^ -o $@

$(BUILD)/gust.yy.c: $(CPP)/lexer.l
	flex -o $(BUILD)/gust.yy.c $(CPP)/lexer.l

$(BUILD)/gust.tab.c $(BUILD)/gust.tab.h: $(CPP)/parser.y
	bison -v -o $(BUILD)/gust.tab.c --report=all -d $(CPP)/parser.y

clean:
	rm -rf $(BUILD) $(DOTDIR) $(BIN)
	rm -f dot*.ps

# For drawing parse tree
parse-%: test/%.go
	make parser
	mkdir -p $(DOTDIR)
	./bin/parser test/$*.go -o $(DOTDIR)/$@
	dot -Tps $(DOTDIR)/$@ -o dot-$@.ps

# For drawing AST
ast-%: test/%.go
	make ast
	mkdir -p $(DOTDIR)
	./bin/ast test/$*.go -ast $(DOTDIR)/$@
	dot -Tps $(DOTDIR)/$@ -o dot-$@.ps

# Run all tests
test:
	make test1
	make test2

# Display test results instantly
try:
	./bin/parser test/test2.go -o dotfile
	dot -Tps dotfile -o dot.ps
	zathura dot.ps
