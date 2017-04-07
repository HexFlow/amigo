#include "helpers.h"

extern ostream *sout, *astout, *tacout;

string to_std_string(int a) {
    stringstream ss;
    ss << a;
    return ss.str();
}

ostream &operator<<(ostream &os, Data *m) {
    if (m && m->name == "")
        m = m->next;
    if (m == NULL)
        return os;
    os << m->name;
    if (m->child != NULL) {
        os << '(' << m->child << ')';
    }
    os << (m->next ? ", " : "") << m->next;
    return os;
}

string toString(ClassType tp) {
    switch (tp) {
        case NULL_TYPE:
            return "NULL_TYPE";
        case BASIC_TYPE:
            return "BASIC_TYPE";
        case ARRAY_TYPE:
            return "ARRAY_TYPE";
        case SLICE_TYPE:
            return "SLICE_TYPE";
        case STRUCT_TYPE:
            return "STRUCT_TYPE";
        case FUNCTION_TYPE:
            return "FUNCTION_TYPE";
        case POINTER_TYPE:
            return "POINTER_TYPE";
    }
};

bool isValidIdent(string name) {
    // TODO
    return true;
}

string tstr(char *s) { return string(s, strlen(s)); }

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
        ttable[name] = tp->clone();
        ttable[name]->next = NULL;
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
        stable[name] = tp->clone();
        stable[name]->next = NULL;
    }
}

bool isType(string name) { return (ttable.find(name) != ttable.end()); }

bool isSymbol(string name) { return (stable.find(name) != stable.end()); }

bool isInScope(string name) {
    if (isSymbol(scope_prefix + name)) {
        return true;
    }
    return false;
}

Type *getSymType(string name) {
    string cur_prefix = scope_prefix, id;
    while (cur_prefix != "") {
        id = cur_prefix + name;
        if (isSymbol(id))
            return stable[id]->clone();
        cur_prefix = cur_prefix.substr(cur_prefix.find("-") + 1);
    }
    id = cur_prefix + name;
    if (isSymbol(id))
        return stable[id]->clone();
    return NULL;
}

Type *isValidMemberOn(Data *base, Data *method) {
    auto symType = getSymType(base->name);
    if (symType == NULL) {
        cout << base->name << " is not declared in this scope" << endl;
        exit(1);
    }
    if (symType->classType != STRUCT_TYPE) {
        cout << base->name << " is not a struct type" << endl;
        exit(1);
    }

    StructType *baseStruct = dynamic_cast<StructType *>(symType);

    auto memType = baseStruct->members.find(method->name);
    if (memType == baseStruct->members.end()) {
        cout << method->name << " is not a member of type "
             << symType->getType() << endl;
    }
    return memType->second;
}

Type *resultOfFunctionApp(Type *fxnType, Type *argType) {
    if (fxnType->classType != FUNCTION_TYPE) {
        cout << fxnType->getType() << " is not a function" << endl;
        exit(1);
    }

    int pos = 1;
    auto fxnTypeCasted = dynamic_cast<FunctionType *>(fxnType);
    for (auto reqArgT : fxnTypeCasted->argTypes) {
        if (argType == NULL) {
            cout << "Insufficient arguments for application of function "
                "type "
                 << fxnType->getType() << endl;
            exit(1);
        }
        if (argType->getType() != reqArgT->getType()) {
            cout << "Needed type " << reqArgT->getType() << " at " << pos
                 << "-th position of function application of type "
                 << fxnType->getType() << "; got " << argType->getType()
                 << endl;
            exit(1);
        }
        argType = argType->next;
        pos = pos + 1;
    }

    if (argType != NULL) {
        cout << "Extra arguments provided to function: "
             << argType->getType() << endl;
        exit(1);
    }

    return vectorToLinkedList(fxnTypeCasted->retTypes);
}

Type *vectorToLinkedList(vector<Type *> &typs) {
    Type *newLink = new BasicType("");
    Type *retType = newLink;
    for (auto retT : typs) {
        newLink->next = retT;
        newLink = newLink->next;
    }
    return retType->next;
}

