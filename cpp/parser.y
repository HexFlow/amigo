%{
#include <cstdio>
#include <sstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <string>
#include "../../cpp/node.h"
#define YYDEBUG 1
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);

int id = 0;

struct node {
    char name[100] = {0};
    vector<node *> children_nt;
    vector<char *> children_t;
};

node &operator<<(node &l, node *r) {
    l.children_nt.push_back(r);
    return l;
}

node &operator<<(node &l, char *r) {
    l.children_t.push_back(strdup(r));
    return l;
}

node &operator>>(node &l, const char *r) {
    strcpy(l.name, r);
    return l;
}

node &init() {
    node *n = new node();
    return *n;
}

string escape_json(const string &s) {
    ostringstream o;
    for (auto c = s.cbegin(); c != s.cend(); c++) {
        switch (*c) {
        case '"': o << "\\\""; break;
        case '\\': o << "\\\\"; break;
        case '\b': o << "\\b"; break;
        case '\f': o << "\\f"; break;
        case '\n': o << "\\n"; break;
        case '\r': o << "\\r"; break;
        case '\t': o << "\\t"; break;
        default:
            if ('\x00' <= *c && *c <= '\x1f') {
                o << "\\u"
                  << hex << setw(4) << setfill('0') << (int)*c;
            } else {
                o << *c;
            }
        }
    }
    return o.str();
}

string print(node* n) {
    int id1=0, id2=0;
    string name = "_" + to_string(id++);
    while(id1 < n->children_nt.size() || id2 < n->children_t.size()) {
        if(id1 < n->children_nt.size()) {
            string child = print(n->children_nt[id1++]);
            cout << name << " -- " << child << endl;
        }

        if(id2 < n->children_t.size()) {
            cout << "_" + to_string(id) <<
              "[label=\"" << escape_json(n->children_t[id2++]) << "\"]" << endl;
            cout << name << " -- " << "_" + to_string(id++) << endl;
        }
    }
    cout << name << "[label=\"" << n->name << "\"]" << endl;
    return name;
}

void printTop(node* n) {
    printf("graph {\n");
    print(n);
    printf("\n}");
}

%}

%union {
    node* nt;
    char *sval;
}

%token <sval> INT FLOAT IDENT BIN_OP DUAL_OP REL_OP MUL_OP ADD_OP UN_OP
%token <sval> RAW_ST INR_ST ASN_OP
%type <nt> Program Expression Block StatementList Statement SimpleStmt
%type <nt> EmptyStmt ExpressionStmt SendStmt Channel IncDecStmt
%type <nt> Assignment ShortVarDecl Declaration ConstDecl ConstSpecList
%type <nt> Signature Result Parameters ParameterList ParameterDecl
%type <nt> ConstSpec MethodDecl Receiver TopLevelDecl LabeledStmt
%type <nt> GoStmt ReturnStmt BreakStmt ContinueStmt GotoStmt
%type <nt> FallthroughStmt IfStmt SwitchStmt ExprSwitchStmt
%type <nt> ExprCaseClauseList ExprCaseClause ExprSwitchCase SelectStmt
%type <nt> CommClauseList CommClause CommCase RecvStmt RecvExpr
%type <nt> FunctionDecl FunctionName TypeSwitchStmt TypeCaseClauseList
%type <nt> TypeSwitchGuard TypeCaseClause TypeSwitchCase TypeList
%type <nt> Function FunctionBody ForStmt ForClause RangeClause InitStmt
%type <nt> PostStmt Condition DeferStmt Label UnaryExpr PrimaryExpr
%type <nt> Selector Index Slice TypeDecl TypeSpecList TypeSpec VarDecl
%type <nt> VarSpec VarSpecList TypeAssertion Arguments IdentifierList
%type <nt> ExpressionList Conversion Type TypeName TypeLit ArrayType
%type <nt> ArrayLength ElementType Operand Literal BasicLit OperandName
%type <nt> QualifiedIdent PackageName MethodExpr RecieverType
%type <nt> MethodName InterfaceTypeName UnaryOp BinaryOp String
%%
Program:
    ExpressionList { $$ = &(init() << $1 >> "Program"); printTop($$);}
    ;

Expression:
    UnaryExpr { $$ = &(init() << $1 >> "Expression"); }
    | Expression BinaryOp UnaryExpr {$$ = &(init() << $1 << $2 << $3 >> "Expression");}
    ;

Block:
    '{' StatementList '}'
    ;

StatementList:
    StatementList Statement ';'
    | Statement ';'
    ;

Statement:
    Declaration
    | LabeledStmt
    | SimpleStmt
    | GoStmt
    | ReturnStmt
    | BreakStmt
    | ContinueStmt
    | GotoStmt
    | FallthroughStmt
    | Block
    | IfStmt
    | SwitchStmt
    | SelectStmt
    | ForStmt
    | DeferStmt
    ;

