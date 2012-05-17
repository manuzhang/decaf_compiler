/* File: ast_decl.cc
 * -----------------
 * Implementation of Decl node classes.
 */

#include <stdio.h>
#include <string.h>

#include <iostream>
#include <typeinfo>

#include "ast_decl.h"
#include "ast_type.h"
#include "ast_stmt.h"
#include "codegen.h"
#include "errors.h"
#include "tac.h"

using std::cout;
using std::endl;

Decl::Decl(Identifier *n) : Node(*n->GetLocation()) {
  Assert(n != NULL);
  (this->id=n)->SetParent(this); 
}


VarDecl::VarDecl(Identifier *n, Type *t) : Decl(n) {
  Assert(n != NULL && t != NULL);
  (this->type=t)->SetParent(this);
}

bool VarDecl::HasSameTypeSig(VarDecl *vd) {
  if (this->type)
    return this->type->HasSameType(vd->GetType());
  else 
    return false;
}

// check NamedType errors
void VarDecl::CheckDeclError() {
  if (this->type)
    this->type->CheckTypeError();
}

Location *VarDecl::Emit() {
  FnDecl *fndecl = this->GetEnclosFunc(this);
  ClassDecl *classdecl = this->GetEnclosClass(this);
  int localOffset = 0;
  const char *name = this->GetID()->GetName();

  if (fndecl) // local variable
    {
      localOffset = fndecl->UpdateFrame();
      this->id->SetMemLoc(Program::cg->GenVar(fpRelative, localOffset, name));
    }
  // else if (classdecl)  // instance variable
  //   {
  //     int instanceOffset = classdecl->UpdateInstanceOffset();
  //     Location *instance = Program::cg->GenVar(fpRelative, instanceOffset, name);
  //     this->SetMemLoc(instance);
  //     Program::cg->GenStore(classdecl->GetMemLoc(), instance, instanceOffset);
  //   }
  else // global variable
    {
      this->id->SetMemLoc(Program::cg->GenVar(gpRelative, Program::offset, name));
      Program::offset = Program::offset + CodeGenerator::VarSize;
    }

  return NULL;
}

ClassDecl::ClassDecl(Identifier *n, NamedType *ex, List<NamedType*> *imp, List<Decl*> *m) : Decl(n) {
  // extends can be NULL, impl & mem may be empty lists but cannot be NULL
  Assert(n != NULL && imp != NULL && m != NULL);     
  this->extends = ex;
  if (this->extends) this->extends->SetParent(this);
  (this->implements=imp)->SetParentAll(this);
  (this->members=m)->SetParentAll(this);
  this->sym_table = new Hashtable<Decl*>;

  this->methodlabels = new List<const char *>;
  this->fieldlabels = new List<const char *>;
  this->instanceOffset = CodeGenerator::VarSize;
}

void ClassDecl::CheckStatements() {
  if (this->members)
    {
      for (int i = 0; i < this->members->NumElements(); i++)
	this->members->Nth(i)->CheckStatements();
    }
}

