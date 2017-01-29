BUILD=./build
CPP=./cpp

all:
	mkdir $(BUILD)
	make gust

gust: $(BUILD)/gust.yy.c $(BUILD)/gust.tab.c $(BUILD)/gust.tab.h
	g++ $(BUILD)/gust.tab.c $(BUILD)/gust.yy.c -lfl -o gust

$(BUILD)/gust.yy.c: $(CPP)/lexer.l
	flex --outfile=$(BUILD)/gust.yy.c $(CPP)/lexer.l

$(BUILD)/gust.tab.c $(BUILD)/gust.tab.h: $(CPP)/parser.y
	bison -o $(BUILD)/gust.tab.c -d $(CPP)/parser.y

clean:
	rm -rf build
	rm gust
