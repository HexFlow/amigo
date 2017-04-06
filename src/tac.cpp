#include "node.h"
#include "type.h"
#include "tac.h"

TAC::Instr::Instr(TAC::INSTR_TYPE _opc, Place* _op1) {
    opcode = _opc;
    op1 = _op1;
}

TAC::Instr::Instr(TAC::INSTR_TYPE _opc, Place* _op1, Place* _op2) {
    opcode = _opc;
    op1 = _op1;
    op2 = _op2;
}

TAC::Instr::Instr(TAC::INSTR_TYPE _opc, Place* _op1, Place* _op2, Place* _op3) {
    opcode = _opc;
    op1 = _op1;
    op2 = _op2;
    op3 = _op3;
}


TAC::INSTR_TYPE TAC::opToOpcode(string oper) {
    if (oper == "+") return AND;
    else if (oper == "-") return SUB;
    else return GOTO;
}

vector<TAC::Instr*> &TAC::Init() {
    return *(new vector<TAC::Instr*>());
}
