%{
#include <cstdio>
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
    char name[100];
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
              "[label=\"" << n->children_t[id2++] << "\"]" << endl;
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

%token <sval> INT
%token <sval> FLOAT
%token <sval> IDENT
%token <sval> BIN_OP
%token <sval> DUAL_OP
%token <sval> REL_OP
%token <sval> MUL_OP
%token <sval> ADD_OP
%token <sval> UN_OP
%token <sval> LITERAL
%type <nt> Program Expression UnaryExpr PrimaryExpr Selector Index Slice
%type <nt> TypeAssertion Arguments IdentifierList ExpressionList Conversion
%type <nt> Type TypeName TypeLit ArrayType ArrayLength ElementType Operand
%type <nt> Literal BasicLit OperandName QualifiedIdent PackageName MethodExpr
%type <nt> RecieverType MethodName InterfaceTypeName BinaryOp UnaryOp
%%
Program:
    ExpressionList { $$ = &(init() << $1 >> "Program"); printTop($$);}
    ;

Expression:
    UnaryExpr { $$ = &(init() << $1 >> "Expression"); }
    | Expression BinaryOp Expression {$$ = &(init() << $1 << $2 << $3 >> "Expression");}
    ;

UnaryExpr:
    PrimaryExpr { $$ = &(init() << $1 >> "UnaryExpr"); }
    | UnaryOp UnaryExpr { $$ = &(init() << $1 << $2 >> "UnaryExpr"); }

PrimaryExpr:
    Operand { $$ = &(init() << $1 >> "PrimaryExpr"); }
    | Conversion
    | PrimaryExpr Selector
    | PrimaryExpr Index
/*  | PrimaryExpr Slice */
    | PrimaryExpr TypeAssertion
    | PrimaryExpr Arguments
    ;

Selector:
    '.' IDENT
    ;

Index:
    '[' Expression ']'
    ;
/*
Slice:
    '[' (Expression?) ':' (Expression?) ']'
    | '[' (Expression?) ':' Expression ':' Expression ']'
    ;
*/
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
    Literal
    | OperandName { $$ = &(init() << $1 >> "Operand"); }
    | MethodExpr
    | '(' Expression ')'
    ;

Literal:
    | BasicLit
/*  | CompositeLit
    | FunctionLit */
    ;

BasicLit:
    INT { $$ = &(init() << $1 >> "BasicLit"); }
    | FLOAT { $$ = &(init() << $1 >> "BasicLit"); }
/*  | IMAGINARY
    | RUNE
    | STRING */
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
    IDENT
    ;

InterfaceTypeName:
    TypeName
    ;

UnaryOp:
    UN_OP
    | DUAL_OP
    ;

BinaryOp:
    BIN_OP
    | DUAL_OP
    ;
%%
