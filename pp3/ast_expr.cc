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
  
void ArithmeticExpr::CheckSemantics() {

  CheckOperandsCompatibility();
}

void ArithmeticExpr::CheckOperandsCompatibility() {

}

ArrayAccess::ArrayAccess(yyltype loc, Expr *b, Expr *s) : LValue(loc) {
    (base=b)->SetParent(this); 
    (subscript=s)->SetParent(this);
}

FieldAccess::FieldAccess(Expr *b, Identifier *f) 
  : LValue(b? Join(b->GetLocation(), f->GetLocation()) : *f->GetLocation()) {
    Assert(f != NULL); // b can be be NULL (just means no explicit base)
    base = b; 
    if (base) base->SetParent(this); 
    (field=f)->SetParent(this);
}

void FieldAccess::CheckSemantics() {
  field->CheckIdDecl(LookingForVariable);
}

Call::Call(yyltype loc, Expr *b, Identifier *f, List<Expr*> *a) : Expr(loc)  {
    Assert(f != NULL && a != NULL); // b can be be NULL (just means no explicit base)
    base = b;
    if (base) base->SetParent(this);
    (field=f)->SetParent(this);
    (actuals=a)->SetParentAll(this);
}

void Call::CheckSemantics() {
  if (base && typeid(*base) == typeid(FieldAccess))
    {
      // check whether base is declared
      Identifier *id = dynamic_cast<FieldAccess*>(base)->GetField();
      Decl *id_decl = id->CheckIdDecl(LookingForClass);

      // check whether the field is a member function of base
      if (id_decl != NULL)
        if (typeid(*id_decl) == typeid(VarDecl))
           {
            char *name = dynamic_cast<VarDecl*>(id_decl)->GetType()->GetTypeName();
            Decl *decl;
            if ((decl = Program::sym_table->Lookup(name)) != NULL) // fetch base symbol table
              {
                if (typeid(*decl) == typeid(ClassDecl))
                  this->field->CheckIdDecl(dynamic_cast<ClassDecl*>(decl)->GetSymTable(),
                                           this->field->GetName(),
                                            LookingForFunction);
              }
            else
                  ReportError::FieldNotFoundInBase(this->field, new NamedType(id));
           }
    }
  else
    {
      // no base, just check whether the field is declared
      this->field->CheckIdDecl(LookingForFunction);
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

PostfixExpr::PostfixExpr(yyltype loc, LValue *lv, Operator *op)
: Expr(loc) {
    Assert(lv != NULL && op != NULL);
    (lvalue=lv)->SetParent(this);
    (optr=op)->SetParent(this);
}
