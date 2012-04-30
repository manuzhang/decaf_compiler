/* File: ast.cc
 * ------------
 */

#include <stdio.h>  // printf
#include <string.h> // strdup

#include "ast.h"
#include "ast_decl.h"
#include "ast_type.h"

Node::Node(yyltype loc) {
    location = new yyltype(loc);
    parent = NULL;
}

Node::Node() {
    location = NULL;
    parent = NULL;
}
	 
Identifier::Identifier(yyltype loc, const char *n) : Node(loc) {
    name = strdup(n);
}