bool isDefined(string name) { return (getSymType(name) != NULL); }

void inittables() {
    typeInsert("void", new BasicType("void"));
    typeInsert("int", new BasicType("int"));
    typeInsert("bool", new BasicType("bool"));
    typeInsert("byte", new BasicType("byte"));
    typeInsert("float", new BasicType("float"));
    typeInsert("string", new BasicType("string"));

    unordered_map<string, Type *> fmtMap = {
        {"PrintString",
         new FunctionType(vector<Type *>{new BasicType("string")},
                          vector<Type *>{})},
        {"IOCall", new FunctionType(vector<Type *>{},
                                    vector<Type *>{new BasicType("string"),
                                            new BasicType("int")})},
        {"Hello", new BasicType("int")}};
    symInsert("fmt", new StructType(fmtMap));
}

void printtables() {
    cout << endl;
    *sout << "Symbol table:" << endl;
    for (auto elem : stable) {
        *sout << elem.first << " :: ";
        *sout << elem.second->getType();
        *sout << endl;
    }
    *sout << endl << "Type table:" << endl;
    for (auto elem : ttable) {
        *sout << elem.first << " :: ";
        *sout << elem.second->getType();
        *sout << endl;
    }
}

bool isLiteral(node *n) {
    if (n) {
        cout << n->name << "LALALA" << endl;
    }
    if (n && n->name == "BasicLit")
        return true;
    if (n == NULL || n->children.size() != 1)
        return false;
    return isLiteral(n->children[0].nt);
}

int getIntValue(node *n) {
    if (!isLiteral(n)) {
        ERROR("This is not a valid literal", "");
    }
    while (n->name != "BasicLit")
        n = n->children[0].nt;
    return atoi(n->data->name.c_str());
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
                    o << "\\u" << hex << setw(4) << setfill('0')
                      << (int)*c;
                } else {
                    o << *c;
                }
        }
    }
    return o.str();
}

string print(node *n) {
    int id1 = 0, id2 = 0;
    string name = "_" + to_std_string(node_id++);
    for (int i = 0; i < n->children.size(); i++) {
        child s = n->children[i];
        if (s.type == 0) {
            string child = print(s.nt);
            cout << name << " -- " << child << endl;
        } else {
            cout << "_" + to_std_string(node_id) << "[label=\""
                 << escape_json(s.t) << "\"]" << endl;
            cout << name << " -- "
                 << "_" + to_std_string(node_id++) << endl;
        }
    }
    cout << name << "[label=\"" << n->name << "\"]" << endl;
    return name;
}

int data_id = 0;

string print(Data *n) {
    int id1 = 0, id2 = 0;
    string name = "_" + to_std_string(data_id++);
    Data *child = n->child;
    while (child != NULL) {
        string ch_name = print(child);
        *astout << name << " -- " << ch_name << endl;
        child = child->next;
    }
    *astout << name << "[label=\"" << escape_json(n->name) << "\"]"
            << endl;
    return name;
}

void printTop(Data *n) {
    *astout << "graph {\n";
    print(n);
    *astout << "}" << endl;
}

void prettyError(int line, int col1, int col2) {
    FILE *f = fopen(filepath.c_str(), "r");
    char c = 'a';
    int lno = 1;
    cout << "Line number: " << line << endl << endl;

    while ((c = fgetc(f)) != EOF) {
        if (c == '\t')
            c = ' ';
        if (lno == line) {
            printf("%c", c);
        }
        if (lno > line)
            break;
        if (c == '\n')
            lno++;
    }
    cout << "\033[1;31m";
    for (int i = 1; i <= col2; i++) {
        if (i >= col1 && i < col2) {
            printf("^");
        } else {
            printf(" ");
        }
    }
    cout << "\033[0m\n";
    printf("\n");
}

void printCode(vector<TAC::Instr*> v) {
    cout << endl;
    *tacout << "Three Address Code:" << endl;
    for (auto &elem: v) {
        *tacout << elem->toString() << endl;
    }
}
