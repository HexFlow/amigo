#include "helpers.h"
#include "node.h"
#include "type.h"

int Place::_id = 0;

Place::Place(Type *_type) {
    type = _type;
    name = nameFromSize(type) + "-" + to_std_string(_id++);
}

Place::Place(Type *_type, string _name) {
    type = _type;
    name = _name;
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
        // case POINTER_TYPE:
        //     return "Pointer-" +
        //         nameFromSize(dynamic_cast<PointerType*>(_type)->base);
        default:
            cerr << "UNKNOWN TYPE ENCOUNTERED" << endl;
            assert(false);
    };
}

string Place::toString() {
    return name;
}
