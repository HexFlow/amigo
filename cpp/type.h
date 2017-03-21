#ifndef _TYPE_H
#define _TYPE_H

#include <string>
#include <vector>
#include <assert.h>
using namespace std;

enum ClassType {
    NULL_TYPE,
    BASIC_TYPE,
    ARRAY_TYPE,
    SLICE_TYPE,
    STRUCT_TYPE,
    FUNCTION_TYPE,
    POINTER_TYPE
};

struct Type {
    virtual string getType();
    virtual Type *clone();
    Type *next = NULL;
    ClassType classType;
};

struct BasicType : Type {
    string base;

    string getType();
    BasicType(string);
    Type *clone();
};

struct ArrayType : Type {
    int size;
    Type *base;

    string getType();
    ArrayType(int, Type *);
    Type *clone();
};

struct SliceType : Type {
    Type *base;

    string getType();
    Type *clone();
    SliceType(Type *b);
};

struct StructType : Type {
    vector<string> memNames;
    vector<Type *> memTypes;

    string getType();
    StructType(vector<string>, vector<Type *>);
    Type *clone();
};

struct FunctionType : Type {
    vector<Type *> argTypes;
    vector<Type *> retTypes;

    string getType();
    FunctionType(vector<Type *> args, vector<Type *> rets);
    Type *clone();
};

#endif
