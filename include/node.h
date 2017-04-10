#ifndef _NODE_H
#define _NODE_H
#include <string.h>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include "type.h"
#include "tac.h"
#include "place.h"
#define umap unordered_map

using namespace std;

class Object;

struct myLoc {
    int line = 0;
    int col1 = 0;
    int col2 = 0;
};
extern myLoc *global_loc;

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
    bool isPrimaryExpr = false;

    Data(string);
};

struct node {
    string name;
    vector<child> children;
    Type *type;
    Data *data;

    Place *place;
    vector<TAC::Instr *> code;
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
