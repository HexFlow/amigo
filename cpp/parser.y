%{
#include <cstdio>
#include <sstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <string>
#include <unordered_map>
#include "node.h"
#include "type.h"
#define YYDEBUG 1
#define ERROR(a,b) cout<<"[ERROR] "<<(a)<<(b)<<endl
#define WARN(a,b) cout<<"[WARN] "<<(a)<<(b)<<endl
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);

string tstr(char *s) {
    return string(s, strlen(s));
}

// SYMBOL TABLE CONSTRUCTS
int node_id = 0;
int scope_id = 0;
string scope_prefix = "0-";

umap<string, Type*> stable; // symbols (a is an int)
umap<string, Type*> ttable; // types (due to typedef or predeclared)

/*
void tableinsert(umap<string, Object*> &table, string name, Object *obj) {
    bool found = false;
    found = (stable.find(name) != stable.end());
    if (!found) {
        found = (ttable.find(name) != ttable.end());
        if (!found) {
            table.insert({name, obj});
        } else {
            ERROR << name << " already declared as a type in this scope" << endl;
        }
    }
    else {
        ERROR << name << " already declared as a symbol in this scope" << endl;
    }
}
*/

void typeInsert(string name, Type* tp) {
    bool found = (ttable.find(name) != ttable.end());
    if(found) {
        ERROR(name, " already declared as a type");
        exit(1);
    } else {
        ttable[name] = tp;
    }
}

void symInsert(string name, Type* tp) {
    bool found = (stable.find(name) != stable.end());
    if(found) {
        ERROR(name, " already declared as a symbol");
        exit(1);
    } else {
        stable[name] = tp;
    }
}

bool isType(string name) {
    return (ttable.find(name) != ttable.end());
}

bool isSymbol(string name) {
    return (stable.find(name) != ttable.end());
}

string getSymType(string name) {
    string cur_prefix = scope_prefix;
    while(cur_prefix != "") {
        string id = cur_prefix + name;
        if(isSymbol(id)) {
            return stable[id]->getType();
        }
        cur_prefix = cur_prefix.substr(cur_prefix.find("-") + 1);
    }
    ERROR(name, ": Symbol's Type not found. Variable undeclared?");
    exit(1);
}

void inittables() {
    /*ttable.insert({"void", new Object("void")});*/
    /*ttable.insert({"int", new Object("int")});*/
    /*ttable.insert({"float", new Object("float")});*/
    /*ttable.insert({"string", new Object("string")});*/
}

