#include "helpers.h"

string tstr(char *s) {
    return string(s, strlen(s));
}

Data *last(Data *ptr) {
    while (ptr->next != 0)
        ptr = ptr->next;
    return ptr;
}

char *concat(char *a, char *b) {
    int len1 = strlen(a);
    int len2 = strlen(b);
    char *ptr = new char[len1 + len2 + 1];
    strcpy(ptr, a);
    strcat(ptr, a);
    return ptr;
}

void typeInsert(string name, Type *tp) {
    bool found = (ttable.find(name) != ttable.end());
    if (found) {
        ERROR(name, " already declared as a type");
        exit(1);
    } else {
        ttable[name] = tp;
    }
}

void symInsert(string name, Type *tp) {
    bool found = (stable.find(name) != stable.end());
    if (found) {
        ERROR(name, " already declared as a symbol");
        exit(1);
    } else {
        if (tp == 0) {
            ERROR("Type shouldn't be null: ", tp);
            exit(1);
        }
        stable[name] = tp;
    }
}

bool isType(string name) {
    return (ttable.find(name) != ttable.end());
}

bool isSymbol(string name) {
    return (stable.find(name) != stable.end());
}

bool isInScope(string name) {
    if (isSymbol(scope_prefix + name)) {
        return true;
    }
    return false;
}

string getSymType(string name) {
    string cur_prefix = scope_prefix;
    while (cur_prefix != "") {
        string id = cur_prefix + name;
        if (isSymbol(id)) {
            return stable[id]->getType();
        }
        cur_prefix = cur_prefix.substr(cur_prefix.find("-") + 1);
    }
    return "Undefined";
}

bool isDefined(string name) {
    return (getSymType(name) != string("Undefined"));
}

void inittables() {
    typeInsert("void", new BasicType("void"));
    typeInsert("int", new BasicType("int"));
    typeInsert("bool", new BasicType("bool"));
    typeInsert("byte", new BasicType("byte"));
    typeInsert("float", new BasicType("float"));
    typeInsert("string", new BasicType("string"));
}

void printtables() {
    cout << endl << endl << "Symbol table:" << endl;
    for (auto elem : stable) {
        cout << elem.first << " :: ";
        cout << elem.second->getType();
        cout << endl;
    }
    for (auto elem : ttable) {
        cout << elem.first << " :: ";
        cout << elem.second->getType();
        cout << endl;
    }
}

string escape_json(const string &s) {
    ostringstream o;
    for (auto c = s.cbegin(); c != s.cend(); c++) {
        switch (*c) {
            case '"':
                o << "\\\"";
                break;
            case '\\':
                o << "\\\\";
                break;
            case '\b':
                o << "\\b";
                break;
            case '\f':
                o << "\\f";
                break;
            case '\n':
                o << "\\n";
                break;
            case '\r':
                o << "\\r";
                break;
            case '\t':
                o << "\\t";
                break;
            default:
                if ('\x00' <= *c && *c <= '\x1f') {
                    o << "\\u" << hex << setw(4) << setfill('0') << (int)*c;
                } else {
                    o << *c;
                }
        }
    }
    return o.str();
}

string print(node *n) {
    int id1 = 0, id2 = 0;
    string name = "_" + to_string(node_id++);
    for (int i = 0; i < n->children.size(); i++) {
        child s = n->children[i];
        if (s.type == 0) {
            string child = print(s.nt);
            cout << name << " -- " << child << endl;
        } else {
            cout << "_" + to_string(node_id) << "[label=\"" << escape_json(s.t)
                 << "\"]" << endl;
            cout << name << " -- "
                 << "_" + to_string(node_id++) << endl;
        }
    }
    cout << name << "[label=\"" << n->name << "\"]" << endl;
    return name;
}

void printTop(node *n) {
    printf("graph {\n");
    print(n);
    printf("\n}");
}
