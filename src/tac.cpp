#include "node.h"
#include "type.h"
#include "tac.h"

TAC::Instr::Instr(TAC::INSTR_TYPE _opc) {
    opcode = _opc;
    op1 = NULL;
    op2 = NULL;
    op3 = NULL;
}

TAC::Instr::Instr(TAC::INSTR_TYPE _opc, Place *_op1) {
    opcode = _opc;
    op1 = _op1;
    op2 = NULL;
    op3 = NULL;
}

TAC::Instr::Instr(TAC::INSTR_TYPE _opc, string val) {
    opcode = _opc;
    op1 = new Place(NULL, val);
    op2 = NULL;
    op3 = NULL;
}

TAC::Instr::Instr(TAC::INSTR_TYPE _opc, Place *_op1, Place *_op2) {
    opcode = _opc;
    op1 = _op1;
    op2 = _op2;
    op3 = NULL;
}

TAC::Instr::Instr(TAC::INSTR_TYPE _opc, Place *_op1, Place *_op2, Place *_op3) {
    opcode = _opc;
    op1 = _op1;
    op2 = _op2;
    op3 = _op3;
}

string TAC::opcodeToString(TAC::INSTR_TYPE op) {
    switch (op) {
        case TAC::AND:
            return "AND";
        case TAC::OR:
            return "OR";
        case TAC::ADD:
            return "ADD";
        case TAC::SUB:
            return "SUB";
        case TAC::MUL:
            return "MUL";
        case TAC::DIV:
            return "DIV";
        case TAC::GOTO:
            return "GOTO";
        case TAC::STOR:
            return "STOR";
        case TAC::JEQZ:
            return "JEQZ";
        case TAC::JMP:
            return "JMP";
        case TAC::LABL:
            return "LABL";
        case TAC::RET:
            return "RET";
        case TAC::NOT:
            return "NOT";
        default:
            return "UNKNOWN";
    }
}

string TAC::Instr::toString() {
    stringstream ss;
    char placeholder[100];
    sprintf(placeholder, "%-25s ", TAC::opcodeToString(opcode).c_str());
    ss << placeholder;
    if (op1 != NULL) {
        sprintf(placeholder, "%-25s ", op1->toString().c_str());
        ss << placeholder;
    }
    if (op2 != NULL) {
        sprintf(placeholder, "%-25s ", op2->toString().c_str());
        ss << placeholder;
    }
    if (op3 != NULL) {
        sprintf(placeholder, "%-25s ", op3->toString().c_str());
        ss << placeholder;
    }
    return ss.str();
}

TAC::INSTR_TYPE TAC::opToOpcode(string oper) {
    if (oper == "+")
        return ADD;
    else if (oper == "-")
        return SUB;
    else if (oper == "*")
        return MUL;
    else if (oper == "/")
        return DIV;
    else if (oper == "!")
        return NOT;
    else
        return GOTO;
}

vector<TAC::Instr *> &TAC::Init() {
    return *(new vector<TAC::Instr *>());
}
