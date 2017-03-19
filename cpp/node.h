#ifndef _NODE_H
#define _NODE_H
#include <iostream>
#include <vector>
#include <string.h>
#include <string>
#include <unordered_map>
#define umap unordered_map

using namespace std;

class Object;

struct node {
    string name;
    vector<node *> children_nt;
    vector<string> children_t;

    Object *ast;
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

enum What { GoType, GoObj, GoExpr };

typedef void *Where;

class Object {
public:
    string name = "";
    What what = GoType;
    Where where = NULL;
    TypeClass classtype = _BasicType;

    unordered_map<string, Object *> members;

    /* For functions */
    vector<Object *> args;
    Object *ret;

    /* For structs */
    unordered_map<string, Object *> fields;

    /* For tuples */
    vector<Object *> types;

    /* For expressions */
    vector<Object *> children;

    /* For maps */
    Object *key, *value;

    /* For array or star or object */
    Object *base;

    Object(string);
    Object(string, What);
    Object(string, Object *);
    Object(vector<Object *>, Object *);
    Object(umap<string, Object *>);
    Object(vector<Object *>);
    Object(Object *, Object *);
    Object(Object *);
    Object(Object *, bool);

    string tostring();
    bool operator==(Object *comp);
    Object *operator>>(Object &comp);
    Object *operator=(Object *c);
};

Object &operator<<(Object &a, Object &b);
Object &operator+=(Object &a, Object &b);
Object &operator<<=(Object &a, Object &b);

#endif
