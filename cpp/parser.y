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
%token <sval> RAW_ST INR_ST ASN_OP LEFT INC DEC DECL CONST DOTS FUNC MAP
%token <sval> GO RETURN BREAK CONT GOTO FALL IF ELSE SWITCH CASE END STAR
%token <sval> DEFLT SELECT TYPE ISOF FOR RANGE DEFER VAR IMPORT PACKGE STRUCT
%type <nt> SourceFile Expression Block StatementList Statement SimpleStmt
%type <nt> EmptyStmt ExpressionStmt SendStmt Channel IncDecStmt MapType
%type <nt> Assignment ShortVarDecl Declaration ConstDecl ConstSpecList
%type <nt> Signature Result Parameters ParameterList ParameterDecl
%type <nt> ConstSpec MethodDecl Receiver TopLevelDecl LabeledStmt
%type <nt> GoStmt ReturnStmt BreakStmt ContinueStmt GotoStmt StructType
%type <nt> FallthroughStmt IfStmt SwitchStmt ExprSwitchStmt
%type <nt> ExprCaseClauseList ExprCaseClause ExprSwitchCase SelectStmt
%type <nt> CommClauseList CommClause CommCase RecvStmt RecvExpr
%type <nt> FunctionDecl FunctionName TypeSwitchStmt TypeCaseClauseList
%type <nt> TypeSwitchGuard TypeCaseClause TypeSwitchCase TypeList
%type <nt> Function FunctionBody ForStmt ForClause RangeClause InitStmt
%type <nt> PostStmt Condition DeferStmt Label UnaryExpr PrimaryExpr
%type <nt> Selector Index Slice TypeDecl TypeSpecList TypeSpec VarDecl
%type <nt> VarSpec VarSpecList TypeAssertion Arguments IdentifierList
%type <nt> ExpressionList TypeLit ArrayType CompositeLit LiteralType
%type <nt> LiteralValue ElementList KeyedElement Key FieldName Element
%type <nt> ArrayLength Type Operand Literal BasicLit OperandName
%type <nt> PackageName MethodExpr ReceiverType ImportSpec PointerType
%type <nt> MethodName  UnaryOp BinaryOp String ImportPath SliceType KeyType
%type <nt> PackageClause ImportDeclList ImportDecl ImportSpecList TopLevelDeclList
%type <nt> FieldDeclList FieldDecl Tag AnonymousField BaseType ElementType
/*%type <nt> TypeName InterfaceTypeName*/
%%
SourceFile:
    PackageClause ';' ImportDeclList TopLevelDeclList { $$ = &(init() << $1 << $3 << $4 >> "SourceFile"); printTop($$); }
    ;

Expression:
    UnaryExpr { $$ = &(init() << $1 >> "Expression"); }
    | Expression BinaryOp Expression {$$ = &(init() << $1 << $2 << $3 >> "Expression");}
    ;

Block:
    '{' StatementList '}' { $$ = &(init() << $2 >> "Block"); }
    ;

StatementList:
    StatementList Statement ';' { $$ = &(init() << $1 << $2 >> "StatementList"); }
    | Statement ';' { $$ = &(init() << $1 >> "StatementList"); }
    ;

Statement:
    Declaration       { $$ = &(init() << $1 >> "Statement"); }
    | LabeledStmt     { $$ = &(init() << $1 >> "Statement"); }
    | SimpleStmt      { $$ = &(init() << $1 >> "Statement"); }
    | GoStmt          { $$ = &(init() << $1 >> "Statement"); }
    | ReturnStmt      { $$ = &(init() << $1 >> "Statement"); }
    | BreakStmt       { $$ = &(init() << $1 >> "Statement"); }
    | ContinueStmt    { $$ = &(init() << $1 >> "Statement"); }
    | GotoStmt        { $$ = &(init() << $1 >> "Statement"); }
    | FallthroughStmt { $$ = &(init() << $1 >> "Statement"); }
    | Block           { $$ = &(init() << $1 >> "Statement"); }
    | IfStmt          { $$ = &(init() << $1 >> "Statement"); }
    | SwitchStmt      { $$ = &(init() << $1 >> "Statement"); }
    | SelectStmt      { $$ = &(init() << $1 >> "Statement"); }
    | ForStmt         { $$ = &(init() << $1 >> "Statement"); }
    | DeferStmt       { $$ = &(init() << $1 >> "Statement"); }
    ;

