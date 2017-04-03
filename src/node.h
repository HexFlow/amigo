#ifndef _NODE_H
#define _NODE_H
#include <string.h>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include "type.h"
#define umap unordered_map

using namespace std;

class Object;

struct node;
struct child {
    int type = 0;  // 0 for NT (node*), 1 for T (string)
    node *nt = NULL;
    string t = "";

    child(int _type, node *_nt, string _t) {
        type = _type;
        nt = _nt;
        t = _t;
    }
};

struct Data {
    string name = "";
    Data *next = NULL;
    Data *child = NULL;

    Data(string);
};

struct node {
    string name;
    vector<child> children;
    Type *type;
    Data *data;
};

node &operator<<(node &l, node *r);
node &operator<<(node &l, char *r);
node &operator>>(node &l, const char *r);
node &init();

enum TypeClass {
    _BasicType,
    _FunctionType,
    _StructType,
    _TupleType,
    _MapType,
    _ArrayType,
    _StarType
};

#endif
