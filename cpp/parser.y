%{
#include <cstdio>
#include <sstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include "node.h"
#include <unordered_map>
#define YYDEBUG 1
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);

// SYMBOL TABLE CONSTRUCTS
int node_id = 0;
int scope_id = 0;
string scope_prefix = "0-";

enum TypeClass {
    _BasicType,
    _FxnType,
    _StructType,
    _TupleType
};

class gotype;
class symbol;

class gotype {
public:
    string name;
    TypeClass classtype;

    /* For functions */
    vector<gotype*> args;
    vector<symbol*> functions;
    gotype *ret;

    /* For structs */
    unordered_map<string, gotype*> fields;

    /* For tuples */
    vector<gotype*> types;

    /* Basic type */
    gotype(string _name) : name(_name) {
        classtype = _BasicType;
    }

    /* Function Type */
    gotype(string _name, vector<gotype*> _args, gotype *_ret)
        : name(_name), args(_args), ret(_ret) {
        classtype = _FxnType;
    }

    /* Struct Type */
    gotype(string _name, unordered_map<string, gotype*> _fields)
        : name(_name), fields(_fields) {
        classtype = _StructType;
    }

    /* Tuple Type */
    gotype(string _name, vector<gotype*> _types)
        : name(_name), types(_types) {
        classtype = _TupleType;
    }

    string tostring() {
        stringstream strval;
        if (classtype == _BasicType) {
            strval << name;
        } else if (classtype == _FxnType) {
            for (auto &param: args) {
                strval << param->tostring() << " -> ";
            }
            strval << ret->tostring();
        } else if (classtype == _StructType) {
            strval << "Data [ ";
            bool first = false;
            for (auto &param: fields) {
                if (!first) strval << ", ";
                strval << param.second->tostring();
            }
            cout << " ]";
        } else {
            strval << "( ";
            bool first = false;
            for (auto &param: types) {
                if (!first) strval << ", ";
                strval << param->tostring();
            }
            strval << " )";
        }
        return strval.str();
    }
};

class symbol {
public:
    string name;
    gotype *type;

    symbol(string n, gotype *t)
        : name(n), type(t) {}
};

unordered_map<string, symbol> stable; // symbols
unordered_map<string, gotype> ttable; // types

void inittables() {
    /* ttable.insert(make_pair("int", newtype("int"))); */
    /* ttable.insert(make_pair("uint32", newtype("uint32"))); */
}

void printtables() {
    cout << endl << endl << "Symbol table:" << endl;
    for(auto elem: stable) {
        cout << elem.first << " :: ";
        cout << elem.second.type->tostring();
        cout << endl;
    }
}

