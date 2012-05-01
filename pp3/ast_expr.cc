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
  const char *lt, *rt;
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
    if (strcmp(lt, rt))
      ReportError::IncompatibleOperands(this->op, new Type(lt), new Type(rt));
  // to be implemented:
  // two objects or an object and null
}

void LogicalExpr::CheckStatements() {
  const char *lt, *rt;
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
          else if (typeid(*ldecl) == typeid(ClassDecl) && typeid(*rdecl) == typeid(ClassDecl))
            {
              ClassDecl *lcldecl = dynamic_cast<ClassDecl*>(ldecl);
              ClassDecl *rcldecl = dynamic_cast<ClassDecl*>(rdecl);
              NamedType *extends = rcldecl->GetExtends();
              if (extends && !strcmp(lcldecl->GetID()->GetName(), extends->GetTypeName()))
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
        return;
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
  Decl *decl; // to keep the result from looking up the symbol table
  if (this->base && typeid(*this->base) == typeid(FieldAccess))
    {
      Identifier *id = dynamic_cast<FieldAccess*>(this->base)->GetField();
      Decl *id_decl = id->CheckIdDecl();
      // check whether the field is a data member of base
      if (id_decl != NULL)
          {
            // class name
            const char *name = id_decl->GetTypeName();
            if ((decl = Program::sym_table->Lookup(name)) != NULL) // fetch base symbol table
              {
                if ((decl = this->field->CheckIdDecl(decl->GetSymTable(), this->field->GetName())) == NULL)
                  ReportError::FieldNotFoundInBase(this->field, new Type(id_decl->GetTypeName()));
              }
          }
      else
        ReportError::IdentifierNotDeclared(id, LookingForClass);
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
  Decl *decl; // to keep the result from looking up the symbol table
  if (this->base && typeid(*this->base) == typeid(FieldAccess))
    {
      // check whether base is declared
      Identifier *id = dynamic_cast<FieldAccess*>(this->base)->GetField();
      // actually, it's LookingForClass or LookingForInterface
      // to be fixed
      Decl *id_decl = id->CheckIdDecl();

      // check whether the field is a member function of base
      if (id_decl != NULL)
        {
             // class name
            const char *name = id_decl->GetTypeName();
            if ((decl = Program::sym_table->Lookup(name)) != NULL) // fetch base symbol table
              {
                if ((decl = this->field->CheckIdDecl(decl->GetSymTable(), this->field->GetName())) == NULL)
                  ReportError::FieldNotFoundInBase(this->field, new Type(id_decl->GetTypeName()));
              }
        }
      else
        ReportError::IdentifierNotDeclared(id, LookingForClass);
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

  if (actuals)
    {
      for (int i = 0; i < actuals->NumElements(); i++)
        actuals->Nth(i)->CheckStatements();
    }
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