SimpleStmt:
    EmptyStmt        { $$ = &(init() << $1 >> "SimpleStmt"); }
    | ExpressionStmt { $$ = &(init() << $1 >> "SimpleStmt"); }
    | SendStmt       { $$ = &(init() << $1 >> "SimpleStmt"); }
    | IncDecStmt     { $$ = &(init() << $1 >> "SimpleStmt"); }
    | Assignment     { $$ = &(init() << $1 >> "SimpleStmt"); }
    | ShortVarDecl   { $$ = &(init() << $1 >> "SimpleStmt"); }
    ;

EmptyStmt:
    /* blank */ { $$ = &(init() >> "EmptyStmt"); }
    ;

ExpressionStmt:
    Expression { $$ = &(init() << $1 >> "ExpressionStmt"); }
    ;

SendStmt:
    Channel LEFT Expression { $$ = &(init() << $1 << $3 >> "SendStmt"); }
    ;

Channel:
    Expression { $$ = &(init() << $1 >> "Channel"); }
    ;

IncDecStmt:
    Expression INC   { $$ = &(init() << $1 >> "Channel"); }
    | Expression DEC { $$ = &(init() << $1 >> "IncDecStmt"); }
    ;

Assignment:
    ExpressionList ASN_OP ExpressionList { $$ = &(init() << $1 << $2 << $3 >> "Assignment"); }
    ;

ShortVarDecl:
    ExpressionList DECL ExpressionList   { $$ = &(init() << $1  << $3 >> "ShortVarDecl"); }
    ;


Declaration:
    ConstDecl  { $$ = &(init() << $1 >> "Declaration"); }
    | TypeDecl { $$ = &(init() << $1 >> "Declaration"); }
    | VarDecl  { $$ = &(init() << $1 >> "Declaration"); }
    ;

ConstDecl:
    CONST ConstSpec { $$ = &(init() << $2 >> "ConstDecl"); }
    | CONST '(' ConstSpecList ')' { $$ = &(init() << $3 >> "ConstDecl"); }
    ;

ConstSpecList:
    /* empty */                   { $$ = &(init() >> "ConstSpecList"); }
    | ConstSpecList ConstSpec ';' { $$ = &(init() << $1 << $2 >> "ConstSpecList"); }
    | ConstSpec ';'               { $$ = &(init() << $1 >> "ConstSpecList"); }
    ;

Signature:
    Parameters          { $$ = &(init() << $1 >> "Signature"); }
    | Parameters Result { $$ = &(init() << $1 << $2 >> "Signature"); }
    ;

Result:
    Parameters { $$ = &(init() << $1 >> "Result"); }
    | Type     { $$ = &(init() << $1 >> "Result"); }
    ;

Parameters:
    '('  ')'                    { $$ = &(init() >> "Parameters"); }
    | '(' ParameterList  ')'    { $$ = &(init() << $2 >> "Parameters"); }
    | '(' ParameterList ',' ')' { $$ = &(init() << $2 >> "Parameters"); }
    ;

ParameterList:
    ParameterDecl { $$ = &(init() << $1 >> "ParameterList"); }
    | ParameterList ',' ParameterDecl { $$ = &(init() << $1 << $3 >> "ParameterList"); }
    ;

ParameterDecl:
    /*Type                       { $$ = &(init() << $1 >> "ParameterDecl"); }*/
    DOTS Type                { $$ = &(init() << $1 << $2 >> "ParameterDecl"); }
    | IdentifierList Type      { $$ = &(init() << $1 << $2 >> "ParameterDecl"); }
    | IdentifierList DOTS Type { $$ = &(init() << $1 << $2 << $3 >> "ParameterDecl"); }
    ;

ConstSpec:
    IdentifierList { $$ = &(init() << $1 >> "ConstSpec"); }
    | IdentifierList '=' ExpressionList { $$ = &(init() << $1 << $3 >> "ConstSpec"); }
    | IdentifierList Type '=' ExpressionList { $$ = &(init() << $1 << $2 << $4 >> "ConstSpec"); }
    ;

