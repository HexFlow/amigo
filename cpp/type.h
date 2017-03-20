#ifndef _TYPE_H
#define _TYPE_H
#define __CLASS_NAME__ className(__PRETTY_FUNCTION__)

#include <string>
#include <vector>
#include <assert.h>
using namespace std;

struct Type {
    virtual string getType();
    virtual string getClass();
};

struct BasicType : Type {
    string base;
    string getType();
    BasicType(string);
    //	string getClass();
};

struct ArrayType : Type {
    int size;
    Type *base;
    string getType();
    //	string getClass();
};

struct SliceType : Type {
    Type *base;
    string getType();
    //	string getClass();
};

struct StructType : Type {
    vector<string> memNames;
    vector<Type *> memTypes;
    string getType();
    //	string getClass();
};

struct FunctionType : Type {
    vector<Type *> argTypes;
    vector<Type *> retTypes;
    string getType();
    //	string getClass();
};

#endif
