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

TAC::Instr::Instr(TAC::INSTR_TYPE _opc, string loc, string val) {
    opcode = _opc;
    op1 = new Place(NULL, loc);
    op2 = new Place(NULL, val);
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
        case TAC::CMP:
            return "CMP";
        case TAC::LABL:
            return "LABL";
        case TAC::RET:
            return "RET";
        case TAC::JE:
            return "JE";
        case TAC::JNE:
            return "JNE";
        case TAC::RETSETUP:
            return "RETSETUP";
        case TAC::RETEND:
            return "RETEND";
        case TAC::PUSHRET:
            return "PUSHRET";
        case TAC::EXIT:
            return "EXIT";
        case TAC::NOT:
            return "NOT";
        case TAC::EQ:
            return "EQ";
        case TAC::NE:
            return "NE";
        case TAC::GE:
            return "GE";
        case TAC::LE:
            return "LE";
        case TAC::GT:
            return "GT";
        case TAC::LT:
            return "LT";
        case TAC::ASN:
            return "ASN";
        case TAC::DECL:
            return "DECL";
        case TAC::ADDR:
            return "ADDR";
        case TAC::ARGDECL:
            return "ARGDECL";
        case TAC::PUSH:
            return "PUSH";
        case TAC::PUSHARG:
            return "PUSHARG";
        case TAC::POP:
            return "POP";
        case TAC::MAKE:
            return "MAKE";
        case TAC::NEW:
            return "NEW";
        case TAC::CALL:
            return "CALL";
        case TAC::NEWFUNC:
            return "NEWFUNC";
        case TAC::NEWFUNCEND:
            return "NEWFUNCEND";
        case TAC::NEG:
            return "NEG";
        case TAC::DEREF:
            return "DEREF";
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
    // else if (oper == "+=")
    // return INCR;
    // else if (oper == "-=")
    // return DECR;
    else if (oper == "*")
        return MUL;
    else if (oper == "/")
        return DIV;
    else if (oper == "!")
        return NOT;
    else if (oper == "==")
        return EQ;
    else if (oper == "!=")
        return NE;
    else if (oper == ">=")
        return GE;
    else if (oper == "<=")
        return LE;
    else if (oper == "<")
        return LT;
    else if (oper == ">")
        return GT;
    else if (oper == "&&")
        return AND;
    else if (oper == "||")
        return OR;
    else if (oper == "=")
        return ASN;
    else if (oper == "&unary")
        return ADDR;
    else if (oper == "-unary")
        return NEG;
    else if (oper == "*unary")
        return DEREF;
    else {
        printf("Wrong operator!! %s\n", oper.c_str());
        exit(1);
    }
}

vector<TAC::Instr *> &TAC::Init() {
    return *(new vector<TAC::Instr *>());
}
