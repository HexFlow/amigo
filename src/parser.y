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
#include "helpers.h"
#define YYDEBUG 1
#define COPS(A, B) { A->data = B->data; A->type = B->type; };
#define HANDLE_BIN_OP(A, B, C, D, aA, aB, aC, aD)                                                  \
    A->data = new Data(string(C) + "binary");                                                      \
    A->data->child = B->data;                                                                      \
    last(A->data->child)->next = D->data;                                                          \
    if(B->type == NULL) {                                                                          \
        ERROR_N("Missing type info in node", B->data->name, aB);                                   \
        exit(1);                                                                                   \
    }                                                                                              \
    if(D->type == NULL) {                                                                          \
        ERROR_N("Missing type info in node", D->data->name, aD);                                   \
        exit(1);                                                                                   \
    }                                                                                              \
    if(D->type->getType() != B->type->getType()) {                                                 \
        ERROR_N("Mismatched types : ", B->type->getType() + " and " + D->type->getType(), aD);     \
        exit(1);                                                                                   \
    }                                                                                              \
    A->type = B->type;

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

Type *curFxnType = NULL;

umap<string, Type*> stable; // symbols (a is an int)
umap<string, Type*> ttable; // types (due to typedef or predeclared)

%}
%locations

%union {
    node* nt;
    char *sval;
}

%token <sval> INT FLOAT IDENT B1 B2 B3 B4 B5 D4 D5 STAR ECURLY UN_OP
%token <sval> RAW_ST INR_ST ASN_OP LEFT INC DEC DECL CONST DOTS FUNC MAP
%token <sval> GO RETURN BREAK CONT GOTO FALL IF ELSE SWITCH CASE END MAKE NEW
%token <sval> DEFLT SELECT TYPE ISOF FOR RANGE DEFER VAR IMPORT PACKGE STRUCT
%type <nt> SourceFile Expression Expression1 Expression2 Expression3
%type <nt> Block StatementList Statement SimpleStmt Expression4 Expression5
%type <nt> EmptyStmt ExpressionStmt SendStmt Channel IncDecStmt MapType
%type <nt> Assignment ShortVarDecl Declaration ConstDecl ConstSpecList VarSpec
%type <nt> Signature Result Parameters ParameterList ParameterDecl TypeList
%type <nt> ConstSpec MethodDecl Receiver TopLevelDecl LabeledStmt
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
%%
SourceFile:
    PackageClause ';' ImportDeclList TopLevelDeclList {
        $$ = &(init() << $1 << $3 << $4 >> "SourceFile");
        $$->data = new Data("SourceFile");
        $$->data->child = $4->data;
        printTop($$->data);
    }
    ;

Block:
    ECURLY OPENB StatementList CLOSEB '}' {
        $$ = &(init() << $3 >> "Block");
        $$->data = $3->data;
    }
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
    StatementList Statement ';' {
        $$ = &(init() << $1 << $2 >> "StatementList");
        $$->data = $1->data;
        last($$->data->child)->next = $2->data;
    }
    | Statement ';' {
        $$ = &(init() << $1 >> "StatementList");
        $$->data = new Data("list");
        if($1->data == NULL) {
            ERROR_N("No AST attached", "", @1);
            exit(1);
        }
        $$->data->child = $1->data;
    }
    ;

