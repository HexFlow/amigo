#include "type.h"

string Type::getType() {
    printf("This VIRTUAL function should never be called.");
    exit(1);
    return "";
}

string BasicType::getType() {
    // 'int'  <- returned string
    return base;
}

string ArrayType::getType() {
    // '[5]int'  <- returned string
    return "[" + to_string(size) + "]" + base.getType();
}

string StructType::getType() {
    // 'struct { a int; b string; }'  <- returned string

    assert(memTypes.size() == memNames.size());
    if (memTypes.size() == 0) {
        return "struct {}";
    }
    string mems = "";
    for (int i = 0; i < memNames.size(); i++) {
        mems += " " + memNames[i] + " " + memTypes[i].getType() + ";";
    }

    return "struct {" + mems + " }";
}

string FunctionType::getType() {
    // 'func(int, int) (float64, int)'  <- returned string
    string argStr = "";
    string retStr = "";

    for (int i = 0; i < argTypes.size(); i++) {
        argStr += argTypes[i].getType() + ", ";
    }
    for (int i = 0; i < retTypes.size(); i++) {
        retStr += retTypes[i].getType() + ", ";
    }

    return "func (" + argStr + ") (" + retStr + ")";
}
