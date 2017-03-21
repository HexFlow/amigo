#ifndef _TYPE_H
#define _TYPE_H

#include <string>
#include <vector>
#include <unordered_map>
#include <assert.h>
using namespace std;

enum ClassType {
    NULL_TYPE,
    BASIC_TYPE,
    ARRAY_TYPE,
    SLICE_TYPE,
    STRUCT_TYPE,
    MAP_TYPE,
    FUNCTION_TYPE,
    POINTER_TYPE
};

struct Type {
    virtual string getType();
    virtual Type *clone();
    Type *next = NULL;
    ClassType classType = NULL_TYPE;
};

struct BasicType : Type {
    string base;
    string getType();
    BasicType(string);
    Type *clone();
    ClassType classType = BASIC_TYPE;
};

struct ArrayType : Type {
    int size;
    Type *base;

    string getType();
    Type *clone();
    ClassType classType = ARRAY_TYPE;
};

struct SliceType : Type {
    Type *base;

    string getType();
    Type *clone();
    SliceType(Type *b) : base(b){};
    ClassType classType = SLICE_TYPE;
};

struct StructType : Type {
    unordered_map<string, Type *> members;

    string getType();
    Type *clone();
    ClassType classType = STRUCT_TYPE;
};

struct MapType : Type {
    Type *key, *value;

    string getType();
    Type *clone();
    MapType(Type *, Type *);
    ClassType classType = MAP_TYPE;
};

struct FunctionType : Type {
    vector<Type *> argTypes;
    vector<Type *> retTypes;

    string getType();
    FunctionType(vector<Type *> args, vector<Type *> rets)
        : argTypes(args), retTypes(rets){};
    Type *clone();
    ClassType classType = FUNCTION_TYPE;
};

#endif