// TREE NODE DEFINTIONS
struct node {
    char name[100] = {0};
    vector<node *> children_nt;
    vector<char *> children_t;
    vector<gotype*> types;
    vector<string> names;
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
    n->types = vector<gotype*>();
    n->names = vector<string>();
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
    string name = "_" + to_string(node_id++);
    while(id1 < n->children_nt.size() || id2 < n->children_t.size()) {
        if(id1 < n->children_nt.size()) {
            string child = print(n->children_nt[id1++]);
            cout << name << " -- " << child << endl;
        }

        if(id2 < n->children_t.size()) {
            cout << "_" + to_string(node_id) <<
              "[label=\"" << escape_json(n->children_t[id2++]) << "\"]" << endl;
            cout << name << " -- " << "_" + to_string(node_id++) << endl;
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

void clone(node *dest, node *parent) {
    dest->types = parent->types;
    dest->names = parent->names;
}

%}

%union {
    node* nt;
    char *sval;
}

%token <sval> INT FLOAT IDENT BIN_OP DUAL_OP REL_OP MUL_OP ADD_OP UN_OP ECURLY
%token <sval> RAW_ST INR_ST ASN_OP LEFT INC DEC DECL CONST DOTS FUNC MAP
%token <sval> GO RETURN BREAK CONT GOTO FALL IF ELSE SWITCH CASE END STAR MAKE
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
%type <nt> TypeSwitchGuard TypeCaseClause TypeSwitchCase
%type <nt> Function FunctionBody ForStmt ForClause RangeClause InitStmt
%type <nt> PostStmt Condition DeferStmt Label UnaryExpr PrimaryExpr
%type <nt> Selector Index Slice TypeDecl TypeSpecList TypeSpec VarDecl
%type <nt> VarSpec VarSpecList TypeAssertion Arguments IdentifierList
%type <nt> ExpressionList TypeLit ArrayType CompositeLit LiteralType
%type <nt> LiteralValue ElementList KeyedElement Key Element
%type <nt> ArrayLength Operand Literal BasicLit OperandName
%type <nt> PackageName ImportSpec TypeList
%type <nt> MethodName  UnaryOp BinaryOp String ImportPath SliceType KeyType
%type <nt> PackageClause ImportDeclList ImportDecl ImportSpecList TopLevelDeclList
%type <nt> FieldDeclList FieldDecl Tag AnonymousField BaseType ElementType MakeExpr
%type <nt> StructLiteral KeyValList
%type <nt> OPENB CLOSEB
/*%type <nt> TypeName InterfaceTypeName MethodExpr*/
%%
SourceFile:
    PackageClause ';' ImportDeclList TopLevelDeclList { $$ = &(init() << $1 << $3 << $4 >> "SourceFile"); printTop($$); }
    ;

Expression:
    UnaryExpr { $$ = &(init() << $1 >> "Expression"); }
    | Expression BinaryOp Expression {$$ = &(init() << $1 << $2 << $3 >> "Expression");}
    ;

Block:
    ECURLY OPENB StatementList CLOSEB '}' { $$ = &(init() << $3 >> "Block"); }
    ;

OPENB:
    /* empty */ {
        scope_id++;
        scope_prefix = (to_string(scope_id) + "-" + scope_prefix);
        $$ = &(init() >> "ERROR");
    }
    ;

CLOSEB:
    /* empty */ {
        scope_prefix = scope_prefix.substr(scope_prefix.find("-") + 1);
        $$ = &(init() >> "ERROR");
    }
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
    Expression INC   { $$ = &(init() << $1 << $2 >> "IncDecStmt"); }
    | Expression DEC { $$ = &(init() << $1 << $2 >> "IncDecStmt"); }
    ;

Assignment:
    IdentifierList ASN_OP ExpressionList { $$ = &(init() << $1 << $2 << $3 >> "Assignment"); }
    ;

ShortVarDecl:
    IdentifierList DECL ExpressionList   { $$ = &(init() << $1  << $3 >> "ShortVarDecl"); }
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
    OPENB Parameters          {
    $$ = &(init() << $2 >> "Signature");
    $$->types.push_back(new gotype("", $2->types, new gotype("void")));
    }
    | OPENB Parameters Result {
        $$ = &(init() << $2 << $3 >> "Signature");
        $$->types.push_back(new gotype("", $2->types, $3->types[0]));
    }
    ;

Result:
    Parameters { $$ = &(init() << $1 >> "Result"); clone($$, $1); }
    | OperandName { $$ = &(init() << $1 >> "Result"); clone($$, $1); }
    ;

Parameters:
    '('  ')'                    {
        $$ = &(init() >> "Parameters");
    }
    | '(' ParameterList  ')'    {
        $$ = &(init() << $2 >> "Parameters");
        $$->types = $2->types;
    }
    | '(' ParameterList ',' ')' {
        $$ = &(init() << $2 >> "Parameters");
        $$->types = $2->types;
      }
    ;

ParameterList:
    ParameterDecl {
        $$ = &(init() << $1 >> "ParameterList");
        $$->types = $1->types;  /* Should not have more than 1 type */
    }
    | ParameterList ',' ParameterDecl {
        $$ = &(init() << $1 << $3 >> "ParameterList");
        $$->types = $1->types;
        $$->types.push_back($3->types[0]); /* Should have only 1 type */
      }
    ;

ParameterDecl:
    /*Type                       { $$ = &(init() << $1 >> "ParameterDecl"); }*/
    DOTS OperandName { $$ = &(init() << $1 << $2 >> "ParameterDecl");  } /* TODO:
                                                                   * Missing types */
    | IdentifierList OperandName {
        $$ = &(init() << $1 << $2 >> "ParameterDecl");
        for (int i=0; i<$1->names.size(); i++) {
            /* Fails if OperandName did not return a type */
            $$->types.push_back($2->types[0]);
            stable.insert(make_pair(scope_prefix + $1->names[i],
                                    symbol($1->names[i], $2->types[0])));
        }
    }
    | IdentifierList DOTS OperandName {
        $$ = &(init() << $1 << $2 << $3 >> "ParameterDecl"); // TODO: Missing types
    }
    ;

ConstSpec:
    IdentifierList { $$ = &(init() << $1 >> "ConstSpec"); }
    | IdentifierList '=' ExpressionList { $$ = &(init() << $1 << $3 >> "ConstSpec"); }
    | IdentifierList OperandName '=' ExpressionList { $$ = &(init() << $1 << $2 << $4 >> "ConstSpec"); }
    ;

MethodDecl:
    FUNC Receiver MethodName Signature CLOSEB { $$ = &(init() << $2 << $3 << $4 >> "MethodDecl"); }
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
    StructType                 { $$ = &(init() << $1 >> "LiteralType"); clone($$, $1); }
    | ArrayType                { $$ = &(init() << $1 >> "LiteralType"); clone($$, $1); }
    | '[' DOTS ']' ElementType {
        $$ = &(init() << $2 << $4 >> "LiteralType");
        clone($$, $1);
    }
    | SliceType                { $$ = &(init() << $1 >> "LiteralType"); clone($$, $1); }
    | MapType                  { $$ = &(init() << $1 >> "LiteralType"); clone($$, $1); }
    ;

LiteralValue:
    '{' '}'                   { $$ = &(init() >> "LiteralValue"); }
    | ECURLY '}'                   { $$ = &(init() >> "LiteralValue"); }
    | '{' ElementList '}'     { $$ = &(init() << $2 >> "LiteralValue"); }
    | ECURLY ElementList '}'     { $$ = &(init() << $2 >> "LiteralValue"); }
    | '{' ElementList ',' '}' { $$ = &(init() << $2 >> "LiteralValue"); }
    | ECURLY ElementList ',' '}' { $$ = &(init() << $2 >> "LiteralValue"); }
    ;

SliceType:
    '[' ']' ElementType  {
        $$ = &(init() << $3 >> "SliceType");
        clone($$, $1);
    }
    /* TODO: Fix this */
    /*| '[' ']' OperandName  { $$ = &(init() << $3 >> "SliceType"); }*/
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
    Expression   { $$ = &(init() << $1 >> "Key"); }
    | LiteralValue { $$ = &(init() << $1 >> "Key"); }
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
    CONT         { $$ = &(init() >> "ContinueStmt"); }
    | CONT Label { $$ = &(init() << $2 >> "ContinueStmt"); }
    ;

GotoStmt:
    GOTO Label   { $$ = &(init() << $2 >> "GotoStmt"); }
    ;

FallthroughStmt:
    FALL         { $$ = &(init() >> "FallthroughStmt"); }
    ;

IfStmt:
    IF OPENB Expression Block CLOSEB { $$ = &(init() << $3 << $4 >> "IfStmt"); }
    | IF OPENB SimpleStmt ';' Expression Block CLOSEB { $$ = &(init() << $3 << $5 << $6 >> "IfStmt"); }
    | IF OPENB Expression Block ELSE Block CLOSEB { $$ = &(init() << $3 << $4 << $6 >> "IfStmt"); }
    | IF OPENB Expression Block ELSE IfStmt CLOSEB   { $$ = &(init() << $3 << $4 << $6 >> "IfStmt"); }
    | IF OPENB SimpleStmt ';' Expression Block ELSE IfStmt CLOSEB { $$ = &(init() << $3 << $5 << $6 << $8 >> "IfStmt"); }
    | IF OPENB SimpleStmt ';' Expression Block ELSE Block CLOSEB { $$ = &(init() << $3 << $5 << $6 << $8 >> "IfStmt"); }
    ;

SwitchStmt:
    ExprSwitchStmt { $$ = &(init() << $1 >> "SwitchStmt"); }
    | TypeSwitchStmt { $$ = &(init() << $1 >> "SwitchStmt"); }
    ;

ExprSwitchStmt:
    SWITCH OPENB ECURLY ExprCaseClauseList '}' CLOSEB { $$ = &(init() << $4 >> "ExprSwitchStmt"); }
    | SWITCH OPENB Expression ECURLY ExprCaseClauseList '}' CLOSEB { $$ = &(init() << $3 << $5 >> "ExprSwitchStmt"); }
    | SWITCH OPENB SimpleStmt ';' ECURLY ExprCaseClauseList '}' CLOSEB { $$ = &(init() << $3 << $6 >> "ExprSwitchStmt"); }
    | SWITCH OPENB SimpleStmt ';' Expression ECURLY ExprCaseClauseList '}' CLOSEB { $$ = &(init() << $3 << $5 << $7 >> "ExprSwitchStmt"); }
    ;

ExprCaseClauseList:
    /* empty */ { $$ = &(init() >> "ExprCaseClauseList"); }
    | ExprCaseClauseList ExprCaseClause { $$ = &(init() << $1 << $2 >> "ExprCaseClauseList"); }
    ;

ExprCaseClause:
    OPENB ExprSwitchCase ':' StatementList CLOSEB { $$ = &(init() << $2 << $4 >> "ExprCaseClause"); }
    ;

ExprSwitchCase:
    CASE ExpressionList { $$ = &(init() << $2 >> "ExprSwitchCase"); }
    | DEFLT { $$ = &(init() << $1 >> "ExprSwitchCase"); }
    ;

SelectStmt:
    SELECT ECURLY CommClauseList '}' { $$ = &(init() << $3 >> "SelectStmt"); }
    ;

CommClauseList:
    /* empty */ { $$ = &(init() >> "CommClauseList"); }
    | CommClauseList CommClause { $$ = &(init() << $1 << $2 >> "CommClauseList"); }
    ;

CommClause:
    OPENB CommCase ':' StatementList CLOSEB { $$ = &(init() << $2 << $4 >> "CommClause"); }
    ;

CommCase:
    CASE SendStmt { $$ = &(init() << $2 >> "CommCase"); }
    | CASE RecvStmt { $$ = &(init() << $2 >> "CommCase"); }
    | DEFLT { $$ = &(init() << $1 >> "CommCase"); }
    ;

RecvStmt:
    RecvExpr { $$ = &(init() << $1 >> "RecvStmt"); }
    | IdentifierList '=' RecvExpr { $$ = &(init() << $1 << $3 >> "RecvStmt"); }
    | IdentifierList DECL RecvExpr { $$ = &(init() << $1 << $2 << $3  >> "RecvStmt"); }
    ;

RecvExpr:
    Expression { $$ = &(init() << $1 >> "RecvExpr"); }
    ;

FunctionDecl:
    FUNC FunctionName Signature CLOSEB {
        $$ = &(init() << $2 << $3 >> "FunctionDecl");
        stable.insert(make_pair(scope_prefix + $2->names[0],
                                symbol($2->names[0], $3->types[0])));
    }
    | FUNC FunctionName Function {
        $$ = &(init() << $2 << $3 >> "FunctionDecl");
        stable.insert(make_pair(scope_prefix + $2->names[0],
                                symbol($2->names[0], $3->types[0])));
    }
    ;

FunctionName:
    IDENT {
        $$ = &(init() << $1 >> "FunctionName");
        $$->names.push_back(string($1, strlen($1)));
    }
    ;

TypeSwitchStmt:
    SWITCH OPENB SimpleStmt ';' TypeSwitchGuard ECURLY TypeCaseClauseList '}' CLOSEB { $$ = &(init() << $3 << $5 << $7 >> "TypeSwitchStmt"); }
    | SWITCH OPENB TypeSwitchGuard ECURLY TypeCaseClauseList '}' CLOSEB { $$ = &(init() << $3 << $5 >> "TypeSwitchStmt"); }
    ;

TypeCaseClauseList:
    /* empty */ { $$ = &(init() >> "TypeCaseClauseList"); }
    | TypeCaseClauseList TypeCaseClause { $$ = &(init() << $1 << $2 >> "TypeCaseClauseList"); }
    /*| TypeCaseClause { $$ = &(init() << $1 >> "TypeCaseClauseList"); }*/
    ;

TypeSwitchGuard:
    PrimaryExpr '.' '(' TYPE ')' { $$ = &(init() << $1 << $4 >> "TypeSwitchGuard"); }
    | IDENT ISOF PrimaryExpr '.' '(' TYPE ')' { $$ = &(init() << $1 << $3 << $6 >> "TypeSwitchGuard"); }
    ;

TypeCaseClause:
    OPENB TypeSwitchCase ':' StatementList CLOSEB { $$ = &(init() << $2 << $4 >> "TypeCaseClause"); }
    ;

TypeSwitchCase:
    CASE TypeList { $$ = &(init() << $2 >> "TypeSwitchCase"); }
    | DEFLT { $$ = &(init() << $1 >> "TypeSwitchCase"); }
    ;

TypeList:
    OperandName { $$ = &(init() << $1 >> "TypeList"); }
    | TypeList ',' OperandName { $$ = &(init() << $1 << $3 >> "TypeList"); }
    ;


Function:
    Signature FunctionBody CLOSEB {
        $$ = &(init() << $2 << $3 >> "Function");
        $$->types = $1->types;
    }
    ;

FunctionBody:
    Block { $$ = &(init() << $1 >> "FunctionBody"); }
    ;

ForStmt:
    FOR Block { $$ = &(init() << $2 >> "ForStmt"); }
    | FOR OPENB Condition Block CLOSEB { $$ = &(init() << $3 << $4 >> "ForStmt"); }
    | FOR OPENB ForClause Block CLOSEB { $$ = &(init() << $3 << $4 >> "ForStmt"); }
    | FOR OPENB RangeClause Block CLOSEB { $$ = &(init() << $3 << $4 >> "ForStmt"); }
    ;

ForClause:
    InitStmt ';'  ';' PostStmt  { $$ = &(init() << $1 << $4 >> "ForClause"); }
    | InitStmt ';' Condition ';' PostStmt  { $$ = &(init() << $1 << $3  << $5 >> "ForClause"); }
    ;

RangeClause:
    RANGE Expression  { $$ = &(init() << $2 >> "RangeClause"); }
    | IdentifierList DECL RANGE Expression  { $$ = &(init() << $1 << $4 >> "RangeClause"); }
    | IdentifierList '=' RANGE Expression  { $$ = &(init() << $1 << $4 >> "RangeClause"); }
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
    | MakeExpr { $$ = &(init() << $1 >> "PrimaryExpr"); }
    | PrimaryExpr Selector { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr Index { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr Slice  { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr TypeAssertion { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr Arguments { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | OperandName StructLiteral { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    /*| Conversion { $$ = &(init() << $1 >> "PrimaryExpr"); }*/
    ;

StructLiteral:
    '{' KeyValList '}' { $$ = &(init() << $2 >> "StructLiteral"); }
    /*| ECURLY KeyValList '}' { $$ = &(init() << $2 >> "StructLiteral"); }*/
    ;

KeyValList:
    /* empty */  { $$ = &(init() >> "KeyValList"); }
    | Expression ':' Expression { $$ = &(init() << $1 << $3 >> "KeyValList"); }
    | Expression ':' Expression ',' KeyValList { $$ = &(init() << $1 << $3 << $5 >> "KeyValList"); }

MakeExpr:
    MAKE '(' LiteralType ',' ExpressionList ')' { $$ = &(init() << $3 << $5 >> "MakeExpr"); }
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
    IDENT OperandName { $$ = &(init() << $1 << $2 >> "TypeSpec"); }
    ;

VarDecl:
    VAR '(' VarSpecList ')' { $$ = &(init() << $3 >> "VarDecl"); }
    | VAR VarSpec           { $$ = &(init() << $2 >> "VarDecl"); }
    ;

VarSpec:
    IdentifierList OperandName { $$ = &(init() << $1 << $2 >> "VarSpec"); }
    | IdentifierList OperandName ':' ExpressionList { $$ = &(init() << $1 << $2 << $4 >> "VarSpec"); }
    | IdentifierList ':' ExpressionList      { $$ = &(init() << $1 << $3 >> "VarSpec"); }
    ;

VarSpecList:
    /* empty */               { $$ = &(init() >> "VarSpecList"); }
    | VarSpecList VarSpec ';' { $$ = &(init() << $1 << $2 >> "VarSpecList"); }
    | VarSpec ';'             { $$ = &(init() << $1 >> "VarSpecList"); }
    ;


TypeAssertion:
    '.' '(' OperandName ')'  { $$ = &(init() << $3 >> "TypeAssertion"); }
    ;

Arguments:
    '(' ')'                       { $$ = &(init() >> "Arguments"); }
    | '(' ExpressionList ')'      { $$ = &(init() << $2 >> "Arguments"); }
    | '(' ExpressionList DOTS ')' { $$ = &(init() << $2 << $3 >> "Arguments"); }
    ;

IdentifierList:
    OperandName { $$ = &(init() << $1 >> "IdentifierList"); clone($$, $1); }
    | IdentifierList ',' OperandName {
        $$ = &(init() << $1 >> "IdentifierList");
        clone($$, $1);
        $$->names.push_back($3->names[0]);
        $$->types.push_back($3->types[0]);
    }
    ;

ExpressionList:
    Expression                      { $$ = &(init() << $1 >> "ExpressionList"); }
    | ExpressionList ',' Expression { $$ = &(init() << $1 << $3 >> "ExpressionList"); }
    ;

/*Conversion:*/
    /*Type '(' Expression ')'       { $$ = &(init() << $1 << $3 >> "Conversion"); }*/
    /*| Type '(' Expression ',' ')' { $$ = &(init() << $1 << $3 >> "Conversion"); }*/
    /*;*/

/*Type:*/
    /*OperandName       { $$ = &(init() << $1 >> "Type"); }*/
    /*| TypeLit      { $$ = &(init() << $1 >> "Type"); }*/
    /*| '(' Type ')' { $$ = &(init() << $2 >> "Type"); }*/
    /*;*/

MapType:
    MAP '[' KeyType ']' ElementType { $$ = &(init() << $1 << $3 << $5 >> "MapType"); }
    ;

KeyType:
    OperandName { $$ = &(init() << $1 >> "KeyType"); clone($$, $1); }
    ;

ElementType:
    OperandName { $$ = &(init() << $1 >> "ElementType"); clone($$, $1); }
    ;

StructType:
    STRUCT '{' FieldDeclList '}' { $$ = &(init() << $1 << $3 >> "StructType"); }
    | STRUCT ECURLY FieldDeclList '}' { $$ = &(init() << $1 << $3 >> "StructType"); }
    ;

FieldDeclList:
    /* empty */ { $$ = &(init() >> "FieldDeclList"); }
    | FieldDeclList FieldDecl ';' { $$ = &(init() << $1 << $2 >> "FieldDeclList"); }
    /*| FieldDecl ';' { $$ = &(init() << $1 >> "FieldDeclList"); }*/
    ;

FieldDecl:
    IdentifierList OperandName Tag { $$ = &(init() << $1 << $2 << $3 >> "FieldDecl"); }
    | IdentifierList OperandName { $$ = &(init() << $1 << $2 >> "FieldDecl"); }
    | AnonymousField Tag { $$ = &(init() << $1 << $2 >> "FieldDecl"); }
    | AnonymousField { $$ = &(init() << $1 >> "FieldDecl"); }
    ;

AnonymousField:
    OperandName { $$ = &(init() << $1 >> "AnonymousField"); }
    ;

Tag:
   String { $$ = &(init() << $1 >> "Tag"); }
   ;

TypeLit:
    ArrayType { $$ = &(init() << $1 >> "TypeLit"); }
    | StructType { $$ = &(init() << $1 >> "TypeLit"); }
    /*| PointerType { $$ = &(init() << $1 >> "TypeLit"); }*/
/*  | FunctionType { $$ = &(init() << $1 >> "TypeLit"); }
    | ChannelType { $$ = &(init() << $1 >> "TypeLit"); }
    | InterfaceType  { $$ = &(init() << $1 >> "TypeLit"); }*/
    | SliceType { $$ = &(init() << $1 >> "TypeLit"); }
    | MapType { $$ = &(init() << $1 >> "TypeLit"); }
    ;

/*PointerType:*/
    /*STAR BaseType { $$ = &(init() << $1 << $2 >> "PointerType"); }*/
    /*;*/

BaseType:
    OperandName { $$ = &(init() << $1 >> "BaseType"); }
    ;

ArrayType:
    '[' ArrayLength ']' ElementType  {
        /* TODO Handle length */
        $$ = &(init() << $2 << $4 >> "ArrayType");
        $$->types = $4->types;
        $$->names = $4->names;
    }
    ;

ArrayLength:
    Expression  { $$ = &(init() << $1 >> "ArrayLength"); }
    ;

Operand:
    Literal              { $$ = &(init() << $1 >> "Operand"); }
    | OperandName        { $$ = &(init() << $1 >> "Operand"); }
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
    IDENT            {
        $$ = &(init() << $1 >> "OperandName");
        $$->types.push_back(new gotype(string($1, strlen($1))));
        $$->names.push_back(string($1, strlen($1)));
    }
    | '(' OperandName ')' {
        $$ = &(init() << $2 >> "OperandName");
        $$->types = $2->types;
        $$->names = $2->names;
    }
    | STAR OperandName {
        $$ = &(init() << $1 << $2 >> "OperandName");
        /* TODO Fix */
        $$->types = $2->types;
        $$->names = $2->names;
    }
    | LiteralType        {
        $$ = &(init() << $1 >> "OperandName");
        $$->types = $1->types;
        $$->names = $1->names;
      }
    | OperandName '.' IDENT {
        $$ = &(init() << $1 << $3 >> "OperandName");
        $$->types = $1->types;
        $$->names = $1->names;
      }
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
