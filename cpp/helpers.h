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
#define WARN(a, b) cout << "[WARN] " << (a) << (b) << endl
using namespace std;

extern int node_id;
extern string scope_prefix;
extern umap<string, Type *> stable;  // symbols (a is an int)
extern umap<string, Type *> ttable;  // types (due to typedef or predeclared)

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
bool isDefined(string name);
void inittables();
void printtables();
string escape_json(const string &s);
string print(node *n);
void printTop(node *n);
bool isValidIdent(string name);
ostream &operator<<(ostream &os, Data *m);
#endif