SimpleStmt:
    EmptyStmt
    | ExpressionStmt
    | SendStmt
    | IncDecStmt
    | Assignment
    | ShortVarDecl
    ;

EmptyStmt:
    | /* blank */
    ;

ExpressionStmt:
    Expression
    ;

SendStmt:
    Channel "<-" Expression
    ;

Channel:
    Expression
    ;

IncDecStmt:
    Expression "++"
    Expression "--"
    ;

Assignment:
    ExpressionList ASN_OP ExpressionList
    ;

ShortVarDecl:
    IdentifierList ":=" ExpressionList
    ;


Declaration:
    ConstDecl
    | TypeDecl
    | VarDecl
    ;

ConstDecl:
    "const" ConstSpec
    "const" "(" ConstSpecList ")"
    ;

ConstSpecList:
    ConstSpecList ConstSpec ';'
    | ConstSpec ';'
    ;

Signature:
    Parameters 
    Parameters Result
    ;

Result:
    Parameters
    | Type
    ;

Parameters:
    "("  ")"
    "(" ParameterList  ")"
    "(" ParameterList "," ")"
    ;

ParameterList:
    ParameterDecl
    | ParameterList "," ParameterDecl
    ;

ParameterDecl:
    Type
    "..." Type
    IdentifierList Type
    IdentifierList "..." Type
    ;

ConstSpec:
	IdentifierList 
	| IdentifierList "=" ExpressionList
	| IdentifierList Type "=" ExpressionList
	;

MethodDecl:
    "func" Receiver MethodName Signature
    "func" Receiver MethodName Function
    ;

Receiver:
    Parameters
    ;

TopLevelDecl:
    Declaration
    | FunctionDecl
    | MethodDecl
    ;

LabeledStmt:
    Label ":" Statement
    ;

GoStmt:
    "go" Expression
    ;

ReturnStmt:
    "return"
    | "return" ExpressionList
    ;

BreakStmt:
    "break"
    | "break" Label
    ;

ContinueStmt:
    "continue"
    | "continue" Label
    ;

GotoStmt:
    "goto" Label
    ;

FallthroughStmt:
    "fallthrough"
    ;

IfStmt:
    "if" Expression Block
    | "if" SimpleStmt ";" Expression Block
    | "if" Expression Block "else" Block
    | "if" Expression Block "else" IfStmt
    | "if" SimpleStmt ";" Expression Block "else" IfStmt
    | "if" SimpleStmt ";" Expression Block "else" Block
    ;

SwitchStmt:
    ExprSwitchStmt
    | TypeSwitchStmt
    ;

ExprSwitchStmt:
    "switch" "{" ExprCaseClauseList "}"
    "switch" Expression "{" ExprCaseClauseList "}"
    "switch" SimpleStmt ";" "{" ExprCaseClauseList "}"
    "switch" SimpleStmt ";" Expression "{" ExprCaseClauseList "}"
    ;

ExprCaseClauseList:
    ExprCaseClauseList ExprCaseClause
    ;

ExprCaseClause:
    ExprSwitchCase ":" StatementList
    ;

ExprSwitchCase:
    "case" ExpressionList
    | "default"
    ;

SelectStmt:
    "select" "{" CommClauseList "}"
    ;

CommClauseList:
    CommClauseList CommClause
    ;

CommClause:
    CommCase ":" StatementList
    ;

CommCase:
    "case" SendStmt
    | "case" RecvStmt
    | "default"
    ;

RecvStmt:
    RecvExpr
    | ExpressionList "=" RecvExpr
    | IdentifierList ":=" RecvExpr
    ;

RecvExpr:
    Expression
    ;

FunctionDecl:
    "func" FunctionName Signature
    | "func" FunctionName Function
    ;

FunctionName:
    IDENT
    ;

TypeSwitchStmt:
    "switch" SimpleStmt ';' TypeSwitchGuard '{' TypeCaseClauseList '}'
    | "switch"  TypeSwitchGuard '{' TypeCaseClauseList '}'
    ;

TypeCaseClauseList:
    TypeCaseClauseList TypeCaseClause
    | TypeCaseClause
    ;

TypeSwitchGuard:
    PrimaryExpr '.' '(' "type" ')'
    IDENT "::" PrimaryExpr '.' '(' "type" ')'
    ;

TypeCaseClause:
    TypeSwitchCase ':' StatementList
    ;

TypeSwitchCase:
    "case" TypeList
    | "default"
    ;

TypeList:
    TypeList "," Type
    | Type
    ;


Function:
    Signature FunctionBody
    ;

FunctionBody:
    Block
    ;

ForStmt:
    "for" Block
    | "for" Condition Block
    | "for" ForClause Block
    | "for" RangeClause Block
    ;

ForClause:
    ";" ";"
    ";" ";" PostStmt
    ";" Condition ";"
    ";" Condition ";" PostStmt
    InitStmt ";"  ";"
    InitStmt ";"  ";" PostStmt
    InitStmt ";" Condition ";"
    InitStmt ";" Condition ";" PostStmt
    ;

