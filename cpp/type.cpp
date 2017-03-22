#include "type.h"

// inline string className(const string &prettyFunction) {
// size_t colons = prettyFunction.find("::");
// if (colons == string::npos)
// return "::";
// size_t begin = prettyFunction.substr(0, colons).rfind(" ") + 1;
// size_t end = colons - begin;

// return prettyFunction.substr(begin, end);
//}

string Type::getType() {
    printf("This VIRTUAL function should never be called.");
    exit(1);
    return "";
}
Type *Type::clone() {
    printf("This VIRTUAL function should never be called.");
    exit(1);
    return NULL;
}

string BasicType::getType() {
    // 'int'  <- returned string
    return base;
}

Type *BasicType::clone() {
    return (new BasicType(*this));
}

BasicType::BasicType(string _base) {
    base = _base;
    classType = BASIC_TYPE;
}

string ArrayType::getType() {
    // '[5]int'  <- returned string
    return "[" + to_string(size) + "]" + base->getType();
}
Type *ArrayType::clone() {
    return (new ArrayType(*this));
}
ArrayType::ArrayType(int _size, Type *_base) : size(_size), base(_base) {
    classType = ARRAY_TYPE;
}

string SliceType::getType() {
    // '[5]int'  <- returned string
    return "[]" + base->getType();
}
Type *SliceType::clone() {
    return (new SliceType(*this));
}
SliceType::SliceType(Type *_base) : base(_base) {
    classType = SLICE_TYPE;
}

string StructType::getType() {
    // 'struct { a int; b string; }'  <- returned string

    string mems = "";

    for (auto &elem : members) {
        mems += " " + elem.first + " " + elem.second->getType() + ";";
    }

    return "struct {" + mems + " }";
}
Type *StructType::clone() {
    return (new StructType(*this));
}
StructType::StructType(unordered_map<string, Type *> _mem) : members(_mem) {
    classType = STRUCT_TYPE;
}

MapType::MapType(Type *_key, Type *_value) {
    key = _key;
    value = _value;
    classType = MAP_TYPE;
}

string MapType::getType() {
    // 'map[int]bool'  <- returned string
    return "map[" + key->getType() + "]" + value->getType();
}

Type *MapType::clone() {
    return (new MapType(*this));
}

string FunctionType::getType() {
    // 'func(int, int) (float64, int)'  <- returned string
    string argStr = "";
    string retStr = "";

    for (int i = 0; i < argTypes.size(); i++) {
        argStr += argTypes[i]->getType() + ", ";
    }
    for (int i = 0; i < retTypes.size(); i++) {
        retStr += retTypes[i]->getType() + ", ";
    }

    return "func (" + argStr + ") (" + retStr + ")";
}
Type *FunctionType::clone() {
    return (new FunctionType(*this));
}
FunctionType::FunctionType(vector<Type *> _argTypes, vector<Type *> _retTypes)
    : argTypes(_argTypes), retTypes(_retTypes) {
    classType = FUNCTION_TYPE;
}
