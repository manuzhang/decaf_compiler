/* File: ast_expr.cc
 * -----------------
 * Implementation of expression node classes.
 */

#include <string.h>

#include <typeinfo>

#include "ast_expr.h"
#include "ast_type.h"
#include "ast_decl.h"
#include "errors.h"

IntConstant::IntConstant(yyltype loc, int val) : Expr(loc) {
  value = val;
}

DoubleConstant::DoubleConstant(yyltype loc, double val) : Expr(loc) {
  value = val;
}

BoolConstant::BoolConstant(yyltype loc, bool val) : Expr(loc) {
  value = val;
}

StringConstant::StringConstant(yyltype loc, const char *val) : Expr(loc) {
  Assert(val != NULL);
  value = strdup(val);
}

Operator::Operator(yyltype loc, const char *tok) : Node(loc) {
  Assert(tok != NULL);
  strncpy(tokenString, tok, sizeof(tokenString));
}


CompoundExpr::CompoundExpr(Expr *l, Operator *o, Expr *r) 
  : Expr(Join(l->GetLocation(), r->GetLocation())) {
  Assert(l != NULL && o != NULL && r != NULL);
  (op=o)->SetParent(this);
  (left=l)->SetParent(this); 
  (right=r)->SetParent(this);
}

CompoundExpr::CompoundExpr(Operator *o, Expr *r) 
  : Expr(Join(o->GetLocation(), r->GetLocation())) {
  Assert(o != NULL && r != NULL);
  left = NULL; 
  (op=o)->SetParent(this);
  (right=r)->SetParent(this);
}
  
void ArithmeticExpr::CheckStatements() {
  const char *lt = NULL, *rt = NULL;
  if (this->left) // binary
    {
      this->left->CheckStatements();
      lt = this->left->GetTypeName();
    }

  this->right->CheckStatements();
  rt = this->right->GetTypeName();
  if (lt && rt) // binary
    {
      if ((strcmp(lt, "int") && strcmp(lt, "double")) ||
          (strcmp(rt, "int") && strcmp(rt, "double")) ||
          (strcmp(lt, rt)))
        ReportError::IncompatibleOperands(this->op, new Type(lt), new Type(rt));
    }
  else if (rt) // unary
    {
      if (strcmp(rt, "int") && strcmp(rt, "double"))
        ReportError::IncompatibleOperand(this->op, new Type(rt));
    }
}

void RelationalExpr::CheckStatements() {
  this->left->CheckStatements();
  const char *lt = this->left->GetTypeName();

  this->right->CheckStatements();
  const char *rt = this->right->GetTypeName();
  if (lt && rt) // binary
    {
      if ((strcmp(lt, "int") && strcmp(lt, "double")) ||
	  (strcmp(rt, "int") && strcmp(rt, "double")) ||
	  (strcmp(lt, rt)))
	ReportError::IncompatibleOperands(this->op, new Type(lt), new Type(rt));
    }
}

void EqualityExpr::CheckStatements() {
  this->left->CheckStatements();
  this->right->CheckStatements();
  const char *lt = this->left->GetTypeName();
  const char *rt = this->right->GetTypeName();
  if (lt && rt)
    {
      Decl *ldecl = Program::sym_table->Lookup(lt);
      Decl *rdecl = Program::sym_table->Lookup(rt);

      if (ldecl && rdecl) // objects
       {
         if (!strcmp(lt, rt))
           return;
         else if (typeid(*ldecl) == typeid(ClassDecl))
           {
             ClassDecl *lcldecl = dynamic_cast<ClassDecl*>(ldecl);
             if (lcldecl->IsCompatibleWith(rdecl))
               return;
           }
         else if (typeid(*rdecl) == typeid(ClassDecl))
           {
             ClassDecl *rcldecl = dynamic_cast<ClassDecl*>(rdecl);
             if (rcldecl->IsCompatibleWith(ldecl))
               return;
           }
       }
      else if (ldecl && !strcmp(rt, "null")) // object = null
         return;
      else if (!strcmp(lt, rt)) // non-objects
         return;
    }
    ReportError::IncompatibleOperands(this->op, new Type(lt), new Type(rt));
}

void LogicalExpr::CheckStatements() {
  const char *lt = NULL, *rt = NULL;
  if (this->left)
    {
      this->left->CheckStatements();
      lt = this->left->GetTypeName();
    }
  this->right->CheckStatements();
  rt = this->right->GetTypeName();
  if (lt && rt)
    {
      if (strcmp(lt, "bool") || strcmp(rt, "bool"))
        ReportError::IncompatibleOperands(this->op, new Type(lt), new Type(rt));
    }
  else if (rt)
    {
      if (strcmp(rt, "bool"))
        ReportError::IncompatibleOperand(this->op, new Type(rt));
    }

}

void AssignExpr::CheckStatements() {
  this->left->CheckStatements();
  this->right->CheckStatements();
  const char *lt = this->left->GetTypeName();
  const char *rt = this->right->GetTypeName();

  if (lt && rt)
    {
      Decl *ldecl = Program::sym_table->Lookup(lt);
      Decl *rdecl = Program::sym_table->Lookup(rt);

      if (ldecl && rdecl) // objects
        {
          if (!strcmp(lt, rt))
            return;
          else if (typeid(*rdecl) == typeid(ClassDecl))
             {
                ClassDecl *rcldecl = dynamic_cast<ClassDecl*>(rdecl);
                if (rcldecl->IsCompatibleWith(ldecl))
                  return;
             }
        }
      else if (ldecl && !strcmp(rt, "null")) // object = null
	return;
      else if (!strcmp(lt, rt)) // non-objects
	return;
      ReportError::IncompatibleOperands(this->op, new Type(lt), new Type(rt));
    }
}

