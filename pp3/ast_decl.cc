/* File: ast_decl.cc
 * -----------------
 * Implementation of Decl node classes.
 */
#include "ast_decl.h"
#include "ast_type.h"
#include "ast_stmt.h"
#include "errors.h"

Decl::Decl(Identifier *n) : Node(*n->GetLocation()) {
    Assert(n != NULL);
    (id=n)->SetParent(this); 
}


VarDecl::VarDecl(Identifier *n, Type *t) : Decl(n) {
    Assert(n != NULL && t != NULL);
    (type=t)->SetParent(this);
}
  
ClassDecl::ClassDecl(Identifier *n, NamedType *ex, List<NamedType*> *imp, List<Decl*> *m) : Decl(n) {
    // extends can be NULL, impl & mem may be empty lists but cannot be NULL
    Assert(n != NULL && imp != NULL && m != NULL);     
    extends = ex;
    if (extends) extends->SetParent(this);
    (implements=imp)->SetParentAll(this);
    (members=m)->SetParentAll(this);
    sym_table = new Hashtable<Decl*>;
}

void ClassDecl::CheckDeclConflict() {
  if (members)
    {
      for (int i = 0; i < members->NumElements(); i++)
        {
         Decl *cur = members->Nth(i);
         Decl *prev;
         char *name = cur->getID()->getName();
         if ((prev = sym_table->Lookup(name)) != NULL)
           {
             ReportError::DeclConflict(cur, prev);
           }
         else
           {
             sym_table->Enter(name, cur);
             cur->CheckDeclConflict();
           }
        }
    }
  if (extends)
    {
      Node *parent = GetParent();
      char *name = extends->id;
      Decl *decl = parent->sym_table->Lookup(name);

    }
}

InterfaceDecl::InterfaceDecl(Identifier *n, List<Decl*> *m) : Decl(n) {
    Assert(n != NULL && m != NULL);
    (members=m)->SetParentAll(this);
    sym_table  = new Hashtable<Decl*>;
}

void InterfaceDecl::CheckDeclConflict() {
  if (members)
    {
      for (int i = 0; i < members->NumElements(); i++)
        {
         Decl *cur = members->Nth(i);
         Decl *prev;
         char *name = cur->getID()->getName();
         if ((prev = sym_table->Lookup(name)) != NULL)
           {
             ReportError::DeclConflict(cur, prev);
           }
         else
           {
             sym_table->Enter(name, cur);
           }
        }
    }
}
	

FnDecl::FnDecl(Identifier *n, Type *r, List<VarDecl*> *d) : Decl(n) {
    Assert(n != NULL && r!= NULL && d != NULL);
    (returnType=r)->SetParent(this);
    (formals=d)->SetParentAll(this);
    body = NULL;
    sym_table  = new Hashtable<Decl*>;
}

void FnDecl::CheckDeclConflict() {
 if (formals)
   {
        for (int i = 0; i < formals->NumElements(); i++)
          {
           Decl *cur = formals->Nth(i);
           Decl *prev;
           char *name = cur->getID()->getName();
           if ((prev = sym_table->Lookup(name)) != NULL)
             {
               ReportError::DeclConflict(cur, prev);
             }
           else
             {
               sym_table->Enter(name, cur);
             }
          }
   }
 if (body)
   body->CheckDeclConflict();
}

void FnDecl::SetFunctionBody(Stmt *b) { 
    (body=b)->SetParent(this);
}



