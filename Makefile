.PHONY: try

BUILD=./target/cpp
DOTDIR=./target/dot
FLAGS=-g -std=c++14 -Wno-write-strings
CPP=./cpp

all:
	make clean
	mkdir -p $(BUILD)
	make lexer
	make parser

# Rule for lexer and parser binaries
%: $(BUILD)/gust.yy.c $(BUILD)/gust.tab.c $(BUILD)/gust.tab.h $(BUILD)/%.o
	g++ $(FLAGS) $(BUILD)/gust.tab.c $(BUILD)/gust.yy.c $(BUILD)/$@.o -lfl -o $@

# Rule for lexer and parser .o files
$(BUILD)/%.o: $(CPP)/%.cpp
	g++ -c $(FLAGS) $< -o $@

$(BUILD)/gust.yy.c: $(CPP)/lexer.l
	flex -o $(BUILD)/gust.yy.c $(CPP)/lexer.l

$(BUILD)/gust.tab.c $(BUILD)/gust.tab.h: $(CPP)/parser.y
	bison -v -o $(BUILD)/gust.tab.c --report=all -d $(CPP)/parser.y

clean:
	rm -rf $(BUILD) $(DOTDIR)
	rm -f lexer parser dot*.ps 

# For running tests
%: test/%.go
	make parser
	mkdir -p $(DOTDIR)
	./parser test/$@.go > $(DOTDIR)/$@
	dot -Tps $(DOTDIR)/$@ -o dot-$@.ps

# Run all tests
test:
	make test1
	make test2

# Display test results instantly
try:
	./gust test/test2.go > dotfile
	dot -Tps dotfile -o dot.ps
	zathura dot.ps
