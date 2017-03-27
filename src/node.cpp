#include <vector>
#include "node.h"

node &operator<<(node &l, node *r) {
    l.children.push_back(child{0, r, ""});
    return l;
}

node &operator<<(node &l, char *r) {
    l.children.push_back(child{1, NULL, strdup(r)});
    return l;
}

node &operator>>(node &l, const char *r) {
    l.name = string(r);
    return l;
}

node &init() {
    node *n = new node();
    // n->ast = new Object("");
    return *n;
}

Data::Data(string abc) {
    name = abc;
    next = child = NULL;
}
