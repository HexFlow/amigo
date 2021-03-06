#ifndef _HELPERS_H
#define _HELPERS_H
#include <cstdio>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>
#include "node.h"
#include "type.h"

#define ERROR(a, b) cout << "[ERROR] " << (a) << (b) << endl
#define ERROR_N(a, b, c)                                      \
    cout << endl << "[ERROR] " << (a) << (b) << endl;         \
    prettyError(c.first_line, c.first_column, c.last_column); \
    exit(1);
#define WARN(a, b) cout << "[WARN] " << (a) << (b) << endl
using namespace std;

string to_std_string(int a);

extern int node_id;
extern string scope_prefix;
extern string last_closed;
extern umap<string, Type *> stable;  // symbols (a is an int)
extern umap<string, Type *> ttable;  // types (due to typedef or predeclared)
extern string filepath;

string tstr(char *s);
/* template<typename T> */
/* T* last(T* ptr); */
/* Data *last(Data *ptr); */
/* Type *last(Type *ptr); */
char *concat(char *a, char *b);
void typeInsert(string name, Type *tp);
void symInsert(string name, Type *tp);
bool isType(string name);
bool isSymbol(string name);
bool isInScope(string name);
Type *getSymType(string name);
Type *isValidMemberOn(Type *, Data *, Data *);
Type *resultOfFunctionApp(Type *fxnType, Type *argType, bool isFFI);
Type *vectorToLinkedList(vector<Type *> &typs);
bool isDefined(string name);
void inittables();
void printtables();
bool isLiteral(node *n);
int getIntValue(node *n);
string nameInScope(string name);
void scopeExprClosed(vector<TAC::Instr *> &code);
void scopeExpr(vector<TAC::Instr *> &code);
string escape_json(const string &s);
string print(node *n);
string print(Data *n);
void printTop(node *n);
void printTop(Data *n);
bool isValidIdent(string name);
ostream &operator<<(ostream &os, Data *m);
string toString(ClassType tp);
void prettyError(int line, int col1, int col2);
void printCode(vector<TAC::Instr *> v);

Type *operatorResult(Type *a, Type *b, string op);

// Has to be in header, otherwise template is not instantiated
// http://stackoverflow.com/questions/8752837
template <typename T>
T *last(T *ptr) {
    while (ptr->next != NULL)
        ptr = ptr->next;
    return ptr;
}

#endif
