//-*-mode: c++-mode-*-
%{
#include <cstdio>
#include <sstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <stack>
#include <string>
#include <algorithm>
#include <unordered_map>
#include "node.h"
#include "type.h"
#include "tac.h"
#include "place.h"
#include "helpers.h"

#define YYDEBUG 1

#define COPS(A, B) { A->data = B->data; A->type = B->type;                  \
                     A->code = B->code; A->place = B->place; };

typedef TAC::Instr Instr;

#define HANDLE_BIN_OP(A, B, C, D, aA, aB, aC, aD)                           \
    A->data = new Data(string(C) + "binary");                               \
    A->data->child = B->data;                                               \
    last(A->data->child)->next = D->data;                                   \
    if(B->type == NULL) {                                                   \
        ERROR_N("Missing type info in node", B->data->name, aB);            \
        exit(1);                                                            \
    }                                                                       \
    if(D->type == NULL) {                                                   \
        ERROR_N("Missing type info in node", D->data->name, aD);            \
        exit(1);                                                            \
    }                                                                       \
    if(D->type->getType() != B->type->getType()) {                          \
        ERROR_N("Mismatched types : ", B->type->getType() +                 \
        " and " + D->type->getType(), aD);                                  \
        exit(1);                                                            \
    }                                                                       \
    A->type = operatorResult(B->type, D->type, C);                          \
    A->place = new Place(A->type);                                          \
    auto tmpPlace = new Place(B->type);                                     \
    A->code = TAC::Init() << B->code << D->code <<                          \
        (new Instr(TAC::STOR, B->place, tmpPlace)) <<                       \
        (new Instr(TAC::opToOpcode(C), D->place, tmpPlace)) <<              \
        (new Instr(TAC::STOR, tmpPlace, A->place));

#define HANDLE_REL_OP(A, B, C, D, aA, aB, aC, aD)                           \
    A->data = new Data(string(C) + "binary");                               \
    A->data->child = B->data;                                               \
    last(A->data->child)->next = D->data;                                   \
    if(B->type == NULL) {                                                   \
        ERROR_N("Missing type info in node", B->data->name, aB);            \
        exit(1);                                                            \
    }                                                                       \
    if(D->type == NULL) {                                                   \
        ERROR_N("Missing type info in node", D->data->name, aD);            \
        exit(1);                                                            \
    }                                                                       \
    if((D->type->getType() != B->type->getType()) && D->type->getType() != "nil") { \
        ERROR_N("Mismatched types : ", B->type->getType() +                 \
        " and " + D->type->getType(), aD);                                  \
        exit(1);                                                            \
    }                                                                       \
    A->type = operatorResult(B->type, D->type, C);                          \
    A->place = new Place(A->type);                                          \
    auto tmpPlace = new Place(B->type);                                     \
    A->code = TAC::Init() << B->code << D->code;                            \
    A->code << (new Instr(TAC::STOR, B->place, tmpPlace));                  \
    A->code << (new Instr(TAC::CMP, D->place, tmpPlace));                   \
    A->code << (new Instr(TAC::opToOpcode(C), tmpPlace));                   \
    A->code << (new Instr(TAC::STOR, tmpPlace, A->place));                  \
    scopeExpr(A->code);

#define HANDLE_AND_OR_OP(A, B, C, D, aA, aB, aC, aD)                        \
    A->data = new Data(string(C) + "binary");                               \
    A->data->child = B->data;                                               \
    last(A->data->child)->next = D->data;                                   \
    if(B->type == NULL) {                                                   \
        ERROR_N("Missing type info in node", B->data->name, aB);            \
        exit(1);                                                            \
    }                                                                       \
    if(D->type == NULL) {                                                   \
        ERROR_N("Missing type info in node", D->data->name, aD);            \
        exit(1);                                                            \
    }                                                                       \
    if((D->type->getType() != B->type->getType()) && D->type->getType() != "nil") { \
        ERROR_N("Mismatched types : ", B->type->getType() +                 \
        " and " + D->type->getType(), aD);                                  \
        exit(1);                                                            \
    }                                                                       \
    A->type = operatorResult(B->type, D->type, C);                          \
    A->place = new Place(A->type);                                          \
    auto end = newlabel();                                                  \
    label_id++;                                                             \
    A->code = TAC::Init() << B->code;                                       \
    A->code << (new Instr(TAC::CMP, new Place("$0"), B->place));            \
    A->code << (new Instr(TAC::STOR, B->place, A->place));                  \
    if(string(C) == "&&")                                                   \
        A->code << (new Instr(TAC::JE, end));                               \
    else                                                                    \
        A->code << (new Instr(TAC::JNE, end));                              \
    A->code << D->code;                                                     \
    A->code << (new Instr(TAC::STOR, D->place, A->place));                  \
    A->code << new Instr(TAC::LABL, end);                                   \
    scopeExpr(A->code);


/* (new Instr(TAC::opToOpcode(C), A->place, B->place, D->place)); */

using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);

template<typename T>
vector<T> operator<<=(vector<T> &A, vector<T> &B) {
    vector<T> AB;
    AB.reserve(A.size() + B.size());
    AB.insert(AB.end(), A.begin(), A.end());
    AB.insert(AB.end(), B.begin(), B.end());
    return AB;
}

vector<Instr*> &operator<<(vector<Instr*> &v1,
                     vector<Instr*> &v2) {
    try {
        v1.insert(v1.end(), v2.begin(), v2.end());
        return v1;
    } catch (int e) {
        cerr << "Unimplemented function encountered for TAC" << endl;
        return TAC::Init();
    }
}

vector<Instr*> &operator<<(vector<Instr*> &v1, Instr* elem) {
    v1.push_back(elem);
    return v1;
}


// SYMBOL TABLE CONSTRUCTS
int node_id = 0;
int scope_id = 0;
string scope_prefix = "0-";
string last_closed = "";
int label_id = 1;

// For break/continue statements
stack<string> breaklabels;
stack<string> nextlabels;

string newlabel() {
    return "label" + to_std_string(label_id);
}

Type *curFxnType = NULL;

umap<string, Type*> stable; // symbols (a is an int)
umap<string, Type*> ttable; // types (due to typedef or predeclared)

%}
%locations

%union {
    node* nt;
    char *sval;
}

%token <sval> INT FLOAT TRUE FALSE IDENT B1 B2 B3 B4 B5 D4 D5 STAR ECURLY UN_OP NIL
%token <sval> RAW_ST INR_ST ASN_OP LEFT INC DEC DECL CONST DOTS FUNC MAP INCR DECR
%token <sval> GO RETURN BREAK CONT GOTO FALL IF ELSE SWITCH CASE END MAKE NEW
%token <sval> DEFLT SELECT TYPE ISOF FOR RANGE DEFER VAR IMPORT PACKGE STRUCT
%type <nt> SourceFile Expression Expression1 Expression2 Expression3 EmptyExpr
%type <nt> Block StatementList Statement SimpleStmt Expression4 Expression5
%type <nt> EmptyStmt ExpressionStmt SendStmt Channel IncDecStmt MapType
%type <nt> Assignment ShortVarDecl Declaration ConstDecl ConstSpecList VarSpec
%type <nt> Signature Result Parameters ParameterList ParameterDecl TypeList
%type <nt> ConstSpec MethodDecl Receiver TopLevelDecl LabeledStmt Empty
%type <nt> GoStmt ReturnStmt BreakStmt ContinueStmt GotoStmt StructType
%type <nt> FunctionDecl FunctionName VarSpecList FallthroughStmt
%type <nt> Function FunctionBody ForStmt ForClause RangeClause InitStmt
%type <nt> PostStmt Condition DeferStmt UnaryExpr PrimaryExpr
%type <nt> Selector Index Slice TypeDecl TypeSpecList TypeSpec VarDecl
%type <nt> TypeAssertion Arguments ExpressionList ArrayType CompositeLit
%type <nt> LiteralValue ElementList KeyedElement Key Element ExpressionE
%type <nt> Operand Literal BasicLit OperandName ImportSpec IfStmt
%type <nt> UnaryOp BinaryOp String ImportPath SliceType LiteralType
%type <nt> PackageClause ImportDeclList ImportDecl ImportSpecList TopLevelDeclList
%type <nt> FieldDeclList FieldDecl MakeExpr StructLiteral KeyValList Type
/*%type <nt> TypeName InterfaceTypeName*/
%type <nt> QualifiedIdent PointerType IdentifierList
%type <nt> BrkBlk BrkBlkEnd
%%
SourceFile:
    PackageClause ';' ImportDeclList TopLevelDeclList {
        $$ = &(init() << $1 << $3 << $4 >> "SourceFile");
        $$->data = new Data("SourceFile");
        $$->data->child = $4->data;
        printTop($$->data);
        printCode($4->code);
    }
    ;

Block:
    ECURLY OPENB StatementList CLOSEB '}' {
        $$ = &(init() << $3 >> "Block");
        COPS($$, $3);
    }
    ;

OPENB:
    /* empty */ {
        scope_id++;
        scope_prefix = (to_std_string(scope_id) + "-" + scope_prefix);
    }
    ;

CLOSEB:
    /* empty */ {
        last_closed = scope_prefix.substr(0, scope_prefix.find("-") + 1);
        scope_prefix = scope_prefix.substr(scope_prefix.find("-") + 1);
    }
    ;

BrkBlk: {
        $$ = &(init());
        breaklabels.push(newlabel());
        label_id++;
        nextlabels.push(newlabel());
        $$->code = TAC::Init() << new Instr(TAC::LABL, new Place(nextlabels.top()));
        label_id++;
    }
    ;

