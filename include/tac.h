#ifndef _TAC_H
#define _TAC_H

#include "node.h"
#include "type.h"
#include "place.h"
#include <string>

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
        Instr(INSTR_TYPE _opcode, Place* _op1);
        Instr(INSTR_TYPE _opcode, Place* _op1, Place* _op2);
        Instr(INSTR_TYPE _opcode, Place* _op1, Place* _op2, Place* _op3);

        INSTR_TYPE opcode;
        Place *op1, *op2, *op3;
    };

    INSTR_TYPE opToOpcode(string oper);

    vector<TAC::Instr*>& Init();
}

#endif