Statement:
    Declaration       {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    | LabeledStmt     {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    | SimpleStmt      {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    | GoStmt          {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    | ReturnStmt      {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    | BreakStmt       {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    | ContinueStmt    {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    | GotoStmt        {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    /*| FallthroughStmt {*/
        /*$$ = &(init() << $1 >> "Statement");*/
    /*}*/
    | Block           {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    | IfStmt          {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    /* | SwitchStmt      { $$ = &(init() << $1 >> "Statement"); } */
    /* | SelectStmt      { $$ = &(init() << $1 >> "Statement"); } */
    | ForStmt         {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
    | DeferStmt       {
        $$ = &(init() << $1 >> "Statement");
    }
    ;

SimpleStmt:
    EmptyStmt        {
        $$ = &(init() << $1 >> "SimpleStmt");
        $$->data = $1->data;
    }
    | ExpressionStmt {
        $$ = &(init() << $1 >> "SimpleStmt");
        $$->data = $1->data;
    }
    | SendStmt       {
        $$ = &(init() << $1 >> "SimpleStmt");
        $$->data = $1->data;
    }
    | IncDecStmt     {
        $$ = &(init() << $1 >> "SimpleStmt");
        $$->data = $1->data;
    }
    | Assignment     {
        $$ = &(init() << $1 >> "SimpleStmt");
        $$->data = $1->data;
    }
    | ShortVarDecl   {
        $$ = &(init() << $1 >> "SimpleStmt");
        $$->data = $1->data;
    }
    ;

EmptyStmt:
    /* blank */ {
        $$ = &(init() >> "EmptyStmt");
        $$->data = new Data("");
    }
    ;

ExpressionStmt:
    Expression {
        $$ = &(init() << $1 >> "ExpressionStmt");
        $$->data = $1->data;
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
    }
    | Expression DEC {
        $$ = &(init() << $1 << $2 >> "IncDecStmt");
        $$->data = new Data(string($2)+"unary");
        $$->data->child = $1->data;
    }
    ;

Assignment:
    ExpressionList ASN_OP ExpressionList {
        $$ = &(init() << $1 << $2 << $3 >> "Assignment");
        Data* lhs = $1->data;
        Type* rhs = $3->type;
        Data* rhsd = $3->data;
        while(lhs != NULL || rhs != NULL) {
            if(lhs == NULL || rhs == NULL) {
                ERROR_N("= must have equal operands on LHS and RHS", "", @$);
                exit(1);
            }
            string varLeft = lhs->name;
            if(lhs->child != NULL) {
                ERROR_N("Non identifier to left of =", "", @1);
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
            if(getSymType(varLeft) != NULL) {
                if(getSymType(varLeft)->getType() != rhs->getType()) {
                    ERROR_N(varLeft, " has a different type than RHS " + rhs->getType(), @1);
                    exit(1);
                }
            } else {
                ERROR_N(varLeft, " variable has not been declared.", @1);
                exit(1);
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
        $$->data = new Data{$2};
        $$->data->child = parentleft;
    }
    ;

ShortVarDecl:
    ExpressionList DECL ExpressionList   {
        $$ = &(init() << $1  << $3 >> "ShortVarDecl");
        bool newVar = false;
        Data*lhs = $1->data;
        Type*rhs = $3->type;
        Data*rhsd = $3->data;
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
            }
            lhs = lhs->next;
            rhs = rhs->next;
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
    }
    ;

VarDecl:
    /* VAR '(' VarSpecList ')' { $$ = &(init() << $3 >> "VarDecl"); } */
    VAR VarSpec           {
        $$ = &(init() << $2 >> "VarDecl");
        $$->data = $2->data;
    }
    ;

VarSpec:
    IdentifierList Type {
        $$ = &(init() << $1 << $2 >> "VarSpec");
        Data *data = $1->data;
        while(data != 0) {
            if(isInScope(data->name)) {
                ERROR_N(data->name, " is already defined in this scope", @1);
                exit(1);
            }
            cout << "// " << $2->type << __LINE__ << endl;
            symInsert(scope_prefix+data->name, $2->type);
            $$->type = $2->type;
            data = data->next;
        }
        $$->data = new Data("");
    }
    | IdentifierList Type ASN_OP ExpressionList {
        $$ = &(init() << $1 << $2 << $4 >> "VarSpec");
        Data *data = $1->data;
        while(data != 0) {
            if(isInScope(data->name)) {
                ERROR_N(data->name, " is already defined in this scope", @1);
                exit(1);
            }
            symInsert(scope_prefix+data->name, $2->type);
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
    }
    | VarDecl  {
        $$ = &(init() << $1 >> "Declaration");
        $$->data = $1->data;
    }
    ;

FunctionDecl:
    FUNC IDENT OPENB Signature CLOSEB {
        $$ = &(init() << $2 << $4 >> "FunctionDecl");
        symInsert(scope_prefix+$2, $4->type);
        $$->data = new Data("Function " + string($2));
    }
    | FUNC IDENT OPENB Function CLOSEB {
        $$ = &(init() << $2 << $4 >> "FunctionDecl");
        symInsert(scope_prefix+$2, $4->type);
        $$->data = new Data("Function " + string($2));
        $$->data->child = $4->data;
    }
    ;

Function:
    Signature { curFxnType = vectorToLinkedList(dynamic_cast<FunctionType*>($1->type)->retTypes); } Block {
        $$ = &(init() << $1 << $3 >> "Function");
        $$->type = $1->type;
        $$->data = $3->data;
        /* printTop($$->data); */
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

        Type*ptr = $1->type;
        while(ptr != NULL) {
            Type* tmp = ptr->clone();
            tmp->next = NULL;
            args.push_back(tmp);
            ptr = ptr->next;
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

        Type*ptr = $1->type;
        while(ptr != NULL) {
            Type* tmp = ptr->clone();
            tmp->next = NULL;
            args.push_back(tmp);
            ptr = ptr->next;
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
    | FUNC Receiver IDENT Function { $$ = &(init() << $2 << $3 << $4 >> "MethodDecl"); }
    ;

Receiver:
    Parameters { $$ = &(init() << $1 >> "Receiver"); }
    ;

TopLevelDeclList:
    TopLevelDeclList TopLevelDecl ';' {
        $$ = &(init() << $1 << $2 >> "TopLevelDeclList");
        $$->data = $1->data;
        last($$->data)->next = $2->data;
    }
    | TopLevelDecl ';' {
        $$ = &(init() << $1 >> "TopLevelDeclList");
        $$->data = $1->data;
    }
    ;

CompositeLit:
    LiteralType LiteralValue { $$ = &(init() << $1 << $2 >> "CompositeLit"); }
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
        if(!isType($1->data->name)) {
            ERROR_N("Invalid Type: ", $1->data->name, @1);
            exit(1);
        }
        $$->data = new Data($$->type->getType());
    }
    | PointerType        {
        $$ = &(init() << $1 >> "Type");
        $$->data = $1->data;
        $$->type = $1->type;
        $$->data = new Data($$->type->getType());
    }
    ;

Operand:
    Literal              {
        $$ = &(init() << $1 >> "Operand");
        $$->type = $1->type;
        $$->data = $1->data;
    }
    | OperandName        {
        $$ = &(init() << $1 >> "Operand");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    | '(' Expression ')' {
        $$ = &(init() << $2 >> "Operand");
        $$->type = $2->type;
        $$->data = $2->data;
      }
    ;

OperandName:
    IDENT            {
        $$ = &(init() << $1 >> "OperandName");
        $$->data = new Data{$1};
        $$->type = getSymType($1)?getSymType($1):new BasicType("undefined");
    }
    /* | QualifiedIdent { */
    /*     $$ = &(init() << $1 >> "OperandName"); */
    /*     $$->data = $1->data; */
    /* } */
    ;

LiteralValue:
    '{' '}'                        { $$ = &(init() >> "LiteralValue"); }
    | ECURLY '}'                   { $$ = &(init() >> "LiteralValue"); }
    | '{' ElementList '}'          { $$ = &(init() << $2 >> "LiteralValue"); }
    | ECURLY ElementList '}'       { $$ = &(init() << $2 >> "LiteralValue"); }
    | '{' ElementList ',' '}'      { $$ = &(init() << $2 >> "LiteralValue"); }
    | ECURLY ElementList ',' '}'   { $$ = &(init() << $2 >> "LiteralValue"); }
    ;

SliceType:
    '[' ']' Type  {
        $$ = &(init() << $3 >> "SliceType");
        $$->type = new SliceType($3->type);
        $$->data = new Data($$->type->getType());
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
    }
    | RETURN ExpressionList {
        $$ = &(init() << $2 >> "ReturnStmt");
        $$->data = new Data(string($1));
        $$->data->child = $2->data;
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
            rT = rT->next;
            eT = eT->next;
        }
    }
    ;

BreakStmt:
    BREAK         {
        $$ = &(init() >> "BreakStmt");
        $$->data = new Data(string($1));
    }
    | BREAK IDENT {
        $$ = &(init() << $2 >> "BreakStmt");
        $$->data = new Data(string($1));
        $$->data->child = new Data($2);
    }
    ;

ContinueStmt:
    CONT         {
        $$ = &(init() >> "ContinueStmt");
        $$->data = new Data(string($1));
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
    }
    ;

ForStmt:
    FOR Block {
        $$ = &(init() << $2 >> "ForStmt");
        $$->data = new Data("For");
        $$->data->child = new Data("Body");
        $$->data->child->child = $2->data;
    }
    | FOR OPENB Expression Block CLOSEB {
        $$ = &(init() << $3 << $4 >> "ForStmt");
        $$->data = new Data("For");
        Data *ptr = $$->data;
        ptr->child = new Data("Condition"); ptr = ptr->child;
        ptr->child = $3->data;
        ptr->next = new Data("Body"); ptr = ptr->next;
        ptr->child = $4->data;
    }
    | FOR OPENB ForClause Block CLOSEB {
        $$ = &(init() << $3 << $4 >> "ForStmt");
        $$->data = new Data("For");
        Data *ptr = $$->data;
        ptr->child = $3->data;
        ptr->next = new Data("Body"); ptr = ptr->next;
        ptr->child = $4->data;
    }
    | FOR OPENB RangeClause Block CLOSEB {
        $$ = &(init() << $3 << $4 >> "ForStmt");
        $$->data = new Data("For");
        Data *ptr = $$->data;
        ptr->child = $3->data;
        ptr->next = new Data("Body"); ptr = ptr->next;
        ptr->child = $4->data;
    }
    ;

ForClause:
    SimpleStmt ';'  ';' SimpleStmt  {
        $$ = &(init() << $1 << $4 >> "ForClause");
        $$->data = new Data("ForClause");
        Data *ptr = $$->data;
        ptr->child = new Data("InitClause"); ptr = ptr->child;
        ptr->child = $1->data;
        ptr->next = new Data("PostClause"); ptr = ptr->next;
        ptr->child = $4->data;
    }
    | SimpleStmt ';' Expression ';' SimpleStmt  {
        $$ = &(init() << $1 << $3  << $5 >> "ForClause");
        $$->data = new Data("ForClause");
        Data *ptr = $$->data;
        ptr->child = new Data("InitClause"); ptr = ptr->child;
        ptr->child = $1->data;
        ptr->next = new Data("ConditionClause"); ptr = ptr->next;
        ptr->child = $3->data;
        ptr->next = new Data("PostClause"); ptr = ptr->next;
        ptr->child = $5->data;
    }
    ;

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
        $$->data = $1->data;
        $$->type = $1->type;
    }
    ;

Expression1:
    Expression1 B1 Expression2 {
        $$ = &(init() << $1 << $2 << $3 >> "Expression1");
        HANDLE_BIN_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression2 {
        $$ = &(init() << $1 >> "Expression2");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    ;

Expression2:
    Expression2 B2 Expression3 {
        $$ = &(init() << $1 << $2 << $3 >> "Expression2");
        HANDLE_BIN_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression3 {
        $$ = &(init() << $1 >> "Expression2");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    ;

Expression3:
    Expression3 B3 Expression4 {
        $$ = &(init() << $1 << $2 << $3 >> "Expression3");
        HANDLE_BIN_OP($$, $1, $2, $3, @$, @1, @2, @3);
    }
    | Expression4 {
        $$ = &(init() << $1 >> "Expression3");
        $$->data = $1->data;
        $$->type = $1->type;
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
        $$->data = $1->data;
        $$->type = $1->type;
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
        $$->data = $1->data;
        $$->type = $1->type;
    }
    ;

UnaryExpr:
    PrimaryExpr {
        $$ = &(init() << $1 >> "UnaryExpr");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    | UnaryOp PrimaryExpr {
        $$ = &(init() << $1 << $2 >> "UnaryExpr");
        $$->data = new Data($1->data->name + "unary");
        $$->data->child = $2->data;
        $$->type = $1->type;
    }
    ;

PrimaryExpr:
    Operand {
        $$ = &(init() << $1 >> "PrimaryExpr");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    | MakeExpr {
        $$ = &(init() << $1 >> "PrimaryExpr");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    | PrimaryExpr Selector {
        $$ = &(init() << $1 << $2 >> "PrimaryExpr");
        $$->type = isValidMemberOn($1->data, $2->data);
        $$->data = new Data("MemberAccess");
        $$->data->child = $1->data;
        $$->data->child->next = $2->data;
    }
    | PrimaryExpr Index {
        $$ = &(init() << $1 << $2 >> "PrimaryExpr");
        Type*tp = $1->type;
        if(tp->classType == SLICE_TYPE) {
            SliceType *tp = (SliceType*) $1->type;
            $$->type = tp->base->clone();
            if($2->type->getType() != "int") {
                ERROR_N("Non integer index provided", "", @2);
                exit(1);
            }
        } else if(tp->classType == ARRAY_TYPE) {
            ArrayType *tp = (ArrayType*) $1->type;
            $$->type = tp->base->clone();
            if($2->type->getType() != "int") {
                ERROR("Non integer index provided", "");
                exit(1);
            }
        } else if(tp->classType == MAP_TYPE) {
            MapType *tp = (MapType*) $1->type;
            if($2->type->getType() != tp->key->getType()) {
                ERROR("Index of type " + $2->type->getType() + " provided, when needed was: ", tp->key->getType());
                exit(1);
            }
            /*$$->type = tp->base->clone();*/
        } else {
            ERROR("It is not possible to use index on something of type: ", tp->getType());
            exit(1);
        }
        $$->data = new Data("methodcall");
        $$->data->child = $1->data;
        $$->data->child->next = new Data("__VALUE_AT__");
        $$->data->child->next->next = $2->data;

    }
    | PrimaryExpr Slice  { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr TypeAssertion { $$ = &(init() << $1 << $2 >> "PrimaryExpr"); }
    | PrimaryExpr Arguments {
        $$ = &(init() << $1 << $2 >> "PrimaryExpr");
        $$->data = new Data("FunctionCall");
        $$->data->child = $1->data;
        $$->data->child->next = $2->data;
        $$->type = resultOfFunctionApp($1->type, $2->type);
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
    }
    | MAKE '(' Type ',' Expression ')' {
        $$ = &(init() << $3 << $5 >> "MakeExpr");
        $$->type = $3->type;
        $$->data = new Data("Make");
        $$->data->child = $5->data;
    }
    | MAKE '(' Type ')' {
        $$ = &(init() << $3 >> "MakeExpr");
        $$->type = $3->type;
        $$->data = new Data("Make");
    }
    | NEW '(' Type ')' {
        $$ = &(init() << $3 >> "NewExpr");
        $$->type = $3->type;
        $$->data = new Data("New");
    }
    ;

Selector:
    '.' IDENT  {
        $$ = &(init() << $2 >> "Selector");
        $$->data = new Data(string($2));
    }
    ;

Index:
    '[' Expression ']'  {
        $$ = &(init() << $2 >> "Index");
        $$->data = $2->data;
        $$->type = $2->type;
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
    | '(' ExpressionList ')'      { $$ = &(init() << $2 >> "Arguments"); COPS($$, $2); }
    | '(' ExpressionList DOTS ')' { $$ = &(init() << $2 << $3 >> "Arguments"); COPS($$, $2); }
    ;

ExpressionList:
    Expression                      {
        $$ = &(init() << $1 >> "ExpressionList");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    | ExpressionList ',' Expression {
        $$ = &(init() << $1 << $3 >> "ExpressionList");
        $$->data = $1->data;
        last($$->data)->next = $3->data;
        $$->type = $1->type;
        last($$->type)->next = $3->type;
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
    STAR Operand {
        $$ = &(init() << $1 << $2 >> "PointerType");
        /*$$->ast = new Object($2->ast, true);*/
    }
    ;

ArrayType:
    '[' Expression ']' Type  {
        $$ = &(init() << $2 << $4 >> "ArrayType");
        if($2->type->getType() == "int") {
            if(isLiteral($2)) {
                int n = getIntValue($2);
                Type* tp = $2->type->clone();
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
        $$->type = $1->type;
        $$->data = $1->data;
    }
    | CompositeLit {
        $$ = &(init() << $1 >> "Literal");
        $$->type = $1->type;
        $$->data = $1->data;
    }
    /* | FunctionLit */
    ;

BasicLit:
    INT         {
        $$ = &(init() << $1 >> "BasicLit");
        $$->data = new Data{$1};
        $$->type = new BasicType("int");
    }
    | FLOAT     {
        $$ = &(init() << $1 >> "BasicLit");
        $$->data = new Data{$1};
        $$->type = new BasicType("float");
    }
    | String    {
        $$ = &(init() << $1 >> "BasicLit");
        $$->data = $1->data;
        $$->type = new BasicType("string");
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
    ;

String:
    RAW_ST         {
        $$ = &(init() << $1 >> "String");
        $$->data = new Data{$1};
    }
    | INR_ST       {
        $$ = &(init() << $1 >> "String");
        $$->data = new Data{$1};
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