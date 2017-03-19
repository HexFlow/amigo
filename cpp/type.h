#ifndef _TYPE_H
#define _TYPE_H

#include <string>
#include <vector>
#include <assert.h>
using namespace std;

struct Type {
    virtual string getType();
};

struct BasicType : Type {
    string base;
    string getType();
};

struct ArrayType : Type {
    int size;
    Type base;
    string getType();
};

struct StructType : Type {
    vector<string> memNames;
    vector<Type> memTypes;
    string getType();
};

struct FunctionType : Type {
    vector<Type> argTypes;
    vector<Type> retTypes;
    string getType();
};

#endif
