#ifndef _NODE_H
#define _NODE_H
#include <string.h>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include "type.h"
#include "tac.h"
#define umap unordered_map

using namespace std;

class Object;

/* Used to store location of variable in 3AC */
class Place {
private:
    /* How many variables have been assigned till now */
    static int _id;

    /* Take type and return keyword for this type */
    string nameFromSize(Type *type);

public:
    string name;                /* To show while printing */
    Type *type;                 /* Needed to allocate space */

    Place(Type *_type);
    Place(Type *_type, string _name);
};

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

    Place *place;
    vector<TAC::Instr*> code;
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
