#ifndef _PLACE_H
#define _PLACE_H

#include "type.h"

/* Used to store location of variable in 3AC */
class Place {
private:
    /* How many variables have been assigned till now */
    static int _id;

    /* Take type and return keyword for this type */
    string nameFromSize(Type *type);

public:
    string name;                /* To show while printing */
    Type *type;                 /* Needed to allocate space */

    Place(Type *_type);
    Place(Type *_type, string _name);
};

#endif
