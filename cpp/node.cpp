#include <vector>
#include "node.h"

node &operator<<(node &l, node *r) {
    l.children.push_back(child{0, r, ""});
    return l;
}

node &operator<<(node &l, char *r) {
    l.children.push_back(child{1, 0, strdup(r)});
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