MethodDecl:
    FUNC Receiver MethodName Signature  { $$ = &(init() << $2 << $3 << $4 >> "MethodDecl"); }
    | FUNC Receiver MethodName Function { $$ = &(init() << $2 << $3 << $4 >> "MethodDecl"); }
    ;

Receiver:
    Parameters { $$ = &(init() << $1 >> "Receiver"); }
    ;

TopLevelDeclList:
    /* empty */ { $$ = &(init() >> "TopLevelDeclList"); }
    | TopLevelDeclList TopLevelDecl ';' { $$ = &(init() << $1 << $2 >> "TopLevelDeclList"); }
    | TopLevelDecl ';' { $$ = &(init() << $1 >> "TopLevelDeclList"); }
    ;

CompositeLit:
    LiteralType LiteralValue { $$ = &(init() << $1 << $2 >> "CompositeLit"); }
    ;

LiteralType:
    StructType                 { $$ = &(init() << $1 >> "LiteralType"); }
    | ArrayType                { $$ = &(init() << $1 >> "LiteralType"); }
    | '[' DOTS ']' ElementType { $$ = &(init() << $2 << $4 >> "LiteralType"); }
    | SliceType                { $$ = &(init() << $1 >> "LiteralType"); }
    | MapType                  { $$ = &(init() << $1 >> "LiteralType"); }
    | OperandName              { $$ = &(init() << $1 >> "LiteralType"); }
    ;

LiteralValue:
    '{' '}'                   { $$ = &(init() >> "LiteralValue"); }
    | '{' ElementList '}'     { $$ = &(init() << $2 >> "LiteralValue"); }
    | '{' ElementList ',' '}' { $$ = &(init() << $2 >> "LiteralValue"); }
    ;

SliceType:
    '[' ']' ElementType  { $$ = &(init() << $3 >> "SliceType"); }
    ;

ElementList:
    KeyedElement                   { $$ = &(init() << $1 >> "ElementList"); }
    | ElementList ',' KeyedElement { $$ = &(init() << $1 << $3 >> "ElementList"); }
    ;

KeyedElement:
    Element                        { $$ = &(init() << $1 >> "KeyedElement"); }
    | Key ':' Element              { $$ = &(init() << $1 << $3 >> "KeyedElement"); }
    ;

Key:
    FieldName      { $$ = &(init() << $1 >> "Key"); }
    | Expression   { $$ = &(init() << $1 >> "Key"); }
    | LiteralValue { $$ = &(init() << $1 >> "Key"); }
    ;

FieldName:
    IDENT          { $$ = &(init() << $1 >> "FieldName"); }
    ;

Element:
    Expression     { $$ = &(init() << $1 >> "Element"); }
    | LiteralValue { $$ = &(init() << $1 >> "Element"); }
    ;

TopLevelDecl:
    Declaration    { $$ = &(init() << $1 >> "TopLevelDecl"); }
    | FunctionDecl { $$ = &(init() << $1 >> "TopLevelDecl"); }
    | MethodDecl   { $$ = &(init() << $1 >> "TopLevelDecl"); }
    ;

LabeledStmt:
    Label ':' Statement { $$ = &(init() << $1 << $3 >> "LabeledStmt"); }
    ;

GoStmt:
    GO Expression { $$ = &(init() << $2 >> "GoStmt"); }
    ;

ReturnStmt:
    RETURN { $$ = &(init() >> "ReturnStmt"); }
    | RETURN ExpressionList { $$ = &(init() << $2 >> "ReturnStmt"); }
    ;

BreakStmt:
    BREAK         { $$ = &(init() >> "BreakStmt"); }
    | BREAK Label { $$ = &(init() << $2 >> "BreakStmt"); }
    ;

ContinueStmt:
    CONT { $$ = &(init() >> "ContinueStmt"); }
    | CONT Label { $$ = &(init() << $2 >> "ContinueStmt"); }
    ;

GotoStmt:
    GOTO Label { $$ = &(init() << $2 >> "GotoStmt"); }
    ;