RangeClause:
    "range" Expression
    | IdentifierList ":=" "range" Expression
    | ExpressionList "=" "range" Expression
    ;

InitStmt:
    SimpleStmt
    ;

PostStmt:
    SimpleStmt
    ;

Condition:
    Expression
    ;

DeferStmt:
    "defer" Expression
    ;

Label:
    IDENT
    ;


UnaryExpr:
    PrimaryExpr { $$ = &(init() << $1 >> "UnaryExpr"); }
    | UnaryOp UnaryExpr { $$ = &(init() << $1 << $2 >> "UnaryExpr"); }
    ;

PrimaryExpr:
    Operand { $$ = &(init() << $1 >> "PrimaryExpr"); }
    | Conversion
    | PrimaryExpr Selector
    | PrimaryExpr Index
    | PrimaryExpr Slice 
    | PrimaryExpr TypeAssertion
    | PrimaryExpr Arguments
    ;

Selector:
    '.' IDENT
    ;

Index:
    '[' Expression ']'
    ;

Slice:
    '[' ':' ']'
    | '[' ':' Expression ']'
    | '[' Expression ':' ']'
    | '[' Expression ':' Expression ']'
    | '[' ':' Expression ':' Expression ']'
    | '[' Expression ':' Expression ':' Expression ']'
    ;

TypeDecl:
    "type" TypeSpec
    "type" "(" TypeSpecList ")"
    ;

TypeSpecList:
    TypeSpecList TypeSpec ';'
    | TypeSpec ';'
    ;

TypeSpec:
    IDENT Type
    ;

VarDecl: 
    "var" "(" VarSpecList ")"
    | "var" VarSpec
    ;

VarSpec: 
    IdentifierList Type 
    | IdentifierList Type ':' ExpressionList
    | IdentifierList ':' ExpressionList
    ;

VarSpecList:
    VarSpecList VarSpec ';'
    | VarSpec ';'
    ;


TypeAssertion:
    '.' '(' Type ')'
    ;

Arguments:
    '(' ')'
    | '(' ExpressionList ')'
    | '(' ExpressionList "..." ')'
    ;

IdentifierList:
    IDENT
    | IdentifierList "," IDENT
    ;

ExpressionList:
    Expression { $$ = &(init() << $1 >> "ExpressionList"); }
    | ExpressionList "," Expression
    ;

Conversion:
    Type '(' Expression ')'
    | Type '(' Expression ',' ')'
    ;

Type:
    TypeName
    | TypeLit
    | '(' Type ')'
    ;

TypeName:
    IDENT
    | QualifiedIdent
    ;

TypeLit:
    ArrayType
 /* | StructType
    | PointerType
    | FunctionType
    | InterfaceType
    | SliceType
    | MapType
    | ChannelType*/
    ;

ArrayType:
    '[' ArrayLength ']' ElementType
    ;

ArrayLength:
    Expression
    ;

ElementType:
    Type
    ;

Operand:
    Literal { $$ = &(init() << $1 >> "Operand"); }
    | OperandName { $$ = &(init() << $1 >> "Operand"); }
    | MethodExpr
    | '(' Expression ')'
    ;

Literal:
    | BasicLit { $$ = &(init() << $1 >> "Literal"); }
/*  | CompositeLit
    | FunctionLit */
    ;

BasicLit:
    INT { $$ = &(init() << $1 >> "BasicLit"); }
    | FLOAT { $$ = &(init() << $1 >> "BasicLit"); }
/*  | IMAGINARY
    | RUNE */
    | String { $$ = &(init() << $1 >> "BasicLit"); }
    ;

OperandName:
    IDENT { $$ = &(init() << $1 >> "OperandName"); }
    | QualifiedIdent
    ;

QualifiedIdent:
    PackageName '.' IDENT
    ;

PackageName:
    IDENT
    ;

MethodExpr:
    RecieverType '.' MethodName
    ;

RecieverType:
    TypeName
    | '(' '*' TypeName ')'
    | '(' RecieverType ')'
    ;

MethodName:
    IDENT { $$ = &(init() << $1 >> "MethodName"); }
    ;

InterfaceTypeName:
    TypeName { $$ = &(init() << $1 >> "InterfaceTypeName"); }
    ;

UnaryOp:
    UN_OP { $$ = &(init() << $1 >> "UnaryOp"); }
    | DUAL_OP { $$ = &(init() << $1 >> "UnaryOp"); }
    ;

BinaryOp:
    BIN_OP { $$ = &(init() << $1 >> "BinaryOp"); }
    | DUAL_OP { $$ = &(init() << $1 >> "BinaryOp"); }
    ;

String:
    RAW_ST { $$ = &(init() << $1 >> "String"); }
    | INR_ST { $$ = &(init() << $1 >> "String"); }
    ;
%%
