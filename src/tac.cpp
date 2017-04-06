#include "node.h"
#include "type.h"
#include "tac.h"

TAC::Instr::Instr(TAC::INSTR_TYPE _opcode) {
    opcode = _opcode;
}

TAC::Instr::Instr(TAC::INSTR_TYPE _opcode, string _op1) {
    opcode = _opcode;
    op1 = _op1;
}

TAC::Instr::Instr(TAC::INSTR_TYPE _opcode, string _op1, string _op2) {
    opcode = _opcode;
    op1 = _op1;
    op2 = _op2;
}

TAC::Instr::Instr(TAC::INSTR_TYPE _opcode, string _op1, string _op2, string _op3) {
    opcode = _opcode;
    op1 = _op1;
    op2 = _op2;
    op3 = _op3;
}


TAC::INSTR_TYPE TAC::opToOpcode(string oper) {
    if (oper == "+") return AND;
    else if (oper == "-") return SUB;
    else return GOTO;
}