FallthroughStmt:
    FALL { $$ = &(init() >> "FallthroughStmt"); }
    ;

IfStmt:
    IF Expression Block { $$ = &(init() << $2 << $3 >> "IfStmt"); }
    | IF SimpleStmt ';' Expression Block { $$ = &(init() << $2 << $4 << $5 >> "IfStmt"); }
    | IF Expression Block ELSE Block { $$ = &(init() << $2 << $3 << $5 >> "IfStmt"); }
    | IF Expression Block ELSE IfStmt { $$ = &(init() << $2 << $3 << $5 >> "IfStmt"); }
    | IF SimpleStmt ';' Expression Block ELSE IfStmt { $$ = &(init() << $2 << $4 << $5 << $7 >> "IfStmt"); }
    | IF SimpleStmt ';' Expression Block ELSE Block { $$ = &(init() << $2 << $4 << $5 << $7 >> "IfStmt"); }
    ;

SwitchStmt:
    ExprSwitchStmt { $$ = &(init() << $1 >> "SwitchStmt"); }
    | TypeSwitchStmt { $$ = &(init() << $1 >> "SwitchStmt"); }
    ;

ExprSwitchStmt:
    SWITCH '{' ExprCaseClauseList '}' { $$ = &(init() << $3 >> "ExprSwitchStmt"); }
    | SWITCH Expression '{' ExprCaseClauseList '}' { $$ = &(init() << $2 << $4 >> "ExprSwitchStmt"); }
    | SWITCH SimpleStmt ';' '{' ExprCaseClauseList '}' { $$ = &(init() << $2 << $5 >> "ExprSwitchStmt"); }
    | SWITCH SimpleStmt ';' Expression '{' ExprCaseClauseList '}' { $$ = &(init() << $2 << $4 << $6 >> "ExprSwitchStmt"); }
    ;

ExprCaseClauseList:
    /* empty */ { $$ = &(init() >> "ExprCaseClauseList"); }
    | ExprCaseClauseList ExprCaseClause { $$ = &(init() << $1 << $2 >> "ExprCaseClauseList"); }
    ;

ExprCaseClause:
    ExprSwitchCase ':' StatementList { $$ = &(init() << $1 << $3 >> "ExprCaseClause"); }
    ;

ExprSwitchCase:
    CASE ExpressionList { $$ = &(init() << $2 >> "ExprSwitchCase"); }
    | DEFLT { $$ = &(init() << $1 >> "ExprSwitchCase"); }
    ;

SelectStmt:
    SELECT '{' CommClauseList '}' { $$ = &(init() << $3 >> "SelectStmt"); }
    ;

CommClauseList:
    /* empty */ { $$ = &(init() >> "CommClauseList"); }
    | CommClauseList CommClause { $$ = &(init() << $1 << $2 >> "CommClauseList"); }
    ;

CommClause:
    CommCase ':' StatementList { $$ = &(init() << $1 << $3 >> "CommClause"); }
    ;

CommCase:
    CASE SendStmt { $$ = &(init() << $2 >> "CommCase"); }
    | CASE RecvStmt { $$ = &(init() << $2 >> "CommCase"); }
    | DEFLT { $$ = &(init() << $1 >> "CommCase"); }
    ;

RecvStmt:
    RecvExpr { $$ = &(init() << $1 >> "RecvStmt"); }
    | ExpressionList '=' RecvExpr { $$ = &(init() << $1 << $3 >> "RecvStmt"); }
    | ExpressionList DECL RecvExpr { $$ = &(init() << $1 << $2 << $3  >> "RecvStmt"); }
    ;

RecvExpr:
    Expression { $$ = &(init() << $1 >> "RecvExpr"); }
    ;

FunctionDecl:
    FUNC FunctionName Signature { $$ = &(init() << $2 << $3 >> "FunctionDecl"); }
    | FUNC FunctionName Function { $$ = &(init() << $2 << $3 >> "FunctionDecl"); }
    ;

FunctionName:
    IDENT { $$ = &(init() << $1 >> "FunctionName"); }
    ;

