#include <string>
#include <unordered_map>
#include <vector>
#include <iostream>
#include <sstream>
#include <assert.h>
#include "node.h"

using namespace std;

static bool compareList(vector<Object*> &list1, vector<Object*> &list2) {
    if (list1.size() != list2.size()) return false;
    bool same = true;
    for (int i=0; i<list1.size() && same; i++) {
        if (list1[i] >= list2[i]) continue;
        else same = false;
    }
    return same;
}

/* Basic type or identifier */
Object::Object(string _name) : name(_name) {
    classtype = _BasicType;
}

// Or statement
Object::Object(string _name, What _what) : name(_name) {
    what = GoExpr;
}

// Or a go Object
Object::Object(string _name, Object *_type) {
    name = _name;
    base = _type;
    what = GoObj;
}

/* Function Type */
Object::Object(vector<Object*> _args, Object *_ret)
    : args(_args), ret(_ret) {
    classtype = _FxnType;
}

/* Struct Type */
Object::Object(unordered_map<string, Object*> _fields)
    : fields(_fields) {
    classtype = _StructType;
}

/* Tuple Type */
Object::Object(vector<Object*> _types) {
    classtype = _TupleType;
}

/* Map Type */
Object::Object(Object *_key, Object *_value)
    : key(_key), value(_value) {
    classtype = _MapType;
}

/* Array Type */
Object::Object(Object *_base)
    : base(_base) {
    classtype = _ArrayType;
}

/* Star Type */
Object::Object(Object *_base, bool isStar)
    : base(_base) {
    classtype = _StarType;
}

string Object::tostring() {
    assert(what == GoType);
    stringstream strval;
    if (classtype == _BasicType) {
        strval << name;
    } else if (classtype == _FxnType) {
        for (auto &param: args) {
            strval << param->tostring() << " -> ";
        }
        strval << ret->tostring();
    } else if (classtype == _StructType) {
        strval << "Data [ ";
        bool first = false;
        for (auto &param: fields) {
            if (!first) strval << ", ";
            strval << param.second->tostring();
        }
        cout << " ]";
    } else if (classtype == _TupleType) {
        strval << "( ";
        bool first = false;
        for (auto &param: types) {
            if (!first) strval << ", ";
            strval << param->tostring();
        }
        strval << " )";
    } else if (classtype == _ArrayType) {
        strval << "[]" << base->tostring();
    } else if (classtype == _StarType) {
        strval << "*" << base->tostring();
    } else if (classtype == _MapType) {
        strval << "map[" << key->tostring();
        strval << "]" << value->tostring();
    }
    return strval.str();
}

bool Object::operator==(Object *comp) {
    assert(what == GoType);
    if (classtype == comp->classtype) {
        if (classtype == _BasicType) {
            return name == comp->name;
        } else if (classtype == _StructType) {
            /* if (fields.size() != comp->fields.size()) return false; */
            /* return Object::compareList(fields, comp->fields); */
            /* TODO: Think about this */
            return true;
        } else if (classtype == _TupleType) {
            if (types.size() != comp->types.size()) return false;
            return compareList(types, comp->types);
        } else if (classtype == _ArrayType || classtype == _StarType) {
            return base == comp->base;
        } else if (classtype == _FxnType) {
            return compareList(args, comp->args) &&
                ret == comp->ret;
        } else if (classtype == _MapType) {
            return key == comp->key && value == comp->key;
        }
    }
    return false;
}

// Copy
Object* Object::operator=(Object *c) {
    name = c->name;
    what = c->what;
    where = c->where;
    classtype = c->classtype;
    members = c->members;
    args = c->args;
    ret = c->ret;
    fields = c->fields;
    types = c->types;
    children = c->children;
    key = c->key;
    value = c->value;
    base = c->base;
    return this;
}

// Assign type to object
Object* Object::operator>>(Object &comp) {
    assert(what == GoObj && comp.what == GoType);
    base = &comp;
    return this;
}

// Add a child
Object &operator<<(Object &a, Object &comp) {
    a.children.push_back(&comp);
    return a;
}

Object &operator+=(Object &a, Object &b) {
    a.children.insert(a.children.end(),
                      b.children.begin(), b.children.end());
    return a;
}

Object &operator<<=(Object &a, Object &c) {
    a.name = c.name;
    a.what = c.what;
    a.where = c.where;
    a.classtype = c.classtype;
    a.members = c.members;
    a.args = c.args;
    a.ret = c.ret;
    a.fields = c.fields;
    a.types = c.types;
    a.children = c.children;
    a.key = c.key;
    a.value = c.value;
    a.base = c.base;
    return a;
}
