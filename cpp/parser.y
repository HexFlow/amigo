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

umap<string, Type*> stable; // symbols (a is an int)
umap<string, Type*> ttable; // types (due to typedef or predeclared)

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
%type <nt> Signature Result Parameters ParameterList ParameterDecl TypeList
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
        cout << "//" << $$->data << "LALALALALA" << endl;
    }
    | Statement ';' {
        $$ = &(init() << $1 >> "StatementList");
        $$->data = new Data("list");
        if($1->data == NULL) {
            ERROR("No AST attached", "");
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
    | LabeledStmt     { $$ = &(init() << $1 >> "Statement"); }
    | SimpleStmt      {
        $$ = &(init() << $1 >> "Statement");
        $$->data = $1->data;
    }
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
        Data*lhs = $1->data;
        Type*rhs = $3->type;
        while(lhs != NULL || rhs != NULL) {
            string varLeft = lhs->name;
            if(lhs->child != NULL) {
                ERROR("Non identifier to left of =", "");
                exit(1);
            }
            if(lhs == NULL || rhs == NULL) {
                ERROR(":= must have equal operands on LHS and RHS", "");
                exit(1);
            }
            if(!isValidIdent(varLeft)) {
                ERROR(varLeft, " is not a valid Identifier");
                exit(1);
            }
            if(getSymType(varLeft) != NULL) {
                if(getSymType(varLeft)->getType() != rhs->getType()) {
                    ERROR(varLeft, " has a different type than RHS " + rhs->getType());
                    exit(1);
                }
            } else {
                ERROR(varLeft, " variable has not been declared.");
                exit(1);
            }
            lhs = lhs->next;
            rhs = rhs->next;
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
        while(lhs != NULL || rhs != NULL) {
            string varLeft = lhs->name;
            if(lhs->child != NULL) {
                ERROR("Non identifier to left of :=", "");
                exit(1);
            }
            if(lhs == NULL || rhs == NULL) {
                ERROR(":= must have equal operands on LHS and RHS", "");
                exit(1);
            }
            if(!isValidIdent(varLeft)) {
                ERROR(varLeft, " is not a valid Identifier");
                exit(1);
            }
            if(isInScope(varLeft)) {
                if(getSymType(varLeft)->getType() != rhs->getType()) {
                    ERROR(varLeft, " has a different type than RHS");
                    exit(1);
                }
            } else {
                newVar = true;
                symInsert(scope_prefix+varLeft, rhs); //TODO check rhs type not "undefined"
            }
            lhs = lhs->next;
            rhs = rhs->next;
        }
        if(newVar == false) {
            ERROR("No new variables found to the left of := ", "");
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
                ERROR(data->name, " is already defined in this scope");
                exit(1);
            }
            cout << "// " << $2->type << __LINE__ << endl;
            symInsert(scope_prefix+data->name, $2->type);
            $$->type = $2->type;
            data = data->next;
        }
        $$->data = new Data("");
    }
    | IdentifierList Type '=' ExpressionList {
        $$ = &(init() << $1 << $2 << $4 >> "VarSpec");
        Data *data = $1->data;
        while(data != 0) {
            if(isInScope(data->name)) {
                ERROR(data->name, " is already defined in this scope");
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
    | IdentifierList '=' ExpressionList      {
        $$ = &(init() << $1 << $3 >> "VarSpec");
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
    FUNC IDENT Signature {
        $$ = &(init() << $2 << $3 >> "FunctionDecl");
    }
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
        $$->type = $1->type;
        $$->data = $1->data;
        last($$->data)->next = $2->data;
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
        cout << "//" << $$->type->getType() << "LALALA" << endl;
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
        cout << "//" << $$->type->getType() << "LALALA" << endl;
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
                ERROR(data->name, " is already defined in this scope");
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
    LiteralType          {
        $$ = &(init() << $1 >> "Type");
        $$->data = $1->data;
    }
    | OperandName        {
        $$ = &(init() << $1 >> "Type");
        $$->data = $1->data;
        $$->type = new BasicType($1->data->name);
        if(!isType($1->data->name)) {
            ERROR("Invalid Type: ", $1->data->name);
            exit(1);
        }
    }
    | PointerType        { $$ = &(init() << $1 >> "Type"); }
    ;

Operand:
    Literal              {
        $$ = &(init() << $1 >> "Operand");
        $$->type = $1->type;
        $$->data = $1->data;
    }
    | PointerType        {
        $$ = &(init() << $1 >> "Operand");
        /*AST($$) <<= AST($1);*/
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
    | QualifiedIdent {
        $$ = &(init() << $1 >> "OperandName");
        $$->data = $1->data;
    }
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
    UnaryExpr {
        $$ = &(init() << $1 >> "Expression");
        $$->data = $1->data;
        $$->type = $1->type;
    }
    | Expression BinaryOp Expression {
        $$ = &(init() << $1 << $2 << $3 >> "Expression");
        $$->data = new Data($2->data->name + "binary");
        $$->data->child = $1->data;
        last($$->data->child)->next = $3->data;
        if($1->type == NULL) {
            ERROR("Missing type info in node", $1->data->name);
            exit(1);
        }
        if($3->type == NULL) {
            ERROR("Missing type info in node", $3->data->name);
            exit(1);
        }
        if($3->type->getType() != $1->type->getType()) {
            ERROR("Mismatched types with binary operator not allowed:\n", $1->type->getType());
            ERROR($3->type->getType(), "");
            exit(1);
        }
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
    IdentifierList Type String {
        $$ = &(init() << $1 << $2 << $3 >> "FieldDecl");
        Type* ptr = $1->type;
        // HERE TODO
    }
    | IdentifierList Type {
        $$ = &(init() << $1 << $2 >> "FieldDecl");
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
    '[' Expression ']' Operand  { $$ = &(init() << $2 << $4 >> "ArrayType"); }
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
    | DUAL_OP      {
        $$ = &(init() << $1 >> "UnaryOp");
        $$->data = new Data{$1};
    }
    ;

BinaryOp:
    BIN_OP         {
        $$ = &(init() << $1 >> "BinaryOp");
        $$->data = new Data{$1};
    }
    | DUAL_OP      {
        $$ = &(init() << $1 >> "BinaryOp");
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