void printtables() {
    cout << endl << endl << "Symbol table:" << endl;
    /*for(auto elem: stable) {*/
        /*cout << elem.first << " :: ";*/
        /*cout << elem.second->base->tostring();*/
        /*cout << endl;*/
    /*}*/
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
    for(int i=0; i<n->children.size(); i++) {
        child s = n->children[i];
        if(s.type == 0) {
            string child = print(s.nt);
            cout << name << " -- " << child << endl;
        } else {
            cout << "_" + to_string(node_id) <<
                    "[label=\"" << escape_json(s.t) << "\"]" << endl;
            cout << name << " -- " << "_" + to_string(node_id++) << endl;
        }
    }
    /*while(id1 < n->children_nt.size() || id2 < n->children_t.size()) {*/
        /*if(id1 < n->children_nt.size()) {*/
            /*string child = print(n->children_nt[id1++]);*/
            /*cout << name << " -- " << child << endl;*/
        /*}*/

        /*if(id2 < n->children_t.size()) {*/
            /*cout << "_" + to_string(node_id) <<*/
              /*"[label=\"" << escape_json(n->children_t[id2++]) << "\"]" << endl;*/
            /*cout << name << " -- " << "_" + to_string(node_id++) << endl;*/
        /*}*/
    /*}*/
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

%token <sval> INT FLOAT IDENT BIN_OP DUAL_OP REL_OP MUL_OP ADD_OP UN_OP ECURLY
%token <sval> RAW_ST INR_ST ASN_OP LEFT INC DEC DECL CONST DOTS FUNC MAP
%token <sval> GO RETURN BREAK CONT GOTO FALL IF ELSE SWITCH CASE END STAR MAKE NEW
%token <sval> DEFLT SELECT TYPE ISOF FOR RANGE DEFER VAR IMPORT PACKGE STRUCT
%type <nt> SourceFile Expression Block StatementList Statement SimpleStmt
%type <nt> EmptyStmt ExpressionStmt SendStmt Channel IncDecStmt MapType
%type <nt> Assignment ShortVarDecl Declaration ConstDecl ConstSpecList VarSpec
%type <nt> Signature Result Parameters ParameterList ParameterDecl
%type <nt> ConstSpec MethodDecl Receiver TopLevelDecl LabeledStmt
%type <nt> GoStmt ReturnStmt BreakStmt ContinueStmt GotoStmt StructType
%type <nt> FunctionDecl FunctionName VarSpecList FallthroughStmt
%type <nt> Function FunctionBody ForStmt ForClause RangeClause InitStmt
%type <nt> PostStmt Condition DeferStmt UnaryExpr PrimaryExpr
%type <nt> Selector Index Slice TypeDecl TypeSpecList TypeSpec VarDecl
%type <nt> TypeAssertion Arguments ExpressionList ArrayType CompositeLit
%type <nt> LiteralValue ElementList KeyedElement Key Element
%type <nt> Operand Literal BasicLit OperandName ImportSpec IfStmt
%type <nt> UnaryOp BinaryOp String ImportPath SliceType LiteralType
%type <nt> PackageClause ImportDeclList ImportDecl ImportSpecList TopLevelDeclList
%type <nt> FieldDeclList FieldDecl MakeExpr StructLiteral KeyValList Type
/*%type <nt> TypeName InterfaceTypeName*/
%type <nt> QualifiedIdent PointerType IdentifierList
%%
SourceFile:
    PackageClause ';' ImportDeclList TopLevelDeclList { $$ = &(init() << $1 << $3 << $4 >> "SourceFile"); printTop($$); }
    ;

Block:
    ECURLY OPENB StatementList CLOSEB '}' { $$ = &(init() << $3 >> "Block"); }
    ;

OPENB:
    /* empty */ {
        scope_id++;
        scope_prefix = (to_string(scope_id) + "-" + scope_prefix);
    }
    ;

CLOSEB:
    /* empty */ {
        scope_prefix = scope_prefix.substr(scope_prefix.find("-") + 1);
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
    /* | SwitchStmt      { $$ = &(init() << $1 >> "Statement"); } */
    /* | SelectStmt      { $$ = &(init() << $1 >> "Statement"); } */
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
    ExpressionList ASN_OP ExpressionList { $$ = &(init() << $1 << $2 << $3 >> "Assignment"); }
    ;

ShortVarDecl:
    ExpressionList DECL ExpressionList   {
        $$ = &(init() << $1  << $3 >> "ShortVarDecl");
 //     auto s1 = AST($1).children;
 //     auto s2 = AST($3).children;

 //     /* TODO: Remove the false when next TODO is finished */
 //     if (s1.size() != s2.size() && false) {
 //         ERROR << "Expected " << s1.size()
 //               << " items on right of :=, found " << s2.size() << endl;
 //     } else {
 //         for (int i=0; i<s1.size(); i++) {
 //             if (s1[i]->classtype != _BasicType) {
 //                 ERROR << "Expected identifier list on left side of :="
 //                       << endl;
 //                 break;
 //             }
 //             /* TODO: We need to pick type from RHS */
 //             tableinsert(stable, scope_prefix + s1[i]->name,
 //                         new Object(s1[i]->name, ttable["int"]));
 //         }
 //     }
    }
    ;

VarDecl:
    /* VAR '(' VarSpecList ')' { $$ = &(init() << $3 >> "VarDecl"); } */
    VAR VarSpec           { $$ = &(init() << $2 >> "VarDecl"); }
    ;

VarSpec:
    IdentifierList Type {
        $$ = &(init() << $1 << $2 >> "VarSpec");
//      for (auto child: AST($1).children) {
//          tableinsert(stable, scope_prefix + child->name,
//                      new Object(child->name, $2->ast));
//      }
    }
    | IdentifierList Type '=' ExpressionList {
        $$ = &(init() << $1 << $2 << $4 >> "VarSpec");
//      for (auto child: AST($1).children) {
//          tableinsert(stable, scope_prefix + child->name,
//              new Object(child->name, $2->ast));
//      }
    }
    | IdentifierList '=' ExpressionList      {
        $$ = &(init() << $1 << $3 >> "VarSpec");
      }
    ;

Declaration:
    TypeDecl { $$ = &(init() << $1 >> "Declaration"); }
    | VarDecl  { $$ = &(init() << $1 >> "Declaration"); }
    ;

FunctionDecl:
    FUNC IDENT Signature { $$ = &(init() << $2 << $3 >> "FunctionDecl"); }
    | FUNC IDENT Function {
        $$ = &(init() << $2 << $3 >> "FunctionDecl");
        /*delete $$->ast;*/
        /*$$->ast = new Object("FunctionDecl", GoExpr);*/
        /*Object *tmp = new Object(tstr($2), AST($3).children[0]);*/
        /*cout << tmp->base->tostring();*/
        /*tableinsert(stable, scope_prefix + tstr($2), tmp);*/
        /*AST($$) << *tmp;*/
    }
    ;

Function:
    Signature Block {
        $$ = &(init() << $1 << $2 >> "Function");
        /*delete $$->ast;*/
        /*$$->ast = new Object("Function", GoExpr);*/
        /*AST($$) << AST($1);*/
    }
    ;

Signature:
    Parameters          {
        $$ = &(init() << $1 >> "Signature");
        /*AST($$) <<= AST($1);*/
        /*AST($$).ret = ttable["void"];*/
    }
    | Parameters Result { $$ = &(init() << $1 << $2 >> "Signature"); }
    ;

Result:
    Parameters { $$ = &(init() << $1 >> "Result"); }
    | Type { $$ = &(init() << $1 >> "Result"); }
    ;

Parameters:
    '('  ')'                    {
        $$ = &(init() >> "Parameters");
        /*$$->ast = ttable["void"];*/
    }
    | '(' ParameterList  ')'    {
        $$ = &(init() << $2 >> "Parameters");
        /*AST($$).args = AST($2).children;*/
        /*AST($$).classtype = _FunctionType;*/
      }
    | '(' ParameterList ',' ')' {
        $$ = &(init() << $2 >> "Parameters");
        /*AST($$).args = AST($2).children;*/
        /*AST($$).classtype = _FunctionType;*/
      }
    ;

ParameterList:
    ParameterDecl {
        $$ = &(init() << $1 >> "ParameterList");
        /*AST($$) << AST($1);*/
    }
    | ParameterList ',' ParameterDecl {
        $$ = &(init() << $1 << $3 >> "ParameterList");
        /*AST($$) += AST($1);*/
        /*AST($$) << AST($3);*/
    }
    ;

ParameterDecl:
    IDENT Type {
        $$ = &(init() << $1 << $2 >> "ParameterDecl");
        /*tableinsert(stable, scope_prefix + tstr($1), new Object(tstr($1), $2->ast));*/
        /*AST($$) <<= AST($2);*/
    }
    ;

IdentifierList:
    IDENT {
        $$ = &(init() << $1 >> "IdentifierList");
        /*AST($$) << *(new Object(tstr($1)));*/
    }
    | IdentifierList ',' IDENT {
        $$ = &(init() << $1 << $3 >> "IdentifierList");
        /*AST($$) += AST($1);*/
        /*AST($$) << *(new Object(tstr($3)));*/
      }
    ;

QualifiedIdent:
    IDENT '.' IDENT { $$ = &(init() << $1 << $3 >> "QualifiedIdent"); }
    ;

MethodDecl:
    FUNC Receiver IDENT Signature  { $$ = &(init() << $2 << $3 << $4 >> "MethodDecl"); }
    | FUNC Receiver IDENT Function { $$ = &(init() << $2 << $3 << $4 >> "MethodDecl"); }
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
    | '[' DOTS ']' Operand        { $$ = &(init() << $2 << $4 >> "LiteralType"); }
    | SliceType                {
        $$ = &(init() << $1 >> "LiteralType");
        /*AST($$) <<= AST($1);*/
    }
    | MapType                  { $$ = &(init() << $1 >> "LiteralType"); }
    ;

Type:
    LiteralType          { $$ = &(init() << $1 >> "Type"); }
    | OperandName        { $$ = &(init() << $1 >> "Type"); }
    | PointerType        { $$ = &(init() << $1 >> "Type"); }
    ;

Operand:
    Literal              {
        $$ = &(init() << $1 >> "Operand");
        /*AST($$) <<= AST($1);*/
    }
    | PointerType        {
        $$ = &(init() << $1 >> "Operand");
        /*AST($$) <<= AST($1);*/
    }
    | OperandName        {
        $$ = &(init() << $1 >> "Operand");
        /*AST($$) <<= AST($1);*/
    }
    | '(' Expression ')' {
        $$ = &(init() << $2 >> "Operand");
        /*AST($$) <<= AST($2);*/
      }
    ;

OperandName:
    IDENT            {
        $$ = &(init() << $1 >> "OperandName");
        /*$$->ast = new Object(tstr($1));*/
    }
    | QualifiedIdent {
        $$ = &(init() << $1 >> "OperandName");
        /*AST($$) <<= AST($1);*/
    }
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
    '[' ']' Operand  {
        $$ = &(init() << $3 >> "SliceType");
        /*AST($$).base = $3->ast;*/
        /*AST($$).classtype = _ArrayType;*/
    }
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
    IDENT ':' Statement { $$ = &(init() << $1 << $3 >> "LabeledStmt"); }
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
    | BREAK IDENT { $$ = &(init() << $2 >> "BreakStmt"); }
    ;

ContinueStmt:
    CONT         { $$ = &(init() >> "ContinueStmt"); }
    | CONT IDENT { $$ = &(init() << $2 >> "ContinueStmt"); }
    ;

GotoStmt:
    GOTO IDENT   { $$ = &(init() << $2 >> "GotoStmt"); }
    ;

FallthroughStmt:
    FALL         { $$ = &(init() >> "FallthroughStmt"); }
    ;

IfStmt:
    IF OPENB Expression Block CLOSEB { $$ = &(init() << $3 << $4 >> "IfStmt"); }
    | IF OPENB SimpleStmt ';' Expression Block CLOSEB { $$ = &(init() << $3 << $5 << $6 >> "IfStmt"); }
    | IF OPENB Expression Block ELSE Block CLOSEB { $$ = &(init() << $3 << $4 << $6 >> "IfStmt"); }
    | IF OPENB Expression Block ELSE IfStmt CLOSEB { $$ = &(init() << $3 << $4 << $6 >> "IfStmt"); }
    | IF OPENB SimpleStmt ';' Expression Block ELSE IfStmt CLOSEB { $$ = &(init() << $3 << $5 << $6 << $8 >> "IfStmt"); }
    | IF OPENB SimpleStmt ';' Expression Block ELSE Block CLOSEB { $$ = &(init() << $3 << $5 << $6 << $8 >> "IfStmt"); }
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

Expression:
    UnaryExpr { $$ = &(init() << $1 >> "Expression"); }
    | Expression BinaryOp Expression {$$ = &(init() << $1 << $2 << $3 >> "Expression");}
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
    ;

StructLiteral:
    '{' KeyValList '}' { $$ = &(init() << $2 >> "StructLiteral"); }
    ;

KeyValList:
    /* empty */  { $$ = &(init() >> "KeyValList"); }
    | Expression ':' Expression { $$ = &(init() << $1 << $3 >> "KeyValList"); }
    | Expression ':' Expression ',' KeyValList { $$ = &(init() << $1 << $3 << $5 >> "KeyValList"); }

MakeExpr:
    MAKE '(' Type ',' ExpressionList ')' { $$ = &(init() << $3 << $5 >> "MakeExpr"); }
    | NEW  '(' Type ')' { $$ = &(init() << $3 >> "NewExpr"); }
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
    ;

TypeSpec:
    IDENT Type { $$ = &(init() << $1 << $2 >> "TypeSpec"); }
    ;

TypeAssertion:
    '.' '(' Type ')'  { $$ = &(init() << $3 >> "TypeAssertion"); }
    ;

Arguments:
    '(' ')'                       { $$ = &(init() >> "Arguments"); }
    | '(' ExpressionList ')'      { $$ = &(init() << $2 >> "Arguments"); }
    | '(' ExpressionList DOTS ')' { $$ = &(init() << $2 << $3 >> "Arguments"); }
    ;

ExpressionList:
    Expression                      {
        $$ = &(init() << $1 >> "ExpressionList");
        /*AST($$) << AST($1);*/
    }
    | ExpressionList ',' Expression {
        $$ = &(init() << $1 << $3 >> "ExpressionList");
        /*AST($$) += AST($1);*/
        /*AST($$) << AST($3);*/
    }
    ;

MapType:
    MAP '[' Type ']' Type { $$ = &(init() << $1 << $3 << $5 >> "MapType"); }
    ;

StructType:
    STRUCT '{' FieldDeclList '}' { $$ = &(init() << $1 << $3 >> "StructType"); }
    | STRUCT ECURLY FieldDeclList '}' { $$ = &(init() << $1 << $3 >> "StructType"); }
    ;

FieldDeclList:
    /* empty */ { $$ = &(init() >> "FieldDeclList"); }
    | FieldDeclList FieldDecl ';' { $$ = &(init() << $1 << $2 >> "FieldDeclList"); }
    ;

FieldDecl:
    ExpressionList Type String { $$ = &(init() << $1 << $2 << $3 >> "FieldDecl"); }
    | ExpressionList Type { $$ = &(init() << $1 << $2 >> "FieldDecl"); }
    /* | AnonymousField Tag { $$ = &(init() << $1 << $2 >> "FieldDecl"); } */
    /* | AnonymousField { $$ = &(init() << $1 >> "FieldDecl"); } */
    ;

PointerType:
    STAR Operand {
        $$ = &(init() << $1 << $2 >> "PointerType");
        /*$$->ast = new Object($2->ast, true);*/
    }
    ;

ArrayType:
    '[' Expression ']' Operand  { $$ = &(init() << $2 << $4 >> "ArrayType"); }
    ;

Literal:
    BasicLit { $$ = &(init() << $1 >> "Literal"); }
    | CompositeLit { $$ = &(init() << $1 >> "Literal"); }
    /* | FunctionLit */
    ;

BasicLit:
    INT         {
        $$ = &(init() << $1 >> "BasicLit");
        /*$$->ast = new Object(tstr($1), ttable["int"]);*/
    }
    | FLOAT     {
        $$ = &(init() << $1 >> "BasicLit");
        /*$$->ast = new Object(tstr($1), ttable["float"]);*/
    }
    | String    {
        $$ = &(init() << $1 >> "BasicLit");
        /**($$->ast) = $1->ast;*/
    }
    ;

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
