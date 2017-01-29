BUILD=./target/cpp
CPP=./cpp

all:
	mkdir -p $(BUILD)
	make gust

gust: $(BUILD)/gust.yy.c $(BUILD)/gust.tab.c $(BUILD)/gust.tab.h $(BUILD)/main.o
	g++ $(BUILD)/gust.tab.c $(BUILD)/gust.yy.c $(BUILD)/main.o -lfl -o gust

$(BUILD)/gust.yy.c: $(CPP)/lexer.l
	flex -o $(BUILD)/gust.yy.c $(CPP)/lexer.l

$(BUILD)/gust.tab.c $(BUILD)/gust.tab.h: $(CPP)/parser.y
	bison -o $(BUILD)/gust.tab.c -d $(CPP)/parser.y

$(BUILD)/main.o: $(CPP)/main.cpp
	g++ -c $(CPP)/main.cpp -o $(BUILD)/main.o

clean:
	rm -rf $(BUILD)
	rm gust
