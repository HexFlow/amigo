#include <vector>
#include "node.h"

node &operator<<(node &l, node *r) {
    l.children_nt.push_back(r);
    return l;
}

node &operator<<(node &l, char *r) {
    l.children_t.push_back(strdup(r));
    return l;
}

node &operator>>(node &l, const char *r) {
    l.name = string(r);
    return l;
}

node &init() {
    node *n = new node();
    n->ast = new Object("");
    return *n;
}
