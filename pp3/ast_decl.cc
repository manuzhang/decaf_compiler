/* File: ast_decl.cc
 * -----------------
 * Implementation of Decl node classes.
 */

#include <stdio.h>
#include <string.h>

#include <typeinfo>

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

bool VarDecl::HasSameTypeSig(VarDecl *vd) {
  return this->type->HasSameType(vd->GetType());
}

void VarDecl::CheckSemantics() {
  // do nothing here
}

// check NamedType errors
void VarDecl::CheckDeclError() {
  this->type->CheckTypeError();
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

void ClassDecl::CheckSemantics() {
  if (this->members)
     {
       for (int i = 0; i < this->members->NumElements(); i++)
         this->members->Nth(i)->CheckSemantics();
     }
}

void ClassDecl::CheckDeclError() {
  if (this->members)
    {
      for (int i = 0; i < this->members->NumElements(); i++)
        {
	  Decl *cur = this->members->Nth(i);
	  Decl *prev;
	  char *name = cur->GetID()->GetName();
	  if ((prev = sym_table->Lookup(name)) != NULL)
	    ReportError::DeclConflict(cur, prev);
	  else
            sym_table->Enter(name, cur);
        }
    }


  NamedType *ex = this->extends;
  while (ex)
    {
      char *name = ex->GetID()->GetName();
      Node *node = Program::sym_table->Lookup(name);
      if (node == NULL)
        {
          ReportError::IdentifierNotDeclared(ex->GetID(), LookingForClass);
          break;
        }
      else
        {
          ClassDecl *base = dynamic_cast<ClassDecl*>(node);
          List<Decl*> *base_members = base->members;
          List<Decl*> *inherited = new List<Decl*>;
          // check the declaration of base class against derived class symbol table
          if (base_members)
            {
              for (int i = 0; i < base_members->NumElements(); i++)
                {
                  Decl *cur = base_members->Nth(i);
                  Decl *prev;
                  char *name = cur->GetID()->GetName();
                  if ((prev = this->sym_table->Lookup(name)) != NULL)
                    {
                      if (typeid(*cur) == typeid(VarDecl) || typeid(*cur) != typeid(*prev))
                        ReportError::DeclConflict(prev, cur);
                      else if (typeid(*cur) == typeid(FnDecl) && typeid(*cur) == typeid(*prev))
                        {
                          FnDecl *fdcur = dynamic_cast<FnDecl*>(cur);
                          FnDecl *fdprev = dynamic_cast<FnDecl*>(prev);
                          if (!fdcur->HasSameTypeSig(fdprev))
                            ReportError::OverrideMismatch(fdprev);
                        }
                    }
                  else // methods that override implemented methods may come from base class
                       // but we cannot add it to symbol table here
                       // otherwise we may have an undesirable overridemismatch error
                    {
                      inherited->Append(cur);
                    }
                }
              for (int i = 0; i < inherited->NumElements(); i++)
		{
                  Decl *decl = inherited->Nth(i);
                  this->sym_table->Enter(decl->GetID()->GetName(), decl);
		}
            }
          ex = base->GetExtends();
        }
    }

  if (this->implements)
    {
      for (int i = 0; i < this->implements->NumElements(); i++)
	{
	  Identifier *id = this->implements->Nth(i)->GetID();
	  Node *node = Program::sym_table->Lookup(id->GetName());
	  if (node == NULL)
	    {
	      ReportError::IdentifierNotDeclared(id, LookingForInterface);
	    }
	  else
	    {
	      InterfaceDecl *ifd = dynamic_cast<InterfaceDecl*>(node);
	      List<Decl*> *members = ifd->GetMembers();
	      for (int j = 0; j < members->NumElements(); j++)
		{
		  FnDecl *cur = dynamic_cast<FnDecl*>(members->Nth(i));
		  Decl *prev;
		  char *name = cur->GetID()->GetName();
		  if ((prev = sym_table->Lookup(name)) != NULL)
		    {
		      if (typeid(*prev) != typeid(FnDecl))
			ReportError::DeclConflict(cur, prev);
		      else if (!cur->HasSameTypeSig(dynamic_cast<FnDecl*>(prev)))
			ReportError::OverrideMismatch(prev);
		    }
		  else
		    ReportError::InterfaceNotImplemented(this, new NamedType(ifd->GetID()));
		}
	    }
	}
    }

  // look into local scopes
  if (this->members)
      {
        for (int i = 0; i < this->members->NumElements(); i++)
          this->members->Nth(i)->CheckDeclError();
      }
}

InterfaceDecl::InterfaceDecl(Identifier *n, List<Decl*> *m) : Decl(n) {
  Assert(n != NULL && m != NULL);
  (members=m)->SetParentAll(this);
  sym_table  = new Hashtable<Decl*>;
}

void InterfaceDecl::CheckSemantics() {
 // do nothing here
}

void InterfaceDecl::CheckDeclError() {
  if (members)
    {
      for (int i = 0; i < members->NumElements(); i++)
	{
	  Decl *cur = members->Nth(i);
	  Decl *prev;
	  char *name = cur->GetID()->GetName();
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

bool FnDecl::HasSameTypeSig(FnDecl *fd) {
  if (!strcmp(id->GetName(), fd->GetID()->GetName()))
    if (returnType->HasSameType(fd->GetReturnType()))
      {
	List<VarDecl*> *f1 = formals;
	List<VarDecl*> *f2 = fd->GetFormals();

	if (f1 && f2)
	  if (f1->NumElements() == f2->NumElements())
	    {
	      for (int i = 0; i < f1->NumElements(); i++)
		{
		  VarDecl *vd1 = f1->Nth(i);
		  VarDecl *vd2 = f2->Nth(i);
		  if (!vd1->HasSameTypeSig(vd2))
		    return false;
		}
	      return true;
	    }
      }

  return false;

}

void FnDecl::CheckSemantics() {
  if (body)
    body->CheckSemantics();
}

void FnDecl::CheckDeclError() {
  if (formals)
    {
      for (int i = 0; i < formals->NumElements(); i++)
	{
	  VarDecl *cur = formals->Nth(i);
	  Decl *prev;
	  char *name = cur->GetID()->GetName();
	  if ((prev = sym_table->Lookup(name)) != NULL)
	    {
	      ReportError::DeclConflict(cur, prev);
	    }
	  else
	    {
	      sym_table->Enter(name, cur);
	      cur->CheckDeclError();
	    }
	}
    }
  if (body)
    body->CheckDeclError();
}

void FnDecl::SetFunctionBody(StmtBlock *b) {
  (body=b)->SetParent(this);
}