TypeSwitchStmt:
    SWITCH SimpleStmt ';' TypeSwitchGuard '{' TypeCaseClauseList '}' { $$ = &(init() << $2 << $4 << $6 >> "TypeSwitchStmt"); }
    | SWITCH TypeSwitchGuard '{' TypeCaseClauseList '}' { $$ = &(init() << $2 << $4 >> "TypeSwitchStmt"); }
    ;

TypeCaseClauseList:
    /* empty */ { $$ = &(init() >> "TypeCaseClauseList"); }
    | TypeCaseClauseList TypeCaseClause { $$ = &(init() << $1 << $2 >> "TypeCaseClauseList"); }
    | TypeCaseClause { $$ = &(init() << $1 >> "TypeCaseClauseList"); }
    ;

TypeSwitchGuard:
    PrimaryExpr '.' '(' TYPE ')' { $$ = &(init() << $1 << $4 >> "TypeSwitchGuard"); }
    | IDENT ISOF PrimaryExpr '.' '(' TYPE ')' { $$ = &(init() << $1 << $3 << $6 >> "TypeSwitchGuard"); }
    ;

TypeCaseClause:
    TypeSwitchCase ':' StatementList { $$ = &(init() << $1 << $3 >> "TypeCaseClause"); }
    ;

TypeSwitchCase:
    CASE TypeList { $$ = &(init() << $2 >> "TypeSwitchCase"); }
    | DEFLT { $$ = &(init() << $1 >> "TypeSwitchCase"); }
    ;

TypeList:
    TypeList ',' Type { $$ = &(init() << $1 << $3 >> "TypeList"); }
    | Type { $$ = &(init() << $1 >> "TypeList"); }
    ;


Function:
    Signature FunctionBody { $$ = &(init() << $1 << $2 >> "Function"); }
    ;

FunctionBody:
    Block { $$ = &(init() << $1 >> "FunctionBody"); }
    ;

ForStmt:
    FOR Block { $$ = &(init() << $2 >> "ForStmt"); }
    | FOR Condition Block { $$ = &(init() << $2 << $3 >> "ForStmt"); }
    | FOR ForClause Block { $$ = &(init() << $2 << $3 >> "ForStmt"); }
    | FOR RangeClause Block { $$ = &(init() << $2 << $3 >> "ForStmt"); }
    ;

ForClause:
    InitStmt ';'  ';' PostStmt  { $$ = &(init() << $1 << $4 >> "ForClause"); }
    | InitStmt ';' Condition ';' PostStmt  { $$ = &(init() << $1 << $3  << $5 >> "ForClause"); }
    ;

RangeClause:
    RANGE Expression  { $$ = &(init() << $2 >> "RangeClause"); }
    | ExpressionList DECL RANGE Expression  { $$ = &(init() << $1 << $4 >> "RangeClause"); }
    | ExpressionList '=' RANGE Expression  { $$ = &(init() << $1 << $4 >> "RangeClause"); }
    ;

InitStmt:
    SimpleStmt  { $$ = &(init() << $1 >> "InitStmt"); }
    ;

PostStmt:
    SimpleStmt  { $$ = &(init() << $1 >> "PostStmt"); }
    ;

Condition:
    Expression  { $$ = &(init() << $1 >> "Condition"); }
    ;

DeferStmt:
    DEFER Expression  { $$ = &(init() << $2 >> "DeferStmt"); }
    ;

Label:
    IDENT  { $$ = &(init() << $1 >> "Label"); }
    ;


UnaryExpr:
    PrimaryExpr { $$ = &(init() << $1 >> "UnaryExpr"); }
    | UnaryOp PrimaryExpr { $$ = &(init() << $1 << $2 >> "UnaryExpr"); }
    ;

