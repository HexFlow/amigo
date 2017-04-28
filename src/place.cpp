#include "helpers.h"
#include "node.h"
#include "type.h"

int Place::_id = 0;

Place::Place() {
    type = NULL;
    name = "*-tmp-" + to_std_string(_id++);
    next = NULL;
}

Place::Place(Type *_type) {
    type = _type;
    name = "*-tmp-" + nameFromSize(type) + "-" + to_std_string(_id++);
    next = NULL;
}

Place::Place(Type *_type, string _name) {
    type = _type;
    name = _name;
    next = NULL;
}

Place::Place(string _name) {
    type = NULL;
    name = _name;
    next = NULL;
}

string Place::nameFromSize(Type *_type) {
    switch (_type->classType) {
        case BASIC_TYPE:
            return _type->getType();
        case ARRAY_TYPE:
            return "Array-" +
                   nameFromSize(dynamic_cast<ArrayType *>(_type)->base);
        case SLICE_TYPE:
            return "Slice-" +
                   nameFromSize(dynamic_cast<SliceType *>(_type)->base);
        case STRUCT_TYPE:
            return "Struct-";
        case MAP_TYPE:
            return "Map-";
        case FUNCTION_TYPE:
            return "Func-";
        case POINTER_TYPE:
            return "Pointer-" +
                   nameFromSize(dynamic_cast<PointerType *>(_type)->BaseType);
        default:
            cerr << "UNKNOWN TYPE ENCOUNTERED " << _type->classType << endl;
            assert(false);
    };
}

string Place::toString() {
    return name;
}