void This::CheckStatements() {
  Node *parent = this->GetParent();
  while (parent)
    {
      if (typeid(*parent) == typeid(ClassDecl))
        {
          this->typeName = dynamic_cast<ClassDecl*>(parent)->GetID()->GetName();
          return;
        }
      parent = parent->GetParent();
    }
  ReportError::ThisOutsideClassScope(this);
}

ArrayAccess::ArrayAccess(yyltype loc, Expr *b, Expr *s) : LValue(loc) {
  (base=b)->SetParent(this); 
  (subscript=s)->SetParent(this);
}

void ArrayAccess::CheckStatements() {
  this->base->CheckStatements();
  if (strstr(this->base->GetTypeName(), "[]") == NULL)
    ReportError::BracketsOnNonArray(this->base);
  this->subscript->CheckStatements();
  if (strcmp(this->subscript->GetTypeName(), "int"))
    ReportError::SubscriptNotInteger(this->subscript);
}

FieldAccess::FieldAccess(Expr *b, Identifier *f) 
  : LValue(b? Join(b->GetLocation(), f->GetLocation()) : *f->GetLocation()) {
  Assert(f != NULL); // b can be be NULL (just means no explicit base)
  base = b; 
  if (base) base->SetParent(this); 
  (field=f)->SetParent(this);
}

void FieldAccess::CheckStatements() {
  Decl *decl = NULL; // to keep the result from looking up the symbol table
  if (this->base)
    {
      this->base->CheckStatements();
      const char *name = this->base->GetTypeName();

      if (name)
	{
	  Node *parent = this->GetParent();
	  Decl *cldecl = NULL; // look for ClassDecl 
	  while (parent)
	    {
	      Hashtable<Decl*> *sym_table = parent->GetSymTable();
	      if (sym_table)
		if ((cldecl = sym_table->Lookup(name)) != NULL)
		  {
                    if ((decl = this->field->CheckIdDecl(cldecl->GetSymTable(), this->field->GetName())) == NULL)
       	              ReportError::FieldNotFoundInBase(this->field, new Type(name));

		  }
	      parent = parent->GetParent();
	    }
	  if (cldecl == NULL)
	    {
	      if ((cldecl = Program::sym_table->Lookup(name)) != NULL)
	        {
	          if ((decl = this->field->CheckIdDecl(cldecl->GetSymTable(), this->field->GetName())) != NULL)
	            ReportError::InaccessibleField(this->field, new Type(name));
	        }
	      else // for those with no symbol table, e.g. int[]
	          ReportError::FieldNotFoundInBase(this->field, new Type(name));
	    }
	}
    }
  else
    {
      // no base, just check whether the field is declared
      decl = this->field->CheckIdDecl();
      if (decl == NULL)
        ReportError::IdentifierNotDeclared(this->field, LookingForVariable);
    }
  if (decl != NULL)
    this->type = decl->GetType(); 
}

Call::Call(yyltype loc, Expr *b, Identifier *f, List<Expr*> *a) : Expr(loc)  {
  Assert(f != NULL && a != NULL); // b can be be NULL (just means no explicit base)
  base = b;
  if (base) base->SetParent(this);
  (field=f)->SetParent(this);
  (actuals=a)->SetParentAll(this);
}

void Call::CheckStatements() {
  if (actuals)
    {
      for (int i = 0; i < actuals->NumElements(); i++)
        actuals->Nth(i)->CheckStatements();
    }

  Decl *decl = NULL;

  if (this->base)
    {
      this->base->CheckStatements();
      const char *name = this->base->GetTypeName();
      if (name && (decl = Program::sym_table->Lookup(name)) != NULL)
	{
	  if ((decl = this->field->CheckIdDecl(decl->GetSymTable(), this->field->GetName())) == NULL)
	    ReportError::FieldNotFoundInBase(this->field, new Type(name));
	}
    }
  else
    {
      // no base, just check whether the field is declared
      decl = this->field->CheckIdDecl();
      if (decl == NULL)
        ReportError::IdentifierNotDeclared(this->field, LookingForFunction);
    }
  if (decl != NULL)
    this->type = decl->GetType(); // returnType


}

NewExpr::NewExpr(yyltype loc, NamedType *c) : Expr(loc) { 
  Assert(c != NULL);
  (cType=c)->SetParent(this);
}

NewArrayExpr::NewArrayExpr(yyltype loc, Expr *sz, Type *et) : Expr(loc) {
  Assert(sz != NULL && et != NULL);
  (size=sz)->SetParent(this); 
  (elemType=et)->SetParent(this);
}

void NewArrayExpr::CheckStatements() {
  this->size->CheckStatements();
  if (strcmp(this->size->GetTypeName(), "int"))
    ReportError::NewArraySizeNotInteger(this->size);
  this->elemType->CheckStatements();
}

PostfixExpr::PostfixExpr(yyltype loc, LValue *lv, Operator *op)
  : Expr(loc) {
  Assert(lv != NULL && op != NULL);
  (lvalue=lv)->SetParent(this);
  (optr=op)->SetParent(this);
}
