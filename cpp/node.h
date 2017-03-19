#ifndef _NODE_H
#define _NODE_H
#include <iostream>
#include <vector>
#include <string.h>
#include <string>
#include <unordered_map>
#include "type.h"
#define umap unordered_map

using namespace std;

class Object;

struct node;
struct child {
    int type = 0;  // 0 for NT (node*), 1 for T (string)
    node *nt = 0;
    string t = "";
};

struct node {
    string name;
    vector<child> children;
    Type *type;
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
