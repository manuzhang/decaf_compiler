/* File: ast.cc
 * ------------
 */

#include <stdio.h>  // printf
#include <string.h> // strdup
#include <typeinfo>
#include "ast.h"
#include "ast_decl.h"
#include "ast_stmt.h"
#include "ast_type.h"
#include "errors.h"

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

// look for declaration from inner most scope to global scope
Decl *Identifier::CheckIdDecl(reasonT whyNeeded) {
   Decl *decl = NULL;
   Node *parent = this->GetParent();
   while (parent)
     {
       Hashtable<Decl*> *sym_table = parent->GetSymTable();
       if (sym_table != NULL)
         {
           if ((decl = sym_table->Lookup(this->name)) != NULL)
             return decl;
         }
       parent = parent->GetParent();
     }

   if ((decl = Program::sym_table->Lookup(this->name)) == NULL)
     ReportError::IdentifierNotDeclared(this, whyNeeded);

   return decl;
}

// look for declaration in the provided scope
Decl *Identifier::CheckIdDecl(Hashtable<Decl*> *sym_table, char *name)
{
  Decl *decl = NULL;
  if (sym_table != NULL)
    decl = sym_table->Lookup(name);
  return decl;
}
