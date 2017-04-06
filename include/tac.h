#ifndef _TAC_H
#define _TAC_H

#include "node.h"
#include "type.h"
#include <string.h>

namespace TAC {
    enum INSTR_TYPE {
        AND,
        OR,
        ADD,
        SUB,
        MUL,
        DIV,
        GOTO,
    };

    class Instr {
    public:
        Instr(INSTR_TYPE _opcode);
        Instr(INSTR_TYPE _opcode, string _op1);
        Instr(INSTR_TYPE _opcode, string _op1, string _op2);
        Instr(INSTR_TYPE _opcode, string _op1, string _op2, string _op3);

        INSTR_TYPE opcode;
        string op1, op2, op3;
    };

    INSTR_TYPE opToOpcode(string oper);
}

#endif