PrimaryExpr:
    Operand { $$ = &(init() << $1 >> "PrimaryExpr"); }
    | PrimaryExpr Selector { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr Index { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr Slice  { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr TypeAssertion { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr Arguments { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    /*| Conversion { $$ = &(init() << $1 >> "PrimaryExpr"); }*/
    ;

Selector:
    '.' IDENT  { $$ = &(init() << $2 >> "Selector"); }
    ;

Index:
    '[' Expression ']'  { $$ = &(init() << $2 >> "Index"); }
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
    TYPE TypeSpec  { $$ = &(init() << $2 >> "TypeDecl"); }
    | TYPE '(' TypeSpecList ')'  { $$ = &(init() << $3 >> "TypeDecl"); }
    ;

TypeSpecList:
    /* empty */  { $$ = &(init() >> "TypeSpecList"); }
    | TypeSpecList TypeSpec ';'  { $$ = &(init() << $1 << $2 >> "TypeSpecList"); }
    | TypeSpec ';'  { $$ = &(init() << $1 >> "TypeSpecList"); }
    ;

TypeSpec:
    IDENT Type { $$ = &(init() << $1 << $2 >> "TypeSpec"); }
    ;

VarDecl:
    VAR '(' VarSpecList ')' { $$ = &(init() << $3 >> "VarDecl"); }
    | VAR VarSpec           { $$ = &(init() << $2 >> "VarDecl"); }
    ;

VarSpec:
    IdentifierList Type                      { $$ = &(init() << $1 << $2 >> "VarSpec"); }
    | IdentifierList Type ':' ExpressionList { $$ = &(init() << $1 << $2 << $4 >> "VarSpec"); }
    | IdentifierList ':' ExpressionList      { $$ = &(init() << $1 << $3 >> "VarSpec"); }
    ;

VarSpecList:
    /* empty */               { $$ = &(init() >> "VarSpecList"); }
    | VarSpecList VarSpec ';' { $$ = &(init() << $1 << $2 >> "VarSpecList"); }
    | VarSpec ';'             { $$ = &(init() << $1 >> "VarSpecList"); }
    ;


TypeAssertion:
    '.' '(' Type ')'  { $$ = &(init() << $3 >> "TypeAssertion"); }
    ;

Arguments:
    '(' ')'                       { $$ = &(init() >> "Arguments"); }
    | '(' ExpressionList ')'      { $$ = &(init() << $2 >> "Arguments"); }
    | '(' ExpressionList DOTS ')' { $$ = &(init() << $2 << $3 >> "Arguments"); }
    ;

IdentifierList:
    IDENT                         { $$ = &(init() << $1 >> "IdentifierList"); }
    | IdentifierList ',' IDENT    { $$ = &(init() << $1 >> "IdentifierList"); }
    ;

ExpressionList:
    Expression                      { $$ = &(init() << $1 >> "ExpressionList"); }
    | ExpressionList ',' Expression { $$ = &(init() << $1 << $3 >> "ExpressionList"); }
    ;

/*Conversion:*/
    /*Type '(' Expression ')'       { $$ = &(init() << $1 << $3 >> "Conversion"); }*/
    /*| Type '(' Expression ',' ')' { $$ = &(init() << $1 << $3 >> "Conversion"); }*/
    /*;*/

Type:
    OperandName       { $$ = &(init() << $1 >> "Type"); }
    | TypeLit      { $$ = &(init() << $1 >> "Type"); }
    | '(' Type ')' { $$ = &(init() << $2 >> "Type"); }
    ;

MapType:
    MAP '[' KeyType ']' ElementType { $$ = &(init() << $1 << $3 << $5 >> "MapType"); }
    ;

KeyType:
    Type { $$ = &(init() << $1 >> "KeyType"); }
    ;

ElementType:
    Type { $$ = &(init() << $1 >> "ElementType"); }
    ;

StructType:
    STRUCT '{' FieldDeclList '}' { $$ = &(init() << $1 << $3 >> "StructType"); }
    ;

FieldDeclList:
    FieldDeclList FieldDecl ';' { $$ = &(init() << $1 << $2 >> "FieldDeclList"); }
    | FieldDecl ';' { $$ = &(init() << $1 >> "FieldDeclList"); }
    ;

FieldDecl:
    IdentifierList Type Tag { $$ = &(init() << $1 << $2 << $3 >> "FieldDecl"); }
    | IdentifierList Type { $$ = &(init() << $1 << $2 >> "FieldDecl"); }
    | AnonymousField Tag { $$ = &(init() << $1 << $2 >> "FieldDecl"); }
    | AnonymousField { $$ = &(init() << $1 >> "FieldDecl"); }
    ;

AnonymousField:
    '*' OperandName { $$ = &(init() << $2 >> "AnonymousField"); }
    | OperandName { $$ = &(init() << $1 >> "AnonymousField"); }
    ;

Tag:
   String { $$ = &(init() << $1 >> "Tag"); }
   ;

TypeLit:
    ArrayType { $$ = &(init() << $1 >> "TypeLit"); }
    | StructType { $$ = &(init() << $1 >> "TypeLit"); }
    | PointerType { $$ = &(init() << $1 >> "TypeLit"); }
/*  | FunctionType { $$ = &(init() << $1 >> "TypeLit"); }
    | ChannelType { $$ = &(init() << $1 >> "TypeLit"); }
    | InterfaceType  { $$ = &(init() << $1 >> "TypeLit"); }*/
    | SliceType { $$ = &(init() << $1 >> "TypeLit"); }
    | MapType { $$ = &(init() << $1 >> "TypeLit"); }
    ;

PointerType:
    STAR BaseType { $$ = &(init() << $1 << $2 >> "PointerType"); }
    ;

BaseType:
    Type { $$ = &(init() << $1 >> "BaseType"); }
    ;

ArrayType:
    '[' ArrayLength ']' ElementType  { $$ = &(init() << $2 << $4 >> "ArrayType"); }
    ;

ArrayLength:
    Expression  { $$ = &(init() << $1 >> "ArrayLength"); }
    ;

Operand:
    Literal              { $$ = &(init() << $1 >> "Operand"); }
    | OperandName        { $$ = &(init() << $1 >> "Operand"); }
    | MethodExpr         { $$ = &(init() << $1 >> "Operand"); }
    | '(' Expression ')' { $$ = &(init() << $2 >> "Operand"); }
    ;

Literal:
    BasicLit { $$ = &(init() << $1 >> "Literal"); }
    | CompositeLit { $$ = &(init() << $1 >> "Literal"); }
/*  | FunctionLit */
    ;

BasicLit:
    INT         { $$ = &(init() << $1 >> "BasicLit"); }
    | FLOAT     { $$ = &(init() << $1 >> "BasicLit"); }
/*  | IMAGINARY
    | RUNE */
    | String    { $$ = &(init() << $1 >> "BasicLit"); }
    ;

OperandName:
    IDENT            { $$ = &(init() << $1 >> "OperandName"); }
    | OperandName '.' IDENT { $$ = &(init() << $1 >> "OperandName"); }
    ;

MethodExpr:
    ReceiverType '.' MethodName  { $$ = &(init() << $1 << $3 >> "MethodExpr"); }
    ;

ReceiverType:
    '(' STAR OperandName ')' { $$ = &(init() << $2 << $3 >> "ReceiverType"); }
    | '(' ReceiverType ')' { $$ = &(init() << $2 >> "ReceiverType"); }
    ;

MethodName:
    IDENT          { $$ = &(init() << $1 >> "MethodName"); }
    ;

/*InterfaceTypeName:*/
    /*TypeName       { $$ = &(init() << $1 >> "InterfaceTypeName"); }*/
    /*;*/

UnaryOp:
    UN_OP          { $$ = &(init() << $1 >> "UnaryOp"); }
    | DUAL_OP      { $$ = &(init() << $1 >> "UnaryOp"); }
    ;

BinaryOp:
    BIN_OP         { $$ = &(init() << $1 >> "BinaryOp"); }
    | DUAL_OP      { $$ = &(init() << $1 >> "BinaryOp"); }
    ;

String:
    RAW_ST         { $$ = &(init() << $1 >> "String"); }
    | INR_ST       { $$ = &(init() << $1 >> "String"); }
    ;

PackageClause:
    PACKGE PackageName { $$ = &(init() << $2 >> "PackageClause"); }
    ;

PackageName:
    IDENT { $$ = &(init() << $1 >> "PackageName"); }
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
    PackageName ImportPath { $$ = &(init() << $1 << $2 >> "ImportSpec"); }
    | '.' ImportPath { $$ = &(init() << $2 >> "ImportSpec"); }
    | ImportPath { $$ = &(init() << $1 >> "ImportSpec"); }
    ;

ImportPath:
    String { $$ = &(init() << $1 >> "ImportPath"); }
    ;
%%
