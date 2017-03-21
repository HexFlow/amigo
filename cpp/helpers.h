#ifndef _HELPERS_H
#define _HELPERS_H
#include <cstdio>
#include <sstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <string>
#include <unordered_map>
#include "node.h"
#include "type.h"
#define ERROR(a, b) cout << "[ERROR] " << (a) << (b) << endl
#define ERROR_N(a, b, c)                      \
    cout << "[ERROR] " << (a) << (b) << endl; \
    prettyError(c.first_line, c.first_column, c.last_column);
#define WARN(a, b) cout << "[WARN] " << (a) << (b) << endl
using namespace std;

extern int node_id;
extern string scope_prefix;
extern umap<string, Type *> stable;  // symbols (a is an int)
extern umap<string, Type *> ttable;  // types (due to typedef or predeclared)
extern string filepath;

string tstr(char *s);
Data *last(Data *ptr);
Type *last(Type *ptr);
char *concat(char *a, char *b);
void typeInsert(string name, Type *tp);
void symInsert(string name, Type *tp);
bool isType(string name);
bool isSymbol(string name);
bool isInScope(string name);
Type *getSymType(string name);
Type *isValidMemberOn(Data *, Data *);
Type *resultOfFunctionApp(Type *fxnType, Type *argType);
Type *vectorToLinkedList(vector<Type*>& typs);
bool isDefined(string name);
void inittables();
void printtables();
string escape_json(const string &s);
string print(node *n);
string print(Data *n);
void printTop(node *n);
void printTop(Data *n);
bool isValidIdent(string name);
ostream &operator<<(ostream &os, Data *m);
string toString(ClassType tp);
void prettyError(int line, int col1, int col2);
#endif
