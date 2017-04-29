from helpers import custom_split
import re

class KeyedElem:
    """
    To be used to store elements of struct.
    Offset field needed for code generation.
    """
    def __init__(self, name, base, offset):
        self.name = name
        self.base = base
        self.offset = offset

    def __str__(self):
        return self.name + " " + self.base.__str__()

    def __repr__(self):
        return self.__str__()

class BasicType:
    """
    All basic types like int, byte, bool etc
    """
    def __init__(self, name):
        self.name = name
        self.size = 8

    def __str__(self):
        return self.name

    def __repr__(self):
        return self.__str__()

class PointerType:
    def __init__(self, base):
        self.base = base
        self.size = 8

    def __str__(self):
        return "*" + self.base.__str__()

    def __repr__(self):
        return self.__str__()

class ArrayType:
    """
    Fixed sized arrays. Allocated on stack if used without make/new.
    """
    def __init__(self, base, size):
        self.name = "-----------"
        self.base = base
        self.size = size * base.size

    def __str__(self):
        return ("[" + str(self.size // self.base.size) + "]" +
                self.base.__str__())

    def __repr__(self):
        return self.__str__()

class SliceType:
    """
    Vectors. Stored on heap, and owns a pointer on the stack
    for accesses.
    """
    def __init__(self, base):
        self.name = "-----------"
        self.base = base
        self.size = 8  # Would be a simple pointer to heap

    def __str__(self):
        return "[]" + self.base.__str__()

    def __repr__(self):
        return self.__str__()

class StructType:
    """
    Struct. Stores children as a dictionary pointing to keyed elements.
    """
    def get_offset(self, name):
        return self.elems[name].offset

    def __init__(self, elems):
        # Elems is a list of tuples. (name, basetype)
        self.name = "-----------"
        self.size = 0
        self.elems = {}
        for elem in elems:
            self.elems[elem[0]] = KeyedElem(
                name=elem[0],
                base=elem[1],
                offset=self.size)
            self.size += elem[1].size

    def __str__(self):
        return "struct {" + ', '.join(
            [va.__str__() for va in self.elems.values()]
        ) + "}"

    def __repr__(self):
        return self.__str__()

class FuncType:
    def __init__(self, s):
        self.name = "-----------"
        for m in re.findall(r'^func \((.*)\) (.*)$', s):
            self.args = [ parse_type(x.strip()) for x in custom_split(m[0]) ]
            self.ret = parse_type(m[1])
        self.size = 8

    def __str__(self):
        return "func (" + ', '.join(
            [arg.__str__() for arg in self.args]
        ) + ") " + self.ret.__str__()

    def __repr__(self):
        return self.__str__()

class TupleType:
    def __init__(self, st):
        self.name = "-----------"
        self.mems = [ parse_type(x.strip()) for x in custom_split(st[1:-1]) ]
        self.size = 0
        for mem in self.mems:
            self.size += mem.size

    def __str__(self):
        return '(' + ', '.join([ x.__str__() for x in self.mems ]) + ')'

    def __repr__(self):
        return self.__str__()

class MapType:
    def __init__(self, key_type, val_type):
        self.name = "-----------"
        self.ktype = key_type
        self.vtype = val_type
        # TODO: How to handle size?

    def __str__(self):
        return "map[" + self.ktype.__str__() + "]" + self.vtype.__str__()

    def __repr__(self):
        return self.__str__()

def parse_type(s):
    """
    Helper function to allow creating instances of the above classes
    using a simple string printed by the C++ component of amigo.
    """
    if re.match(r'^struct \{.*\}$', s):
        # return parse_struct(s)
        matches = [ m.strip()
                    for m in re.findall(r'^struct \{(.*)\}$', s)[0].
                    split(';') ]
        parsed_matches = [ (m.split(' ', 1)[0].strip(),
                            parse_type(m.split(' ', 1)[1].strip()))
                           for m in matches if m != '']
        return StructType(parsed_matches)

    elif re.match(r'^\[\].*$', s):
        subt = parse_type(re.findall(r'^\[\](.*)$', s)[0])
        return SliceType(base=subt)

    elif re.match(r'^\[.*?\].*$', s):
        out = re.findall(r'^\[(.*?)\](.*)$', s)[0]
        size = int(out[0])
        subt = parse_type(out[1])
        return ArrayType(base=subt, size=size)

    elif s.startswith('func'):
        return FuncType(s)

    elif s.startswith('('):
        return TupleType(s)

    elif s.startswith('*'):
        return PointerType(base=parse_type(s[1:]))

    elif s[:3] == 'map':
        counter, i, tp = 1, 0, ""
        s = s[4:]
        while counter is not 0:
            tp += s[i]
            i += 1
            if s[i] == '[': counter += 1
            elif s[i] == ']': counter -= 1
        return MapType(key_type=parse_type(tp), val_type=parse_type(s[i:]))
    else:
        return BasicType(name=s)
