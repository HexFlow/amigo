class Type {
    virtual string getType();
}

class BasicType : Type {
    string base;
    string getType() {
        return base;
    }
}

class ArrayType : Type {
    int size;
    Type base;
    string getType() {
        return "[" + size + "]" + base.getType();
    }
}

class StructType : Type {
    vector<string> memNames;
    vector<Type> memTypes;
    string getType() {
        assert(memTypes.size() == memNames.size());
        if (memTypes.size() == 0) {
            return "struct {}";
        }
        string mems = "";
        for (int i = 0; i < memNames.size(); i++) {
            mems += " " + memNames[i] + " " + memTypes[i].getType() + ";";
        }
        return "struct {" + mems + "}";
    }
}

class FunctionType : Type {
    vector<Type> argTypes;
    vector<Type> retTypes;

    string getType() {
        string argStr = "";
        string retStr = "";
        for (int i = 0; i < argTypes.size(); i++) {
            argStr += argTypes[i].getType() + ", ";
        }
        for (int i = 0; i < retTypes.size(); i++) {
            retStr += retTypes[i].getType() + ", ";
        }
        return "func (" + argStr + ") (" + retStr + ")";
    }
}