BrkBlkEnd: {
        $$ = &(init());
        $$->code = TAC::Init() << new Instr(TAC::LABL, new Place(breaklabels.top()));
        breaklabels.pop();
        nextlabels.pop();
    }
    ;

StatementList:
    StatementList Statement ';' {
        $$ = &(init() << $1 << $2 >> "StatementList");
        $$->data = $1->data;
        last($$->data->child)->next = $2->data;
        $$->code = TAC::Init() << $1->code << $2->code;
    }
    | Statement ';' {
        $$ = &(init() << $1 >> "StatementList");
        $$->data = new Data("list");
        if($1->data == NULL) {
            ERROR_N("No AST attached", "", @1);
            exit(1);
        }
        $$->data->child = $1->data;
        $$->code = TAC::Init() << $1->code;
    }
    ;

Statement:
    Declaration       {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    | LabeledStmt     {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    | SimpleStmt      {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    | GoStmt          {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    | ReturnStmt      {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    | BreakStmt       {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    | ContinueStmt    {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    | GotoStmt        {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    /*| FallthroughStmt {*/
        /*$$ = &(init() << $1 >> "Statement");*/
    /*}*/
    | Block           {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    | IfStmt          {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    /* | SwitchStmt      { $$ = &(init() << $1 >> "Statement"); } */
    /* | SelectStmt      { $$ = &(init() << $1 >> "Statement"); } */
    | ForStmt         {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    | DeferStmt       {
        $$ = &(init() << $1 >> "Statement");
        COPS($$, $1);
    }
    ;

SimpleStmt:
    EmptyStmt        {
        $$ = &(init() << $1 >> "SimpleStmt");
        COPS($$, $1);
    }
    | ExpressionStmt {
        $$ = &(init() << $1 >> "SimpleStmt");
        COPS($$, $1);
    }
    | SendStmt       {
        $$ = &(init() << $1 >> "SimpleStmt");
        COPS($$, $1);
    }
    | IncDecStmt     {
        $$ = &(init() << $1 >> "SimpleStmt");
        COPS($$, $1);
    }
    | Assignment     {
        $$ = &(init() << $1 >> "SimpleStmt");
        COPS($$, $1);
    }
    | ShortVarDecl   {
        $$ = &(init() << $1 >> "SimpleStmt");
        COPS($$, $1);
    }
    ;

EmptyStmt:
    /* blank */ {
        $$ = &(init() >> "EmptyStmt");
        $$->data = new Data("");
        $$->code = TAC::Init();
    }
    ;

ExpressionStmt:
    Expression {
        $$ = &(init() << $1 >> "ExpressionStmt");
        COPS($$, $1);
        scopeExpr($$->code);
    }
    ;

SendStmt:
    Channel LEFT Expression { $$ = &(init() << $1 << $3 >> "SendStmt"); }
    ;

Channel:
    Expression { $$ = &(init() << $1 >> "Channel"); }
    ;

IncDecStmt:
    Expression INC   {
        $$ = &(init() << $1 << $2 >> "IncDecStmt");
        $$->data = new Data(string($2)+"unary");
        $$->data->child = $1->data;
        $$->code = TAC::Init() << $1->code <<
            new Instr(TAC::ADD, new Place("1"), $1->place);
        scopeExpr($$->code);
    }
    | Expression DEC {
        $$ = &(init() << $1 << $2 >> "IncDecStmt");
        $$->data = new Data(string($2)+"unary");
        $$->data->child = $1->data;
        $$->code = TAC::Init() << $1->code <<
            new Instr(TAC::SUB, new Place("1"), $1->place);
        scopeExpr($$->code);
    }
    | Expression INCR Expression {
        $$ = &(init() << $1 << $2 << $3 >> "IncDecStmt");
        $$->data = new Data(string($2));
        $$->data->child = $1->data;
        $$->code = TAC::Init() << $1->code << $3->code <<
            new Instr(TAC::ADD, $3->place, $1->place);
        scopeExpr($$->code);
    }
    | Expression DECR Expression {
        $$ = &(init() << $1 << $2 << $3 >> "IncDecStmt");
        $$->data = new Data(string($2));
        $$->data->child = $1->data;
        $$->code = TAC::Init() << $1->code << $3->code <<
            new Instr(TAC::SUB, $3->place, $1->place);
        scopeExpr($$->code);
    }
    ;

Assignment:
    ExpressionList ASN_OP ExpressionList {
        $$ = &(init() << $1 << $2 << $3 >> "Assignment");
        Data* lhs = $1->data;
        Type* ltype = $1->type;
        Type* rhs = $3->type;
        Place* rplace = $3->place;
        Data* rhsd = $3->data;

        $$->code = TAC::Init() << $3->code << $1->code;

        while(lhs != NULL || rhs != NULL) {
            if(lhs == NULL || rhs == NULL) {
                ERROR_N("= must have equal operands on LHS and RHS", "", @$);
                exit(1);
            }
            string varLeft = lhs->name;
            if(!lhs->lValue && lhs->child != NULL) {
                ERROR_N("Non identifier to left of =", "", @1);
                exit(1);
            }
            if(lhs->lValue) {
                if (lhs->child == NULL) {
                    varLeft = lhs->name;
                } else {
                    varLeft = lhs->child->name;
                }
            }
            if(!isValidIdent(varLeft)) {
                ERROR_N(varLeft, " is not a valid Identifier", @1);
                exit(1);
            }
            if(rhs?(rhs->getType() == "undefined"):false) {
                ERROR_N("Identifier in RHS has not yet been defined: ", string(rhsd->name), @3)
                exit(1);
            }
            if(getSymType(varLeft) != NULL) {
                if((ltype->getType() != rhs->getType()) && rhs->getType() != "nil") {
                    ERROR_N(varLeft, " has a different type " + ltype->getType() + " than RHS " + rhs->getType(), @1);
                    exit(1);
                }
            } else {
                ERROR_N(varLeft, " variable has not been declared.", @1);
                exit(1);
            }

            $$->code << new Instr(TAC::STOR,
                                  rplace,
                                  new Place(rhs, lhs->lval));

            lhs = lhs->next;
            ltype = ltype->next;
            rhs = rhs->next;
            rplace = rplace?rplace->next:rplace;
            rhsd = rhsd?rhsd->next:rhsd;
        }
        Data* parentleft = new Data("list");
        Data* parentright = new Data("list");
        parentleft->child = $1->data;
        parentright->child = $3->data;
        parentleft->next = parentright;
        $$->data = new Data{$2};
        $$->data->child = parentleft;

        scopeExpr($$->code);
    }
    ;

ShortVarDecl:
    ExpressionList DECL ExpressionList   {
        $$ = &(init() << $1  << $3 >> "ShortVarDecl");
        bool newVar = false;
        Data*lhs = $1->data;
        Type*rhs = $3->type;
        Place*rplace = $3->place;
        Data*rhsd = $3->data;

        $$->code = TAC::Init() << $3->code;

        while(lhs != NULL || rhs != NULL) {
            if(lhs == NULL || rhs == NULL) {
                ERROR_N(":= must have equal operands on LHS and RHS", "", @$);
                exit(1);
            }
            string varLeft = lhs->name;
            if(lhs->child != NULL) {
                ERROR_N("Non identifier to left of :=", "", @1);
                exit(1);
            }
            if(!isValidIdent(varLeft)) {
                ERROR_N(varLeft, " is not a valid Identifier", @1);
                exit(1);
            }
            if(rhs?(rhs->getType() == "undefined"):false) {
                ERROR_N("Identifier in RHS has not yet been defined: ", string(rhsd->name), @3)
                exit(1);
            }
            if(isInScope(varLeft)) {
                if(getSymType(varLeft)->getType() != rhs->getType()) {
                    ERROR_N(varLeft, " has a different type than RHS", @1);
                    exit(1);
                }
            } else {
                newVar = true;
                symInsert(scope_prefix+varLeft, rhs); //TODO check rhs type not "undefined"
                $$->code << new Instr(TAC::DECL, new Place(lhs->name));
            }

            $$->code << new Instr(TAC::STOR,
                                  rplace,
                                  new Place(rhs, lhs->name));

            lhs = lhs->next;
            rhs = rhs->next;
            rplace = rplace?rplace->next:rplace;
            rhsd = rhsd?rhsd->next:rhsd;
        }
        if(newVar == false) {
            ERROR_N("No new variables found to the left of := ", "", @1);
            exit(1);
        }
        Data* parentleft = new Data("list");
        Data* parentright = new Data("list");
        parentleft->child = $1->data;
        parentright->child = $3->data;
        parentleft->next = parentright;
        $$->data = new Data{$2};
        $$->data->child = parentleft;

        scopeExpr($$->code);
    }
    ;

VarDecl:
    /* VAR '(' VarSpecList ')' { $$ = &(init() << $3 >> "VarDecl"); } */
    VAR VarSpec           {
        $$ = &(init() << $2 >> "VarDecl");
        COPS($$, $2);
    }
    ;

VarSpec:
    IdentifierList Type {
        $$ = &(init() << $1 << $2 >> "VarSpec");
        Data *data = $1->data;
        $$->code = TAC::Init();
        while(data != 0) {
            if(isInScope(data->name)) {
                ERROR_N(data->name, " is already defined in this scope", @1);
                exit(1);
            }
            cout << "// " << $2->type << __LINE__ << endl;
            symInsert(scope_prefix+data->name, $2->type);
            $$->code << new Instr(TAC::DECL,
                                  new Place(scope_prefix + data->name));
            $$->type = $2->type;
            data = data->next;
        }
        $$->data = new Data("");
    }
    | IdentifierList Type ASN_OP ExpressionList {
        $$ = &(init() << $1 << $2 << $4 >> "VarSpec");
        Data *data = $1->data;
        $$->code = TAC::Init();
        while(data != 0) {
            if(isInScope(data->name)) {
                ERROR_N(data->name, " is already defined in this scope", @1);
                exit(1);
            }
            symInsert(scope_prefix+data->name, $2->type);
            $$->code << new Instr(TAC::DECL,
                                  new Place(scope_prefix + data->name));
            $$->type = $2->type;
        }
        Data* parentleft = new Data("list");
        Data* parentright = new Data("list");
        parentleft->child = $1->data;
        parentright->child = $4->data;
        parentleft->next = parentright;
        $$->data = new Data("=");
        $$->data->child = parentleft;
    }
    | IdentifierList ASN_OP ExpressionList      {
        $$ = &(init() << $1 << $3 >> "VarSpec");
        Data*lhs = $1->data;
        Type*rhs = $3->type;
        Data*rhsd = $3->data;
        $$->code = TAC::Init();
        while(lhs != NULL || rhs != NULL || rhsd != NULL) {
            if(lhs == NULL || rhs == NULL || rhsd == NULL) {
                ERROR_N(":= must have equal operands on LHS and RHS", "", @$);
                exit(1);
            }
            string varLeft = lhs->name;
            if(lhs->child != NULL) {
                ERROR_N("Non identifier to left of :=", "", @1);
                exit(1);
            }
            if(!isValidIdent(varLeft)) {
                ERROR_N(varLeft, " is not a valid Identifier", @1);
                exit(1);
            }
            if(rhs?(rhs->getType() == "undefined"):false) {
                ERROR_N("Identifier in RHS has not yet been defined: ", string(rhsd->name), @3)
                exit(1);
            }
            if(isInScope(varLeft)) {
                ERROR_N("Redeclaration of variable: ", varLeft, @1);
                exit(1);
            } else {
                symInsert(scope_prefix+varLeft, rhs); //TODO check rhs type not "undefined"
                $$->code << new Instr(TAC::DECL,
                                      new Place(scope_prefix + varLeft));
            }
            lhs = lhs->next;
            rhs = rhs->next;
            rhsd = rhsd?rhsd->next:rhsd;
        }
        Data* parentleft = new Data("list");
        Data* parentright = new Data("list");
        parentleft->child = $1->data;
        parentright->child = $3->data;
        parentleft->next = parentright;
        $$->data = new Data{":="};
        $$->data->child = parentleft;
      }
    ;

Declaration:
    TypeDecl {
        $$ = &(init() << $1 >> "Declaration");
        $$->data = $1->data;
        COPS($$, $1);
    }
    | VarDecl  {
        $$ = &(init() << $1 >> "Declaration");
        COPS($$, $1);
    }
    ;

FunctionDecl:
    FUNC IDENT OPENB Signature CLOSEB {
        $$ = &(init() << $2 << $4 >> "FunctionDecl");
        symInsert(scope_prefix+$2, $4->type);
        $$->data = new Data("Function " + string($2));
    }
    | FUNC IDENT OPENB Signature { curFxnType = vectorToLinkedList(dynamic_cast<FunctionType*>($4->type)->retTypes); symInsert(scope_prefix+$2, $4->type); } Block CLOSEB {
        $$ = &(init() << $2 << $4 << $6 >> "FunctionDecl");

        $$->data = new Data("Function " + string($2));
        $$->data->child = $6->data;
        $$->code = TAC::Init() << new Instr(TAC::LABL, $2);
        $$->code << (new Instr(TAC::NEWFUNC));
        $$->code << $4->code << $6->code;
        $$->code << (new Instr(TAC::NEWFUNCEND));
        scopeExpr($$->code);
    }
    ;

Signature:
    Parameters          {
        $$ = &(init() << $1 >> "Signature");
        $$->data = new Data("params");
        $$->data->child = $1->data;
        $$->data->next = new Data("return");
        $$->data->next->child = NULL;

        vector<Type*> args;
        vector<Type*> rets;

        $$->code = TAC::Init();

        Type*ptr = $1->type;
        Data*dptr = $1->data;
        int i = 0;
        while(ptr != NULL) {
            Type* tmp = ptr->clone();
            tmp->next = NULL;
            args.push_back(tmp);

            // TODO We are assuming there are only primary idents here
            $$->code << new Instr(TAC::ARGDECL, to_std_string(i++), scope_prefix + dptr->name);

            ptr = ptr->next;
            dptr = dptr->next;
        }
        $$->type = new FunctionType(args, rets);
    }
    | Parameters Result {
        $$ = &(init() << $1 << $2 >> "Signature");
        $$->data = new Data("params");
        $$->data->child = $1->data;
        $$->data->next = new Data("return");
        $$->data->next->child = $2->data;

        vector<Type*> args;
        vector<Type*> rets;

        $$->code = TAC::Init();

        Type*ptr = $1->type;
        Data*dptr = $1->data;
        int i=0;
        while(ptr != NULL) {
            Type* tmp = ptr->clone();
            tmp->next = NULL;

            // TODO We are assuming there are only primary idents here
            $$->code << new Instr(TAC::ARGDECL, to_std_string(i++), scope_prefix + dptr->name);

            args.push_back(tmp);
            ptr = ptr->next;
            dptr = dptr->next;
        }

        ptr = $2->type;
        while(ptr != NULL) {
            Type* tmp = ptr->clone();
            tmp->next = NULL;
            rets.push_back(tmp);
            ptr = ptr->next;
        }

        $$->type = new FunctionType(args, rets);
    }
    ;

Result:
    '(' TypeList ')' {
        $$ = &(init() << $2 >> "Result");
        $$->data = $2->data;
        $$->type = $2->type;
    }
    | Type {
        $$ = &(init() << $1 >> "Result");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    ;

Parameters:
    '('  ')'                    {
        $$ = &(init() >> "Parameters");
        $$->data = NULL;
        $$->type = NULL;
    }
    | '(' ParameterList  ')'    {
        $$ = &(init() << $2 >> "Parameters");
        $$->data = $2->data;
        $$->type = $2->type;
      }
    | '(' ParameterList ',' ')' {
        $$ = &(init() << $2 >> "Parameters");
        $$->data = $2->data;
        $$->type = $2->type;
      }
    ;

ParameterList:
    ParameterDecl {
        $$ = &(init() << $1 >> "ParameterList");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    | ParameterList ',' ParameterDecl {
        $$ = &(init() << $1 << $3 >> "ParameterList");
        $$->data = $1->data;
        $$->type = $1->type;
        last($$->data)->next = $3->data;
        last($$->type)->next = $3->type;
    }
    ;

ParameterDecl:
    IdentifierList Type {
        $$ = &(init() << $1 << $2 >> "ParameterDecl");
        Data *data = $1->data;
        Type *type = $2->type->clone();
        $$->type = type;
        $$->data = data;
        while(data != 0) {
            if(isInScope(data->name)) {
                ERROR_N(data->name, " is already defined in this scope", @1);
                exit(1);
            }
            cout << "//" << $2->type << __LINE__ << " " << data->name << endl;
            symInsert(scope_prefix+data->name, $2->type);
            type->next = data->next ? type->clone() : NULL;
            type = type->next;
            data = data->next;
        }
    }
    ;

TypeList:
    TypeList ',' Type {
        $$ = &(init() << $1 << $3 >> "TypeList");
        $$->type = $1->type;
        $$->data = $1->data;
        $$->data->next = $3->data;
        $$->type->next = $3->type;
    }
    | Type {
        $$ = &(init() << $1 >> "TypeList");
        $$->type = $1->type;
        $$->data = $1->data;
    }
    ;

IdentifierList:
    IDENT {
        $$ = &(init() << $1 >> "IdentifierList");
        $$->data = new Data{$1};
        $$->type = getSymType($1)?getSymType($1):new BasicType("undefined");
    }
    | IdentifierList ',' IDENT {
        $$ = &(init() << $1 << $3 >> "IdentifierList");
        last($1->data)->next = new Data{$3};
        last($1->type)->next = (getSymType($3))?(getSymType($3)):(new BasicType("undefined"));
        $$->type = $1->type;
        $$->data = $1->data;
      }
    ;

QualifiedIdent:
    IDENT '.' IDENT {
        $$ = &(init() << $1 << $3 >> "QualifiedIdent");
        $$->data = new Data{ concat(concat($1, "."), $3) };
    }
    ;

MethodDecl:
    FUNC Receiver IDENT Signature  { $$ = &(init() << $2 << $3 << $4 >> "MethodDecl"); }
    /*| FUNC Receiver IDENT Function { $$ = &(init() << $2 << $3 << $4 >> "MethodDecl"); }*/
    ;

Receiver:
    Parameters { $$ = &(init() << $1 >> "Receiver"); }
    ;

TopLevelDeclList:
    TopLevelDeclList TopLevelDecl ';' {
        $$ = &(init() << $1 << $2 >> "TopLevelDeclList");
        $$->data = $1->data;
        last($$->data)->next = $2->data;
        $$->code = TAC::Init() << $1->code << $2->code;
    }
    | TopLevelDecl ';' {
        $$ = &(init() << $1 >> "TopLevelDeclList");
        $$->data = $1->data;
        $$->code = TAC::Init() << $1->code;
    }
    ;

CompositeLit:
    LiteralType LiteralValue {
        $$ = &(init() << $1 << $2 >> "CompositeLit");
        int elems;
        Type *iter;
        ArrayType* littypeArray;
        SliceType* littypeSlice;
        switch ($1->type->classType) {
            case ARRAY_TYPE:
                littypeArray = dynamic_cast<ArrayType*>($1->type);
                elems = 0;
                iter = $2->type;
                while (iter != NULL) {
                    if (iter->getType() != littypeArray->base->getType()) {
                        ERROR_N("Element of wrong type in array declaration: ",
                                iter->getType(), @2);
                    }
                    elems++;
                    iter = iter->next;
                }
                if (elems > littypeArray->size) {
                    ERROR_N("Wrong number of elements. Expected <=", elems, @2);
                }
                $$->data = new Data("ArrayLiteral");
                $$->data->child = new Data("Type");
                $$->data->child->next = new Data("Value");
                $$->data->child->child = $1->data;
                $$->data->child->next->child = $2->data;
                $$->type = $1->type->clone();
                $$->place = new Place($$->type);
                break;
            case SLICE_TYPE:
                littypeSlice = dynamic_cast<SliceType*>($1->type);
                iter = $2->type;
                while (iter != NULL) {
                    if (iter->getType() != littypeSlice->base->getType()) {
                        ERROR_N("Element of wrong type in array declaration: ",
                                iter->getType(), @2);
                    }
                    iter = iter->next;
                }
                $$->data = new Data("SliceLiteral");
                $$->data->child = new Data("Type");
                $$->data->child->next = new Data("Value");
                $$->data->child->child = $1->data;
                $$->data->child->next->child = $2->data;
                $$->type = $1->type->clone();
                $$->place = new Place($$->type);
            default:
                cerr << "Composite type not yet supported" << endl;
                exit(1);
        }
    }
;

LiteralType:
    StructType                 {
        $$ = &(init() << $1 >> "LiteralType");
        COPS($$, $1);
    }
    | ArrayType                {
        $$ = &(init() << $1 >> "LiteralType");
        COPS($$, $1);
    }
    /* | PointerType        { */
    /*     $$ = &(init() << $1 >> "Type"); */
    /*     $$->data = $1->data; */
    /*     $$->type = $1->type; */
    /*     $$->data = new Data($$->type->getType()); */
    /* } */
    | PointerType              {
        $$ = &(init() << $1 >> "LiteralType");
        COPS($$, $1);
    }
    | '[' DOTS ']' Operand     {
        $$ = &(init() << $2 << $4 >> "LiteralType");
    }
    | SliceType                {
        $$ = &(init() << $1 >> "LiteralType");
        COPS($$, $1);
    }
    | MapType                  {
        $$ = &(init() << $1 >> "LiteralType");
        COPS($$, $1);
    }
    ;

Type:
    LiteralType          {
        $$ = &(init() << $1 >> "Type");
        $$->data = $1->data;
        $$->type = $1->type;
        $$->data = new Data($$->type->getType());
    }
    | OperandName        {
        $$ = &(init() << $1 >> "Type");
        $$->data = $1->data;
        $$->type = new BasicType($1->data->name);
        /* if(!isType($1->data->name)) { */
        /*     ERROR_N("Invalid Type: ", $1->data->name, @1); */
        /*     exit(1); */
        /* } */
        $$->data = new Data($$->type->getType());
    }
    ;

Operand:
    Literal              {
        $$ = &(init() << $1 >> "Operand");
        COPS($$, $1);
    }
    | OperandName        {
        $$ = &(init() << $1 >> "Operand");
        COPS($$, $1);
    }
    | '(' Expression ')' {
        $$ = &(init() << $2 >> "Operand");
        COPS($$, $2);
      }
    ;

OperandName:
    IDENT            {
        $$ = &(init() << $1 >> "OperandName");
        $$->data = new Data{$1};
        $$->data->lValue = true;
        $$->type = getSymType($1)?getSymType($1):new BasicType("undefined");
        cout << scope_prefix + $1 << endl;
        $$->place = new Place($1);
        $$->code = TAC::Init();
        $$->data->lval = $$->place->name;
    }
    /* | QualifiedIdent { */
    /*     $$ = &(init() << $1 >> "OperandName"); */
    /*     $$->data = $1->data; */
    /* } */
    ;

LiteralValue:
    '{' '}'                        { $$ = &(init() >> "LiteralValue"); $$->data = new Data("Empty"); }
    | ECURLY '}'                   { $$ = &(init() >> "LiteralValue"); $$->data = new Data("Empty"); }
    | '{' ElementList '}'          { $$ = &(init() << $2 >> "LiteralValue"); COPS($$, $2); }
    | ECURLY ElementList '}'       { $$ = &(init() << $2 >> "LiteralValue"); COPS($$, $2); }
    | '{' ElementList ',' '}'      { $$ = &(init() << $2 >> "LiteralValue"); COPS($$, $2); }
    | ECURLY ElementList ',' '}'   { $$ = &(init() << $2 >> "LiteralValue"); COPS($$, $2); }
    ;

SliceType:
    '[' ']' Type  {
        $$ = &(init() << $3 >> "SliceType");
        $$->type = new SliceType($3->type);
        $$->data = new Data($$->type->getType());
    }
    ;

ElementList:
    KeyedElement                   { $$ = &(init() << $1 >> "ElementList"); COPS($$, $1); }
    | ElementList ',' KeyedElement {
        $$ = &(init() << $1 << $3 >> "ElementList");
        $$->data = $1->data;
        last($$->data)->next = $3->data;
        $$->type = $1->type;
        last($$->type)->next = $3->type;
        $$->place = $1->place;
        last($$->place)->next = $3->place;
    }
    ;

KeyedElement:
    Element                        { $$ = &(init() << $1 >> "KeyedElement"); COPS($$, $1); }
    | Key ':' Element              {
        $$ = &(init() << $1 << $3 >> "KeyedElement");
    }
    ;

Key:
    Expression   { $$ = &(init() << $1 >> "Key"); }
    | LiteralValue { $$ = &(init() << $1 >> "Key"); }
    ;

Element:
    Expression     { $$ = &(init() << $1 >> "Element"); COPS($$, $1); }
    | LiteralValue { $$ = &(init() << $1 >> "Element"); COPS($$, $1); }
    ;

TopLevelDecl:
    Declaration    { $$ = &(init() << $1 >> "TopLevelDecl"); COPS($$, $1); }
    | FunctionDecl {
        $$ = &(init() << $1 >> "TopLevelDecl");
        COPS($$, $1);
    }
    | MethodDecl   { $$ = &(init() << $1 >> "TopLevelDecl"); }
    ;

LabeledStmt:
    IDENT ':' Statement {
        $$ = &(init() << $1 << $3 >> "LabeledStmt");
        $$->data = new Data("label-" + string($1));
        $$->data->child = $3->data;
    }
    ;

GoStmt:
    GO Expression {
        $$ = &(init() << $2 >> "GoStmt");
        $$->data = new Data(string($1));
        $$->data->child = $2->data;
    }
    ;

ReturnStmt:
    RETURN {
        $$ = &(init() >> "ReturnStmt");
        $$->data = new Data(string($1));
        $$->data->child = NULL;
        if (curFxnType != NULL) {
            ERROR("Function has a return type, cannot use untyped return", "");
            exit(1);
        }
        $$->code = TAC::Init() << new Instr(TAC::RET);
    }
    | RETURN ExpressionList {
        $$ = &(init() << $2 >> "ReturnStmt");
        $$->data = new Data(string($1));
        $$->data->child = $2->data;

        auto placeptr = $2->place;

        auto parallel = new Place();
        auto parllptr = parallel;

        $$->code = TAC::Init();
        $$->code << $2->code;
        if (curFxnType == NULL) {
            ERROR("Function has no return type provided", "");
            exit(1);
        }
        Type *rT = curFxnType, *eT = $2->type;
        while (rT != NULL || eT != NULL) {
            if (rT == NULL || eT == NULL) {
                ERROR("Different number of return values than expected", "");
                exit(1);
            }
            if (rT->getType() != eT->getType()) {
                ERROR("Mismatching return types. Expected " + rT->getType() + " and got ", eT->getType());
                exit(1);
            }
            parllptr->next = new Place(eT);
            $$->code << new Instr(TAC::STOR, placeptr, parllptr->next);
            rT = rT->next;
            eT = eT->next;
            placeptr = placeptr->next;
            parllptr = parllptr->next;
        }
        rT = curFxnType;
        $2->place = parallel->next;
        eT = $2->type;
        placeptr = $2->place;
        $$->code << new Instr(TAC::RETSETUP);
        vector<Instr*> insArr;
        while (rT != NULL || eT != NULL) {
            insArr.push_back(new Instr(TAC::PUSHRET, placeptr));
            rT = rT->next;
            eT = eT->next;
            placeptr = placeptr->next;
        }
        std::reverse(insArr.begin(), insArr.end());

        for(auto it: insArr) {
            $$->code << it;
        }
        $$->code << new Instr(TAC::RETEND);
        scopeExpr($$->code);
    }
    ;

BreakStmt:
    BREAK {
        $$ = &(init() >> "BreakStmt");
        $$->data = new Data(string($1));
        if (breaklabels.empty()) {
            cout << "Something is wrong. Breaklabels is empty" << endl;
            exit(1);
        }
        $$->code = TAC::Init() <<
            new Instr(TAC::JMP, new Place(breaklabels.top()));
    }
    | BREAK IDENT {
        $$ = &(init() << $2 >> "BreakStmt");
        $$->data = new Data(string($1));
        $$->data->child = new Data($2);
        $$->code = TAC::Init() <<
            new Instr(TAC::JMP, new Place("<unimplemented>"));
    }
    ;

ContinueStmt:
    CONT         {
        $$ = &(init() >> "ContinueStmt");
        $$->data = new Data(string($1));
        $$->code = TAC::Init() << new Instr(TAC::JMP, new Place(nextlabels.top()));
    }
    | CONT IDENT {
        $$ = &(init() << $2 >> "ContinueStmt");
        $$->data = new Data(string($1));
        $$->data->child = new Data($2);
    }
    ;

GotoStmt:
    GOTO IDENT   {
        $$ = &(init() << $2 >> "GotoStmt");
        $$->data = new Data(string($1));
        $$->data->child = new Data($2);
    }
    ;

IfStmt:
    IF OPENB Expression Block CLOSEB {
        $$ = &(init() << $3 << $4 >> "IfStmt");
        $$->type = NULL;
        $$->data = new Data("If");
        Data *ptr = $$->data;
        ptr->child = new Data("Condition"); ptr = ptr->child;
        ptr->child = $3->data;
        ptr->next = new Data("Body"); ptr = ptr->next;
        ptr->child = $4->data;

        if ($3->type->getType() != "bool") {
            ERROR_N("If expression has to be boolean, found: ",
                    $3->type->getType(), @3);
        }

        $$->code = TAC::Init() << $3->code <<
            new Instr(TAC::JEQZ, $3->place, new Place(newlabel())) <<
            $4->code << new Instr(TAC::LABL, newlabel());
        scopeExprClosed($$->code);
        label_id++;
    }
    | IF OPENB SimpleStmt ';' Expression Block CLOSEB {
        $$ = &(init() << $3 << $5 << $6 >> "IfStmt");
        $$->data = new Data("If");
        Data *ptr = $$->data;
        ptr->child = new Data("Statement"); ptr = ptr->child;
        ptr->child = $3->data;
        ptr->next = new Data("Condition"); ptr = ptr->next;
        ptr->child = $5->data;
        ptr->next = new Data("Body"); ptr = ptr->next;
        ptr->child = $6->data;

        if ($5->type->getType() != "bool") {
            ERROR_N("If expression has to be boolean, found: ",
                    $3->type->getType(), @3);
        }

        $$->code = TAC::Init() << $3->code << $5->code <<
            new Instr(TAC::JEQZ, $5->place,
                      new Place(NULL, newlabel())) << $6->code <<
            new Instr(TAC::LABL, newlabel());
        scopeExprClosed($$->code);
        label_id++;
    }
    | IF OPENB Expression Block ELSE Block CLOSEB {
        $$ = &(init() << $3 << $4 << $6 >> "IfStmt");
        $$->data = new Data("If");
        Data *ptr = $$->data;
        ptr->child = new Data("Condition"); ptr = ptr->child;
        ptr->child = $3->data;
        ptr->next = new Data("Body"); ptr = ptr->next;
        ptr->child = $4->data;
        ptr->next = new Data("Else"); ptr = ptr->next;
        ptr->child = $6->data;


        if ($3->type->getType() != "bool") {
            ERROR_N("If expression has to be boolean, found: ",
                    $3->type->getType(), @3);
        }

        string lbl1 = newlabel(); label_id++;
        string lbl2 = newlabel(); label_id++;
        $$->code = TAC::Init() << $3->code <<
            new Instr(TAC::JEQZ, $3->place, new Place(lbl1)) <<
            $4->code <<
            new Instr(TAC::JMP, new Place(lbl2)) <<
            new Instr(TAC::LABL, lbl1) <<
            $6->code <<
            new Instr(TAC::LABL, lbl2);
        scopeExprClosed($$->code);
    }
    | IF OPENB Expression Block ELSE IfStmt CLOSEB {
        $$ = &(init() << $3 << $4 << $6 >> "IfStmt");
        $$->data = new Data("If");
        Data *ptr = $$->data;
        ptr->child = new Data("Condition"); ptr = ptr->child;
        ptr->child = $3->data;
        ptr->next = new Data("Body"); ptr = ptr->next;
        ptr->child = $4->data;
        ptr->next = new Data("Else"); ptr = ptr->next;
        ptr->child = $6->data;

        if ($3->type->getType() != "bool") {
            ERROR_N("If expression has to be boolean, found: ",
                    $3->type->getType(), @3);
        }

        string lbl1 = newlabel(); label_id++;
        string lbl2 = newlabel(); label_id++;
        $$->code = TAC::Init() << $3->code <<
            new Instr(TAC::JEQZ, $3->place, new Place(lbl1)) <<
            $4->code <<
            new Instr(TAC::JMP, new Place(lbl2)) <<
            new Instr(TAC::LABL, lbl1) <<
            $6->code <<
            new Instr(TAC::LABL, lbl2);
        scopeExprClosed($$->code);
    }
    | IF OPENB SimpleStmt ';' Expression Block ELSE IfStmt CLOSEB {
        $$ = &(init() << $3 << $5 << $6 << $8 >> "IfStmt");
        $$->data = new Data("If");
        Data *ptr = $$->data;
        ptr->child = new Data("Statement"); ptr = ptr->child;
        ptr->child = $3->data;
        ptr->next = new Data("Condition"); ptr = ptr->next;
        ptr->child = $5->data;
        ptr->next = new Data("Body"); ptr = ptr->next;
        ptr->child = $6->data;
        ptr->next = new Data("Else"); ptr = ptr->next;
        ptr->child = $8->data;

        string lbl1 = newlabel(); label_id++;
        string lbl2 = newlabel(); label_id++;
        $$->code = TAC::Init() << $3->code <<
            $5->code <<
            new Instr(TAC::JEQZ, $5->place, new Place(lbl1)) <<
            $6->code <<
            new Instr(TAC::JMP, new Place(lbl2)) <<
            new Instr(TAC::LABL, lbl1) <<
            $8->code <<
            new Instr(TAC::LABL, lbl2);
        scopeExprClosed($$->code);
    }
    | IF OPENB SimpleStmt ';' Expression Block ELSE Block CLOSEB {
        $$ = &(init() << $3 << $5 << $6 << $8 >> "IfStmt");
        $$->data = new Data("If");
        Data *ptr = $$->data;
        ptr->child = new Data("Statement"); ptr = ptr->child;
        ptr->child = $3->data;
        ptr->next = new Data("Condition"); ptr = ptr->next;
        ptr->child = $5->data;
        ptr->next = new Data("Body"); ptr = ptr->next;
        ptr->child = $6->data;
        ptr->next = new Data("Else"); ptr = ptr->next;
        ptr->child = $8->data;

        string lbl1 = newlabel(); label_id++;
        string lbl2 = newlabel(); label_id++;
        $$->code = TAC::Init() << $3->code <<
            $5->code <<
            new Instr(TAC::JEQZ, $5->place, new Place(lbl1)) <<
            $6->code <<
            new Instr(TAC::JMP, new Place(lbl2)) <<
            new Instr(TAC::LABL, lbl1) <<
            $8->code <<
            new Instr(TAC::LABL, lbl2);
        scopeExprClosed($$->code);
    }
    ;

EmptyExpr:
     /*empty*/ {
        $$ = &(init() >> "EmptyExpr");
        $$->data = new Data{"true"};
        $$->type = new BasicType("bool");
        $$->place = new Place($$->type, "1");
     }

Empty:
     /**/ {

    }

ForStmt:
       FOR OPENB SimpleStmt ';' BrkBlk ExpressionStmt ';' SimpleStmt Block BrkBlkEnd CLOSEB {
            $$ = &(init() << $3 << $6 << $8 << $9 >> "ForStmt");
            $$->data = new Data("For");
            $$->data->child = new Data("Body");
            $$->data->child->child = $9->data;

            string lbl1 = newlabel(); label_id++;
            string lbl2 = newlabel(); label_id++;

            $$->code = TAC::Init();
            $$->code << $3->code;                                         // Prelude
            $$->code << new Instr(TAC::LABL, new Place(lbl1));            // Label for next loop
            $$->code << $6->code;                                         // Condition
            $$->code << new Instr(TAC::CMP, new Place("0"), $6->place);   // Compare condition
            $$->code << new Instr(TAC::JE, lbl2);                         // If false (=0) jump to label2
            $$->code << $9->code;                                         // Block code
            $$->code << $5->code;
            $$->code << $8->code;                                         // Post statement
            $$->code << new Instr(TAC::JMP, lbl1);
            $$->code << $10->code;
            $$->code << new Instr(TAC::LABL, new Place(lbl2));
       }
       | FOR OPENB Expression BrkBlk Block BrkBlkEnd CLOSEB {
            $$ = &(init() << $3 << $5 >> "ForStmt");
            $$->data = new Data("For");
            Data *ptr = $$->data;
            ptr->child = new Data("Condition"); ptr = ptr->child;
            ptr->child = $3->data;
            ptr->next = new Data("Body"); ptr = ptr->next;
            ptr->child = $5->data;

            string lbl1 = newlabel(); label_id++;
            string lbl2 = newlabel(); label_id++;

            $$->code = TAC::Init();
            $$->code << new Instr(TAC::LABL, new Place(lbl1));            // Label for next loop
            $$->code << $3->code;
            $$->code << new Instr(TAC::CMP, "0", $3->place->name);
            $$->code << new Instr(TAC::JE, new Place(lbl2));
            $$->code << $5->code;
            $$->code << $4->code;
            $$->code << new Instr(TAC::JMP, lbl1);
            $$->code << $6->code;
            $$->code << new Instr(TAC::LABL, new Place(lbl2));
       }
       | FOR BrkBlk Block BrkBlkEnd {
            $$ = &(init() << $3 >> "ForStmt");
            $$->data = new Data("For");
            $$->data->child = new Data("Body");
            $$->data->child->child = $3->data;
            string lbl = newlabel(); label_id++;
            $$->code = TAC::Init() <<
                new Instr(TAC::LABL, new Place(lbl)) <<
                $3->code <<
                $2->code <<
                new Instr(TAC::JMP, new Place(lbl)) <<
                $4->code;
       }
       | FOR OPENB SimpleStmt ';' BrkBlk EmptyExpr ';' SimpleStmt Block BrkBlkEnd CLOSEB {
            $$ = &(init() << $3 << $6 << $8 << $9 >> "ForStmt");
            $$->data = new Data("For");
            $$->data->child = new Data("Body");
            $$->data->child->child = $9->data;

            string lbl1 = newlabel(); label_id++;
            string lbl2 = newlabel(); label_id++;

            $$->code = TAC::Init();
            $$->code << $3->code;                                         // Prelude
            $$->code << $5->code;                                         // Label for continue
            $$->code << new Instr(TAC::LABL, new Place(lbl1));            // Label for next loop
            $$->code << $6->code;                                         // Condition
            $$->code << new Instr(TAC::CMP, new Place("0"), $6->place);   // Compare condition
            $$->code << new Instr(TAC::JE, lbl2);                         // If false (=0) jump to label2
            $$->code << $9->code;                                         // Block code
            $$->code << $8->code;                                         // Post statement
            $$->code << new Instr(TAC::JMP, lbl1);                        // If false (=0) jump to label2
            $$->code << $10->code;                                        // Break label
            $$->code << new Instr(TAC::LABL, new Place(lbl2));
       }
       | FOR OPENB EmptyStmt Empty BrkBlk Expression Empty EmptyStmt Block BrkBlkEnd CLOSEB {
            $$ = &(init() << $3 << $6 << $8 << $9 >> "ForStmt");
            $$->data = new Data("For");
            $$->data->child = new Data("Body");
            $$->data->child->child = $9->data;

            string lbl1 = newlabel(); label_id++;
            string lbl2 = newlabel(); label_id++;

            $$->code = TAC::Init();
            $$->code << $3->code;                                         // Prelude
            $$->code << $5->code;                                         // Label for continue
            $$->code << new Instr(TAC::LABL, new Place(lbl1));            // Label for next loop
            $$->code << $6->code;                                         // Condition
            $$->code << new Instr(TAC::CMP, new Place("0"), $6->place);   // Compare condition
            $$->code << new Instr(TAC::JE, lbl2);                         // If false (=0) jump to label2
            $$->code << $9->code;                                         // Block code
            $$->code << $8->code;                                         // Post statement
            $$->code << new Instr(TAC::JMP, lbl1);                        // If false (=0) jump to label2
            $$->code << $10->code;                                        // Break label
            $$->code << new Instr(TAC::LABL, new Place(lbl2));
       };


//ForStmt:
//    FOR BrkBlk Block BrkBlkEnd {
//        $$ = &(init() << $3 >> "ForStmt");
//        $$->data = new Data("For");
//        $$->data->child = new Data("Body");
//        $$->data->child->child = $3->data;
//        string lbl = newlabel(); label_id++;
//        $$->code = TAC::Init() <<
//            new Instr(TAC::LABL, new Place(lbl)) <<
//            $3->code <<
//            new Instr(TAC::JMP, new Place(lbl)) <<
//            $4->code;
//    }
//    | FOR OPENB Expression BrkBlk Block BrkBlkEnd CLOSEB {
//        $$ = &(init() << $3 << $5 >> "ForStmt");
//        $$->data = new Data("For");
//        Data *ptr = $$->data;
//        ptr->child = new Data("Condition"); ptr = ptr->child;
//        ptr->child = $3->data;
//        ptr->next = new Data("Body"); ptr = ptr->next;
//        ptr->child = $5->data;
//        string lbl = newlabel(); label_id++;
//        $$->code = TAC::Init();
//        $$->code << new Instr(TAC::LABL, new Place(lbl));
//        $$->code << $3->code;
//        $$->code << new Instr(TAC::CMP, "0", $3->place);
//        $$->code << new Instr(TAC::JMP, new Place(lbl));
//        $$->code << $6->code;
//    }
//    | FOR OPENB ForClause Block CLOSEB {
//        $$ = &(init() << $3 << $4 >> "ForStmt");
//        $$->data = new Data("For");
//        Data *ptr = $$->data;
//        ptr->child = $3->data;
//        ptr->next = new Data("Body"); ptr = ptr->next;
//        ptr->child = $4->data;
//    }
//    | FOR OPENB RangeClause Block CLOSEB {
//        $$ = &(init() << $3 << $4 >> "ForStmt");
//        $$->data = new Data("For");
//        Data *ptr = $$->data;
//        ptr->child = $3->data;
//        ptr->next = new Data("Body"); ptr = ptr->next;
//        ptr->child = $4->data;
//    }
//    ;
//
//ForClause:
//    SimpleStmt ';'  ';' SimpleStmt  {
//        $$ = &(init() << $1 << $4 >> "ForClause");
//        $$->data = new Data("ForClause");
//        Data *ptr = $$->data;
//        ptr->child = new Data("InitClause"); ptr = ptr->child;
//        ptr->child = $1->data;
//        ptr->next = new Data("PostClause"); ptr = ptr->next;
//        ptr->child = $4->data;
//    }
//    | SimpleStmt ';' Expression ';' SimpleStmt  {
//        $$ = &(init() << $1 << $3  << $5 >> "ForClause");
//        $$->data = new Data("ForClause");
//        Data *ptr = $$->data;
//        ptr->child = new Data("InitClause"); ptr = ptr->child;
//        ptr->child = $1->data;
//        ptr->next = new Data("ConditionClause"); ptr = ptr->next;
//        ptr->child = $3->data;
//        ptr->next = new Data("PostClause"); ptr = ptr->next;
//        ptr->child = $5->data;
//
//
//        if ($3->type->getType() != "bool") {
//            ERROR_N("For expression has to be boolean, found: ",
//                    $3->type->getType(), @3);
//        }
//    }
//    ;

RangeClause:
    RANGE Expression  {
        $$ = &(init() << $2 >> "RangeClause");
        $$->data = new Data("RangeClause");
        Data *ptr = $$->data;
        ptr->child = new Data("Expression"); ptr = ptr->child;
        ptr->child = $2->data;
    }
    | ExpressionList DECL RANGE Expression  {
        $$ = &(init() << $1 << $4 >> "RangeClause");
        $$->data = new Data("RangeClause");
        Data *ptr = $$->data;
        ptr->child = new Data("NewExpressionList"); ptr = ptr->child;
        ptr->child = $1->data;
        ptr->next = new Data("RangeExpr"); ptr = ptr->next;
        ptr->child = $4->data;
    }
    | ExpressionList '=' RANGE Expression  {
        $$ = &(init() << $1 << $4 >> "RangeClause");
        $$->data = new Data("RangeClause");
        Data *ptr = $$->data;
        ptr->child = new Data("ExpressionList"); ptr = ptr->child;
        ptr->child = $1->data;
        ptr->next = new Data("RangeExpr"); ptr = ptr->next;
        ptr->child = $4->data;
    }
    ;

// InitStmt:
//     SimpleStmt  { $$ = &(init() << $1 >> "InitStmt"); $$->data = $1->data; }
//     ;

// PostStmt:
//     SimpleStmt  { $$ = &(init() << $1 >> "PostStmt"); $$->data = $1->data; }
//     ;

// Condition:
//     Expression  { $$ = &(init() << $1 >> "Condition"); $$->data = $1->data; }
//     ;

DeferStmt:
    DEFER Expression  {
        $$ = &(init() << $2 >> "DeferStmt");
        $$->data = new Data(string($1));
        $$->data->child = $2->data;
    }
    ;

Expression:
    Expression1 {
        $$ = &(init() << $1 >> "Expression");
        COPS($$, $1);
    }
    ;

Expression1:
    Expression1 B1 Expression2 {
        $$ = &(init() << $1 << $2 << $3 >> "Expression1");
        HANDLE_AND_OR_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression2 {
        $$ = &(init() << $1 >> "Expression2");
        COPS($$, $1);
    }
    ;

Expression2:
    Expression2 B2 Expression3 {
        $$ = &(init() << $1 << $2 << $3 >> "Expression2");
        HANDLE_AND_OR_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression3 {
        $$ = &(init() << $1 >> "Expression2");
        COPS($$, $1);
    }
    ;

Expression3:
    Expression3 B3 Expression4 {
        $$ = &(init() << $1 << $2 << $3 >> "Expression3");
        HANDLE_REL_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression4 {
        $$ = &(init() << $1 >> "Expression3");
        COPS($$, $1);
    }
    ;

Expression4:
    Expression4 B4 Expression5 {
        $$ = &(init() << $1 << $2 << $3 >> "Expression4");
        HANDLE_BIN_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression4 D4 Expression5 {
        $$ = &(init() << $1 << $2 << $3 >> "Expression4");
        HANDLE_BIN_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression5 {
        $$ = &(init() << $1 >> "Expression4");
        COPS($$, $1);
    }
    ;

Expression5:
    Expression5 B5 PrimaryExpr {
        $$ = &(init() << $1 << $2 << $3 >> "Expression5");
        HANDLE_BIN_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression5 D5 PrimaryExpr {
        $$ = &(init() << $1 << $2 << $3 >> "Expression5");
        HANDLE_BIN_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression5 STAR PrimaryExpr {
        $$ = &(init() << $1 << $2 << $3 >> "Expression5");
        HANDLE_BIN_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | UnaryExpr {
        $$ = &(init() << $1 >> "Expression5");
        COPS($$, $1);
    }
    ;

UnaryExpr:
    PrimaryExpr {
        $$ = &(init() << $1 >> "UnaryExpr");
        COPS($$, $1);
    }
    | UnaryOp PrimaryExpr {
        $$ = &(init() << $1 << $2 >> "UnaryExpr");
        $$->data = new Data($1->data->name + "unary");
        $$->data->child = $2->data;
        $$->code = TAC::Init() << $2->code;
        if($$->data->name == "&unary") {
            $$->type = new PointerType($2->type);
            auto tmpPlace = new Place($$->type);
            $$->code << (new Instr(TAC::opToOpcode($$->data->name),
                                   $2->place, tmpPlace));
            $$->place = tmpPlace;
        } else if($$->data->name == "*unary") {
            if($2->type->classType != POINTER_TYPE) {
                ERROR_N("Attempting to dereference a non pointer: ", "", @2);
            }
            $$->type = dynamic_cast<PointerType*>($2->type)->BaseType->clone();
            auto tmpPlace = new Place($$->type);
            $$->code << (new Instr(TAC::DEREF, $2->place, tmpPlace));
            $$->place = tmpPlace;
        } else {
            $$->type = $2->type->clone();
            auto tmpPlace = new Place($$->type);
            $$->code << (new Instr(TAC::STOR, $2->place, tmpPlace));
            $$->code << (new Instr(TAC::opToOpcode($$->data->name), tmpPlace));
            $$->place = tmpPlace;
        }
    }
    ;

PrimaryExpr:
    Operand {
        $$ = &(init() << $1 >> "PrimaryExpr");
        COPS($$, $1);
    }
    | MakeExpr {
        $$ = &(init() << $1 >> "PrimaryExpr");
        COPS($$, $1);
    }
    | PrimaryExpr Selector {
        $$ = &(init() << $1 << $2 >> "PrimaryExpr");
        $$->type = isValidMemberOn($1->type, $1->data, $2->data);
        $$->data = new Data("MemberAccess");
        $$->data->child = $1->data;
        $$->data->child->next = $2->data;
        $$->data->lValue = true;
        $$->place =
            new Place($1->place->toString() + "." + $2->place->toString());
        $$->data->lval = $$->place->name;
        $$->code = TAC::Init() << $1->code;
    }
    | PrimaryExpr Index {
        $$ = &(init() << $1 << $2 >> "PrimaryExpr");
        Type*tp = $1->type;
        if (tp->classType == POINTER_TYPE) {
            tp = dynamic_cast<PointerType*>(tp)->BaseType;
        }

        if(tp->classType == SLICE_TYPE) {
            SliceType *itp = (SliceType*) tp;
            $$->type = itp->base->clone();
            if($2->type->getType() != "int") {
                ERROR_N("Non integer index provided", "", @2);
                exit(1);
            }
        } else if(tp->classType == ARRAY_TYPE) {
            ArrayType *itp = (ArrayType*) tp;
            $$->type = itp->base->clone();
            cout << "RESOLVED for " << $1->type->getType() << " to " << $$->type->getType() << endl;
            if($2->type->getType() != "int") {
                ERROR_N("Non integer index provided", "", @2);
                exit(1);
            }
        } else if(tp->classType == MAP_TYPE) {
            MapType *itp = (MapType*) tp;
            if($2->type->getType() != itp->key->getType()) {
                ERROR_N("Index of type " + $2->type->getType() +
                        " provided, when needed was: ", itp->key->getType(), @2);
                exit(1);
            }
            // No global type sent
        } else {
            ERROR("It is not possible to use index on something of type: ",
                  tp->getType());
            exit(1);
        }
        /* $$->data = new Data("arrayaccess"); */
        /* $$->data->child = $1->data; */
        /* $$->data->child->next = new Data("__VALUE_AT__"); */
        /* $$->data->child->next->next = $2->data; */
        $$->data = $1->data;
        $$->data->lValue = true;
        $$->code = TAC::Init() << $1->code << $2->code;

        auto lvalOfPrim = $1->data->lval;
        auto tmp = nameInScope(lvalOfPrim);
        if (tmp != "") lvalOfPrim = tmp;

        auto lvalOfIndex = $2->place->name;
        tmp = nameInScope(lvalOfIndex);
        if (tmp != "") lvalOfIndex = tmp;

        $$->place = new Place(lvalOfPrim + "[" + lvalOfIndex + "]");
        $$->data->lval = $$->place->name;
    }
    | PrimaryExpr Slice  { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr TypeAssertion { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr Arguments {
        $$ = &(init() << $1 << $2 >> "PrimaryExpr");
        $$->data = new Data("FunctionCall");
        $$->data->child = $1->data;
        $$->data->child->next = $2->data;
        auto isFFI = !strncmp($1->place->name.c_str(), "ffi.", 4);
        $$->type = resultOfFunctionApp($1->type, $2->type, isFFI);

        $$->code = TAC::Init() << $2->code << new Instr(TAC::CALL, $1->place);
        scopeExpr($$->code);
        auto retPtr = $$->type;
        auto placePtr = new Place("");
        $$->place = placePtr;

        while(retPtr != NULL) {
            auto tmpPlace = new Place(retPtr);
            placePtr->next = tmpPlace;
            $$->code << new Instr(TAC::POP, tmpPlace);
            retPtr = retPtr->next;
            placePtr = placePtr->next;
        }
        $$->place = $$->place->next;

        Type *tmp = $$->type;
        Place *rtmp = $$->place;
        int cnt = 0;
        while (tmp != NULL) {
            if (cnt == 0) {
                rtmp = new Place("$esp");
            } else {
                rtmp = new Place("$esp + " + to_std_string(cnt*4));
            }
            tmp = tmp->next;
            rtmp = rtmp->next;
            cnt++;
        }
        $$->data->lValue = false;
    }
    | OperandName StructLiteral { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    ;

StructLiteral:
    '{' KeyValList '}' { $$ = &(init() << $2 >> "StructLiteral"); }
    ;

KeyValList:
    /* empty */  { $$ = &(init() >> "KeyValList"); }
    | Expression ':' Expression { $$ = &(init() << $1 << $3 >> "KeyValList"); }
    | Expression ':' Expression ',' KeyValList { $$ = &(init() << $1 << $3 << $5 >> "KeyValList"); }

MakeExpr:
    MAKE '(' Type ',' Expression ',' Expression ')' {
        $$ = &(init() << $3 << $5 << $7 >> "MakeExpr");
        $$->type = $3->type;
        $$->data = new Data("Make");
        $$->data->child = $5->data;
        $$->data->child->next = $7->data;

        string lbl = newlabel(); label_id++;
        $$->code = TAC::Init() <<
            new Instr(TAC::MAKE, lbl, $3->type->getType());
        $$->place = new Place(lbl);
    }
    | MAKE '(' Type ',' Expression ')' {
        $$ = &(init() << $3 << $5 >> "MakeExpr");
        $$->type = $3->type;
        $$->data = new Data("Make");
        $$->data->child = $5->data;

        string lbl = newlabel(); label_id++;
        $$->code = TAC::Init() <<
            new Instr(TAC::MAKE, lbl, $3->type->getType());
        $$->place = new Place(lbl);
    }
    | MAKE '(' Type ')' {
        $$ = &(init() << $3 >> "MakeExpr");
        $$->type = $3->type;
        $$->data = new Data("Make");

        string lbl = newlabel(); label_id++;
        $$->code = TAC::Init() <<
            new Instr(TAC::MAKE, lbl, $3->type->getType());
        $$->place = new Place(lbl);
    }
    | NEW '(' Type ')' {
        $$ = &(init() << $3 >> "NewExpr");
        $$->type = new PointerType($3->type);
        $$->data = new Data("New");

        $$->place = new Place($$->type);
        $$->code = TAC::Init() <<
            new Instr(TAC::NEW, $3->type->getType(), $$->place->name);
    }
    ;

Selector:
    '.' IDENT  {
        $$ = &(init() << $2 >> "Selector");
        $$->data = new Data(string($2));
        $$->place = new Place($2);
    }
    ;

Index:
    '[' Expression ']'  {
        $$ = &(init() << $2 >> "Index");
        COPS($$, $2);
    }
    ;

Slice:
    '[' ':' ']'  { $$ = &(init() >> "Slice"); }
    | '[' ':' Expression ']'  { $$ = &(init() << ":" << $3 >> "Slice"); }
    | '[' Expression ':' ']'  { $$ = &(init() << $2 << ":" >> "Slice"); }
    | '[' Expression ':' Expression ']'  { $$ = &(init() << $2 << ":" << $4 >> "Slice"); }
    | '[' ':' Expression ':' Expression ']'  { $$ = &(init() << ":" << $3 << ":" << $5 >> "Slice"); }
    | '[' Expression ':' Expression ':' Expression ']'  { $$ = &(init() << $2 << ":" << $4 << ":" << $6 >> "Slice"); }
    ;

TypeDecl:
    TYPE TypeSpec  { $$ = &(init() << $2 >> "TypeDecl"); COPS($$, $2); }
    ;

TypeSpec:
    IDENT Type {
        $$ = &(init() << $1 << $2 >> "TypeSpec");
        typeInsert(string($1), $2->type);
        $$->data = new Data("TypeSpec");
        $$->code = TAC::Init();
    }
    ;

TypeAssertion:
    '.' '(' Type ')'  { $$ = &(init() << $3 >> "TypeAssertion"); }
    ;

Arguments:
    '(' ')'                       { $$ = &(init() >> "Arguments"); }
    | '(' ExpressionList ')'      {
        $$ = &(init() << $2 >> "Arguments");
        COPS($$, $2);
        Place *tmp = $2->place;
        $$->code = TAC::Init() << $2->code;
        int i=0;
        while (tmp != NULL) {
            /*$$->code << new Instr(TAC::PUSH, tmp->name);*/
            $$->code << new Instr(TAC::PUSHARG, to_std_string(i++), tmp->name);
            tmp = tmp->next;
        }
    }
    | '(' ExpressionList DOTS ')' {
        $$ = &(init() << $2 << $3 >> "Arguments"); COPS($$, $2);
        Place *tmp = $2->place;
        $$->code = TAC::Init() << $2->code;
        int i=0;
        while (tmp != NULL) {
            $$->code << new Instr(TAC::PUSHARG, to_std_string(i++), tmp->name);
            tmp = tmp->next;
        }
    }
    ;

ExpressionList:
    Expression                      {
        $$ = &(init() << $1 >> "ExpressionList");
        COPS($$, $1);
    }
    | ExpressionList ',' Expression {
        $$ = &(init() << $1 << $3 >> "ExpressionList");
        $$->data = $1->data;
        last($$->data)->next = $3->data;
        $$->type = $1->type;
        last($$->type)->next = $3->type;
        $$->place = $1->place;
        last($$->place)->next = $3->place;
        $$->code = TAC::Init() << $1->code << $3->code;
    }
    ;

MapType:
    MAP '[' Type ']' Type {
        $$ = &(init() << $1 << $3 << $5 >> "MapType");
        $$->type = new MapType($3->type, $5->type);
    }
    ;

StructType:
    STRUCT '{' FieldDeclList '}' {
        $$ = &(init() << $1 << $3 >> "StructType");
        COPS($$, $3);
    }
    | STRUCT ECURLY FieldDeclList '}' {
        $$ = &(init() << $1 << $3 >> "StructType");
        COPS($$, $3);
    }
    | STRUCT '{' '}' {
        $$ = &(init() << $1 >> "StructType");
        $$->type = new StructType(*(new umap<string, Type*>));
    }
    | STRUCT ECURLY '}' {
        $$ = &(init() << $1 >> "StructType");
        $$->type = new StructType(*(new umap<string, Type*>));
    }
    ;

FieldDeclList:
    FieldDecl ';' {
        $$ = &(init() >> "FieldDeclList");
        COPS($$, $1);
    }
    | FieldDeclList FieldDecl ';' {
        $$ = &(init() << $1 << $2 >> "FieldDeclList");
        $$->data = $1->data;
        umap<string, Type *> mem1 = ((StructType*)$1->type)->members;
        umap<string, Type *> mem2 = ((StructType*)$2->type)->members;
        for(auto& it: mem2) {
            string key = it.first;
            if(mem1.find(key) != mem1.end()) {
                ERROR_N("Redeclaration of struct member: ", key, @2);
            }
            mem1[key] = it.second->clone();
        }
        $$->type = new StructType(mem1);
    }
    ;

FieldDecl:
    IdentifierList Type String {
        $$ = &(init() << $1 << $2 << $3 >> "FieldDecl");
        Type* tptr = $2->type;
        tptr->next = NULL;

        Data* lptr = $1->data;
        umap<string, Type *> mem;
        while(lptr != NULL) {
            mem[lptr->name] = tptr->clone();
            lptr = lptr->next;
        }
        $$->type = new StructType(mem);
    }
    | IdentifierList Type {
        $$ = &(init() << $1 << $2 >> "FieldDecl");
        Type* tptr = $2->type;
        tptr->next = NULL;

        Data* lptr = $1->data;
        umap<string, Type *> mem;
        while(lptr != NULL) {
            mem[lptr->name] = tptr->clone();
            lptr = lptr->next;
        }
        $$->type = new StructType(mem);
    }
    /* | AnonymousField Tag { $$ = &(init() << $1 << $2 >> "FieldDecl"); } */
    /* | AnonymousField { $$ = &(init() << $1 >> "FieldDecl"); } */
    ;

PointerType:
    STAR Type {
        $$ = &(init() << $1 << $2 >> "PointerType");
        COPS($$, $2);
        if ($2->type->getType() == "undefined") {
            $2->type = new BasicType($2->data->name);
        }
        $$->type = new PointerType($2->type->clone());
    }
    ;

ArrayType:
    '[' Expression ']' Type  {
        $$ = &(init() << $2 << $4 >> "ArrayType");
        if($2->type->getType() == "int") {
            if(isLiteral($2)) {
                int n = getIntValue($2);
                Type* tp = $4->type->clone();
                $$->type = new ArrayType(n, tp);
            } else {
                ERROR_N("Array Index is not a constant literal:\n",
                                        "\t\tMaybe you need a slice?", @2);
            }
        } else {
            ERROR_N("Index is not of type int", "", @2);
        }
    }
    ;

Literal:
    BasicLit {
        $$ = &(init() << $1 >> "Literal");
        COPS($$, $1);
    }
    | CompositeLit {
        $$ = &(init() << $1 >> "Literal");
        COPS($$, $1);
    }
    /* | FunctionLit */
    ;

BasicLit:
    INT         {
        $$ = &(init() << $1 >> "BasicLit");
        $$->data = new Data{$1};
        $$->type = new BasicType("int");
        $$->place = new Place($$->type, $1);
    }
    | FLOAT     {
        $$ = &(init() << $1 >> "BasicLit");
        $$->data = new Data{$1};
        $$->type = new BasicType("float");
        $$->place = new Place($$->type, $1);
    }
    | String    {
        $$ = &(init() << $1 >> "BasicLit");
        $$->data = $1->data;
        $$->type = new BasicType("string");
        $$->place = new Place($$->type, $1->place->name);
    }
    | TRUE {
        $$ = &(init() << $1 >> "BasicLit");
        $$->data = new Data{"$1"};
        $$->type = new BasicType("bool");
        $$->place = new Place("$1");
    }
    | FALSE {
        $$ = &(init() << $1 >> "BasicLit");
        $$->data = new Data{"$0"};
        $$->type = new BasicType("bool");
        $$->place = new Place("$0");
    }
    | NIL {
        $$ = &(init() << $1 >> "BasicLit");
        $$->data = new Data{"$0"};
        $$->type = new BasicType("nil");
        $$->place = new Place("$0");
    }
    ;

UnaryOp:
    UN_OP          {
        $$ = &(init() << $1 >> "UnaryOp");
        $$->data = new Data{$1};
    }
    | D4      {
        $$ = &(init() << $1 >> "UnaryOp");
        $$->data = new Data{$1};
    }
    | D5      {
        $$ = &(init() << $1 >> "UnaryOp");
        $$->data = new Data{$1};
    }
    | STAR {
        $$ = &(init() << $1 >> "UnaryOp");
        $$->data = new Data{$1};
    }
    ;

String:
    RAW_ST         {
        $$ = &(init() << $1 >> "String");
        $$->data = new Data{$1};
        $$->place = new Place(NULL, $1);
    }
    | INR_ST       {
        $$ = &(init() << $1 >> "String");
        $$->data = new Data{$1};
        $$->place = new Place(NULL, $1);
    }
    ;

PackageClause:
    PACKGE IDENT { $$ = &(init() << $2 >> "PackageClause"); }
    ;

ImportDeclList:
    /* empty */ { $$ = &(init() >> "ImportDeclList"); }
    | ImportDeclList ImportDecl ';' { $$ = &(init() << $1 << $2 >> "ImportDeclList"); }
    | ImportDecl ';' { $$ = &(init() << $1 >> "ImportDeclList"); }
    ;

ImportDecl:
    IMPORT '(' ImportSpecList ')' { $$ = &(init() << $3 >> "ImportDecl"); }
    | IMPORT ImportSpec { $$ = &(init() << $2 >> "ImportDecl"); }
    ;

ImportSpecList:
    /* empty */ { $$ = &(init() >> "ImportSpecList"); }
    | ImportSpecList ImportSpec ';' { $$ = &(init() << $1 << $2 >> "ImportSpecList"); }
    | ImportSpec ';' { $$ = &(init() << $1 >> "ImportSpecList"); }
    ;

ImportSpec:
    IDENT ImportPath { $$ = &(init() << $1 << $2 >> "ImportSpec"); }
    | '.' ImportPath { $$ = &(init() << $2 >> "ImportSpec"); }
    | ImportPath { $$ = &(init() << $1 >> "ImportSpec"); }
    ;

ImportPath:
    String { $$ = &(init() << $1 >> "ImportPath"); }
    ;
%%