void ClassDecl::CheckDeclError() {
  // add itself to the symbol table
  this->sym_table->Enter(this->GetID()->GetName(), this);

  // check decl conflicts of its members and add the decl to symbol table if no errors
  if (this->members)
    {
      for (int i = 0; i < this->members->NumElements(); i++)
        {
	  Decl *cur = this->members->Nth(i);
	  Decl *prev;

	  const char *name = cur->GetID()->GetName();
	  if (name)
	    {
	      if ((prev = this->sym_table->Lookup(name)) != NULL)
		ReportError::DeclConflict(cur, prev);
	      else
		this->sym_table->Enter(name, cur);
	    }
        }
    }

  // turn to extends first in case methods to override those in interface may be inherited from it
  // we do not purposely check decl error of extends here
  // but leave it to the sequential work in Program::CheckDeclError
  NamedType *ex = this->extends;
  while (ex)
    {
      const char *classname = ex->GetID()->GetName();
      if (classname)
	{
	  Node *node = Program::sym_table->Lookup(classname);
	  if (node == NULL)
	    {
	      ReportError::IdentifierNotDeclared(ex->GetID(), LookingForClass);
	      break;
	    }
	  else if (typeid(*node) == typeid(ClassDecl))
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

		      const char *name = cur->GetID()->GetName();
		      if ((prev = this->sym_table->Lookup(name)) != NULL)
			{
			  if (typeid(*cur) == typeid(VarDecl) || typeid(*cur) != typeid(*prev)) // data members
			    ReportError::DeclConflict(prev, cur);
			  else if (typeid(*cur) == typeid(FnDecl) && typeid(*cur) == typeid(*prev)) // member functions
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
    }

  if (this->implements)
    {
      for (int i = 0; i < this->implements->NumElements(); i++)
	{
          NamedType *implement = this->implements->Nth(i);
	  Identifier *id = implement->GetID();
	  if (id)
	    {
	      Node *node = Program::sym_table->Lookup(id->GetName());
	      if (node == NULL || (typeid(*node) != typeid(InterfaceDecl)))
		{
		  ReportError::IdentifierNotDeclared(id, LookingForInterface);
		}
	      else if (typeid(*node) == typeid(InterfaceDecl))
		{
		  InterfaceDecl *ifd = dynamic_cast<InterfaceDecl*>(node);
		  List<Decl*> *members = ifd->GetMembers();
		  for (int j = 0; j < members->NumElements(); j++)
		    {
		      FnDecl *cur = dynamic_cast<FnDecl*>(members->Nth(j));
		      Decl *prev;
		      const char *name = cur->GetID()->GetName();
		      ;
		      if ((prev = this->sym_table->Lookup(name)) != NULL)
			{
			  if (typeid(*prev) != typeid(FnDecl))
			    ReportError::DeclConflict(cur, prev);
			  else if (!cur->HasSameTypeSig(dynamic_cast<FnDecl*>(prev)))
			    ReportError::OverrideMismatch(prev);
			}
		      else
			ReportError::InterfaceNotImplemented(this, implement);
		    }
		}
	    }
	}
    }

  // look into local scopes
  // again we do not go into the scope of extended classes or implemented interfaces
  if (this->members)
    {
      for (int i = 0; i < this->members->NumElements(); i++)
	this->members->Nth(i)->CheckDeclError();
    }
}

// A and B are not of the same class type
// A->IsCompatible(B)
// A is compatible with B if A is a B
bool ClassDecl::IsCompatibleWith(Decl *decl)
{
  NamedType *extends = this->GetExtends();
  List<NamedType*> *implements = this->GetImplements();

  if (typeid(*decl) == typeid(ClassDecl))
    {
      ClassDecl *cldecl = dynamic_cast<ClassDecl*>(decl);
      // is B a base class of A
      if (extends)
        {
          const char *name = extends->GetTypeName();
          if (!strcmp(cldecl->GetID()->GetName(), name))
	    return true;
          else
	    {
	      if (name)
		{
		  Decl *exdecl = Program::sym_table->Lookup(name);
		  if (exdecl && typeid(*exdecl) == typeid(ClassDecl))
		    return dynamic_cast<ClassDecl*>(exdecl)->IsCompatibleWith(decl);
		}
	    }
        }
    }
  // is B an interface of A
  else if (typeid(*decl) == typeid(InterfaceDecl))
    {
      InterfaceDecl *itfdecl = dynamic_cast<InterfaceDecl*>(decl);

      if (implements)
	{
	  for (int i = 0; i < implements->NumElements(); i++)
	    {
	      NamedType *implement = implements->Nth(i);
	      if (implement && !strcmp(itfdecl->GetID()->GetName(), implement->GetTypeName()))
		return true;
		  
	    }
	}
      if (extends)
        {
          const char *name = extends->GetTypeName();
          if (name)
            {
              Decl *exdecl = Program::sym_table->Lookup(name);
              if (exdecl && typeid(*exdecl) == typeid(ClassDecl))
                return dynamic_cast<ClassDecl*>(exdecl)->IsCompatibleWith(decl);
            }
        }
    }

  return false;
}

void ClassDecl::SetLabels() {
  if (this->sym_table)
      {
        Iterator<Decl*> iter = this->sym_table->GetIterator();
        Decl *decl;

        while ((decl = iter.GetNextValue()) != NULL)
          {
            if (typeid(*decl) == typeid(FnDecl))
              {
                ClassDecl *classdecl = decl->GetEnclosClass(decl);
                string name = Program::GetClassLabel(classdecl->GetID()->GetName(), decl->GetID()->GetName());
                this->methodlabels->Append(strdup(name.c_str()));
              }
            else if (typeid(*decl) == typeid(VarDecl))
              this->fieldlabels->Append(decl->GetID()->GetName());
         }


      }
}

Location *ClassDecl::Emit() {
  if (this->members)
      {
        for (int i = 0; i < this->members->NumElements(); i++)
          this->members->Nth(i)->SetLabels();

        for (int i = 0; i < this->members->NumElements(); i++)
          this->members->Nth(i)->Emit();
      }

  Program::cg->GenVTable(this->id->GetName(), this->methodlabels);

  return NULL;
}

int ClassDecl::UpdateInstanceOffset() {
  int offset = this->instanceOffset;
  this->instanceOffset += CodeGenerator::VarSize;
  return offset;
}

InterfaceDecl::InterfaceDecl(Identifier *n, List<Decl*> *m) : Decl(n) {
  Assert(n != NULL && m != NULL);
  (this->members=m)->SetParentAll(this);
  this->sym_table  = new Hashtable<Decl*>;
}


void InterfaceDecl::CheckDeclError() {
  if (this->members)
    {
      for (int i = 0; i < this->members->NumElements(); i++)
	{
	  Decl *cur = members->Nth(i);
	  Decl *prev;
	  const char *name = cur->GetID()->GetName();
	  if (name)
	    {
	      if ((prev = this->sym_table->Lookup(name)) != NULL)
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
}
	

FnDecl::FnDecl(Identifier *n, Type *r, List<VarDecl*> *d) : Decl(n) {
  Assert(n != NULL && r!= NULL && d != NULL);
  (this->returnType=r)->SetParent(this);
  (this->formals=d)->SetParentAll(this);
  this->body = NULL;
  this->sym_table  = new Hashtable<Decl*>;

  this->beginFunc = NULL;
  this->frameSize = 0;
  this->localOffset = CodeGenerator::OffsetToFirstLocal;
  this->paramOffset = CodeGenerator::OffsetToFirstParam;
}

// return type, number of formals need be matched
// all the formals must be matched in order
bool FnDecl::HasSameTypeSig(FnDecl *fd) {
  if (!strcmp(this->id->GetName(), fd->GetID()->GetName()))
    if (this->returnType->HasSameType(fd->GetType()))
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

void FnDecl::CheckStatements() {
  if (this->body)
    this->body->CheckStatements();
}

void FnDecl::CheckDeclError() {
  if (this->formals)
    {
      for (int i = 0; i < this->formals->NumElements(); i++)
	{
	  VarDecl *cur = this->formals->Nth(i);
	  Decl *prev;
	  const char *name = cur->GetID()->GetName();
	  if (name)
	    {
	      if ((prev = this->sym_table->Lookup(name)) != NULL)
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
    }
  if (this->body)
    this->body->CheckDeclError();
}

Location *FnDecl::Emit() {
  const char *name = this->GetID()->GetName();
  ClassDecl *classdecl = this->GetEnclosClass(this);

  if (!strcmp(name, "main") && classdecl == NULL)
    Program::cg->GenLabel("main");
  else
    {
      Program::cg->GenLabel((this->label).c_str());
    }

  this->beginFunc = Program::cg->GenBeginFunc();

  // assign locations for params
  if (this->formals)
    {
      List<VarDecl*> *newformals = new List<VarDecl*>;
      if (classdecl)
	{
	  VarDecl *this_var = new VarDecl(new Identifier(*this->GetLocation(), "this"), Type::nullType);
	  this_var->GetID()->SetMemLoc(Program::cg->GenVar(fpRelative, this->paramOffset, "this"));
	  this->paramOffset += CodeGenerator::VarSize;
	  newformals->Append(this_var);
	}
      for (int i = 0; i < this->formals->NumElements(); i++)
	{
	  VarDecl *vardecl = this->formals->Nth(i);
	  vardecl->GetID()->SetMemLoc(Program::cg->GenVar(fpRelative, this->paramOffset, vardecl->GetID()->GetName()));
	  this->paramOffset += CodeGenerator::VarSize;
	  newformals->Append(vardecl);
	}
      if (classdecl)
	{
          this->formals = newformals;
          this->formals->SetParentAll(this);
	}
      else
	delete newformals;
    }

  if (this->body)
    this->body->Emit();

  this->beginFunc->SetFrameSize(this->GetFrameSize());

  Program::cg->GenEndFunc();

  return NULL;
}

void FnDecl::SetFunctionBody(StmtBlock *b) {
  (this->body=b)->SetParent(this);
}

int FnDecl::UpdateFrame() {
  this->frameSize += CodeGenerator::VarSize;
  int offset = this->localOffset;
  this->localOffset -= CodeGenerator::VarSize;

  return offset;
}


void FnDecl::SetLabels() {
  ClassDecl *classdecl = this->GetEnclosClass(this);
  const char *name = this->GetID()->GetName();
  if (strcmp(name, "main") || classdecl)
    {
      string label;

      if (classdecl)
        label = Program::GetClassLabel(classdecl->GetID()->GetName(), name);
      else
        label = Program::GetFuncLabel(name);

      this->label = label;
    }
}
