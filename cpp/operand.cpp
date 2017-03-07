#include <string>
#include <unordered_map>
#include <vector>
#include <iostream>
#include <sstream>
#include "node.h"

using namespace std;

static bool compareList(vector<gotype*> &list1, vector<gotype*> &list2) {
    if (list1.size() != list2.size()) return false;
    bool same = true;
    for (int i=0; i<list1.size() && same; i++) {
        if (list1[i] >= list2[i]) continue;
        else same = false;
    }
    return same;
}

/* Basic type */
gotype::gotype(string _name) : name(_name) {
    classtype = _BasicType;
}

/* Function Type */
gotype::gotype(vector<gotype*> _args, gotype *_ret)
    : args(_args), ret(_ret) {
    classtype = _FxnType;
}

/* Struct Type */
gotype::gotype(unordered_map<string, gotype*> _fields)
    : fields(_fields) {
    classtype = _StructType;
}

/* Tuple Type */
gotype::gotype(vector<gotype*> _types)
    : types(_types) {
    classtype = _TupleType;
}

/* Map Type */
gotype::gotype(gotype *_key, gotype *_value)
    : key(_key), value(_value) {
    classtype = _MapType;
}

/* Array or star Type */
gotype::gotype(gotype *_base)
    : base(_base) {
    classtype = _ArrayType;
}

gotype::gotype(gotype *_base, bool isStar)
    : base(_base) {
    classtype = _StarType;
}

string gotype::tostring() {
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

bool gotype::operator>=(gotype *comp) {
    if (classtype == comp->classtype) {
        if (classtype == _BasicType) {
            return name == comp->name;
        } else if (classtype == _StructType) {
            /* if (fields.size() != comp->fields.size()) return false; */
            /* return gotype::compareList(fields, comp->fields); */
            /* TODO: Think about this */
            return true;
        } else if (classtype == _TupleType) {
            if (types.size() != comp->types.size()) return false;
            return compareList(types, comp->types);
        } else if (classtype == _ArrayType || classtype == _StarType) {
            return base >= comp->base;
        } else if (classtype == _FxnType) {
            return compareList(args, comp->args) &&
                ret >= comp->ret;
        } else if (classtype == _MapType) {
            return key >= comp->key && value >= comp->key;
        }
    }
    return false;
}
