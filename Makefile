.PHONY: try

BUILD=./target/cpp
FLAGS=-g -std=c++14 -Wno-write-strings
CPP=./cpp

all:
	make clean
	mkdir -p $(BUILD)
	make gust

gust: $(BUILD)/gust.yy.c $(BUILD)/gust.tab.c $(BUILD)/gust.tab.h $(BUILD)/main.o
	g++ $(FLAGS) $(BUILD)/gust.tab.c $(BUILD)/gust.yy.c $(BUILD)/main.o -lfl -o gust

$(BUILD)/gust.yy.c: $(CPP)/lexer.l
	flex -o $(BUILD)/gust.yy.c $(CPP)/lexer.l

$(BUILD)/gust.tab.c $(BUILD)/gust.tab.h: $(CPP)/parser.y
	bison -v -o $(BUILD)/gust.tab.c --report=all -d $(CPP)/parser.y

$(BUILD)/main.o: $(CPP)/main.cpp
	g++ -c $(FLAGS) $(CPP)/main.cpp -o $(BUILD)/main.o

clean:
	rm -rf $(BUILD)
	rm -f gust

try:
	./gust test/test1.go > dotfile
	dot -Tps dotfile -o dot.ps
	zathura dot.ps
