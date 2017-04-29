#ifndef _TAC_H
#define _TAC_H

#include "node.h"
#include "type.h"
#include "place.h"
#include <string>
#include <sstream>

namespace TAC {
enum INSTR_TYPE {
    AND,
    OR,
    ADD,
    SUB,
    MUL,
    DIV,
    GOTO,
    STOR,
    JEQZ,
    LABL,
    RET,
    RETSETUP,
    RETEND,
    PUSHRET,
    JMP,
    JE,
    CMP,
    NE,
    GE,
    LE,
    GT,
    LT,
    NOT,
    EQ,
    DECL,
    ARGDECL,
    PUSH,
    POP,
    MAKE,
    NEW,
    ASN,
    ADDR,
    NEG,
    DEREF,
    CALL,
    EXIT,
    PUSHARG,
    NEWFUNC,
    NEWFUNCEND,
};

class Instr {
public:
    Instr(INSTR_TYPE _opcode);
    Instr(INSTR_TYPE _opcode, Place *_op1);
    Instr(INSTR_TYPE _opcode, Place *_op1, Place *_op2);
    Instr(INSTR_TYPE _opcode, Place *_op1, Place *_op2, Place *_op3);

    Instr(INSTR_TYPE _opcode, string name);
    Instr(INSTR_TYPE _opcode, string name, string name2);

    INSTR_TYPE opcode;
    Place *op1, *op2, *op3;

    string toString();
};

INSTR_TYPE opToOpcode(string oper);

string opcodeToString(INSTR_TYPE op);

vector<TAC::Instr *> &Init();
}

#endif
