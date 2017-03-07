#ifndef _NODE_H
#define _NODE_H
#include <iostream>
#include <vector>
#include <string.h>
#include <string>
#include <unordered_map>

using namespace std;

struct node {
    char name[100] = {0};
    vector<node *> children_nt;
    vector<char *> children_t;
};

node &operator<<(node &l, node *r);
node &operator<<(node &l, char *r);
node &operator>>(node &l, const char *r);
node &init();

enum TypeClass {
    _BasicType,
    _FxnType,
    _StructType,
    _TupleType,
    _MapType,
    _ArrayType,
    _StarType
};

class gotype;
class symbol;

class symbol {
public:
    string name;
    gotype *type;
};

class gotype {
public:
    string name;
    TypeClass classtype;

    unordered_map<string, symbol*> functions;

    /* For functions */
    vector<gotype*> args;
    gotype *ret;

    /* For structs */
    unordered_map<string, gotype*> fields;

    /* For tuples */
    vector<gotype*> types;

    /* For maps */
    gotype *key, *value;

    /* For array or star */
    gotype *base;

    gotype(string);
    gotype(vector<gotype*>, gotype*);
    gotype(unordered_map<string, gotype*>);
    gotype(vector<gotype*>);
    gotype(gotype*, gotype*);
    gotype(gotype*);
    gotype(gotype*, bool);

    string tostring();
    bool operator>=(gotype *comp);
};

#endif
