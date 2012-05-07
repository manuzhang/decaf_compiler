/* File: ast_expr.cc
 * -----------------
 * Implementation of expression node classes.
 */

#include <string.h>

#include <typeinfo>

#include "ast_expr.h"
#include "ast_type.h"
#include "ast_decl.h"
#include "codegen.h"
#include "errors.h"
#include "tac.h"

IntConstant::IntConstant(yyltype loc, int val)
  : Expr(loc) {
  this->value = val;
  Expr::type = Type::intType;
}

Location *IntConstant::Emit() {
  return Program::cg->GenLoadConstant(this->value);
}

DoubleConstant::DoubleConstant(yyltype loc, double val)
  : Expr(loc) {
  this->value = val;
  Expr::type = Type::doubleType;
}

BoolConstant::BoolConstant(yyltype loc, bool val)
  : Expr(loc) {
  this->value = val;
  Expr::type = Type::boolType;
}

Location *BoolConstant::Emit() {
  return Program::cg->GenLoadConstant(static_cast<int>(this->value));
}

StringConstant::StringConstant(yyltype loc, const char *val)
  : Expr(loc) {
  Assert(val != NULL);
  this->value = strdup(val);
  Expr::type = Type::stringType;
}

Location *StringConstant::Emit() {
  return Program::cg->GenLoadConstant(this->value);
}

NullConstant::NullConstant(yyltype loc)
  : Expr(loc) {
  Expr::type = Type::nullType;
}

Operator::Operator(yyltype loc, const char *tok) : Node(loc) {
  Assert(tok != NULL);
  strncpy(this->tokenString, tok, sizeof(this->tokenString));
}

void Operator::SetToken(const char *tok) {
  Assert(tok != NULL);
  strncpy(this->tokenString, tok, sizeof(this->tokenString));
}

CompoundExpr::CompoundExpr(Expr *l, Operator *o, Expr *r) 
  : Expr(Join(l->GetLocation(), r->GetLocation())) {
  Assert(l != NULL && o != NULL && r != NULL);
  (this->op=o)->SetParent(this);
  (this->left=l)->SetParent(this); 
  (this->right=r)->SetParent(this);
}

CompoundExpr::CompoundExpr(Operator *o, Expr *r) 
  : Expr(Join(o->GetLocation(), r->GetLocation())) {
  Assert(o != NULL && r != NULL);
  this->left = NULL; 
  (this->op=o)->SetParent(this);
  (this->right=r)->SetParent(this);
}
  
void CompoundExpr::SwapOperands() {
  Expr *tmp;
  tmp = this->right;
  this->right = this->left;
  this->left = tmp;
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

Location *ArithmeticExpr::Emit() {
  if (this->left && this->right)
    {
      return Program::cg->GenBinaryOp(this->GetOp()->GetToken(), this->left->Emit(), this->right->Emit());
    }

  return NULL;
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

Location *RelationalExpr::Emit() {
  if (this->left && this->right)
    {
      if (!strcmp(this->GetOp()->GetToken(), ">"))
       {
         SwapOperands();
         this->GetOp()->SetToken("<");
       }
      return Program::cg->GenBinaryOp(this->GetOp()->GetToken(), this->left->Emit(), this->right->Emit());
    }

  return NULL;
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


Location *EqualityExpr::Emit() {
  if (this->left && this->right)
    {
       if (!strcmp(this->GetOp()->GetToken(), "!="))
         {
           Expr *prevLeft = this->left;
           Expr *prevRight = this->right;
           // the location is not correct, but semantic check has been done upto this step
           this->left = new RelationalExpr(prevLeft, new Operator(*this->GetLocation(), "<"), prevRight);
           this->left->SetParent(this);
           this->right = new RelationalExpr(prevLeft, new Operator(*this->GetLocation(), ">"), prevRight);
           this->right->SetParent(this);
           this->op->SetToken("||");
           this->op->SetParent(this);
         }

       return Program::cg->GenBinaryOp(this->GetOp()->GetToken(), this->left->Emit(), this->right->Emit());
    }

  return NULL;

}

Location *LogicalExpr::Emit() {
  if (this->left && this->right)
     {
       return Program::cg->GenBinaryOp(this->GetOp()->GetToken(), this->left->Emit(), this->right->Emit());
     }

   return NULL;
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

Location *AssignExpr::Emit() {
  if (this->left && this->right)
    {
      Program::cg->GenAssign(this->left->Emit(), this->right->Emit());
    }

  return NULL;
}

void This::CheckStatements() {
  Node *parent = this->GetParent();
  while (parent)
    {
      if (typeid(*parent) == typeid(ClassDecl))
        {
          this->type = new NamedType(dynamic_cast<ClassDecl*>(parent)->GetID());
          return;
        }
      parent = parent->GetParent();
    }
  ReportError::ThisOutsideClassScope(this);
}

ArrayAccess::ArrayAccess(yyltype loc, Expr *b, Expr *s) : LValue(loc) {
  (this->base=b)->SetParent(this); 
  (this->subscript=s)->SetParent(this);
}

Type *ArrayAccess::GetType() {
  Type *type = base->GetType();
  if (type)
    return type->GetElemType();
  else
    return NULL;
}

const char *ArrayAccess::GetTypeName() {
  Type *type = this->base->GetType();
  if (type)
    return type->GetElemType()->GetTypeName();
  else
    return NULL;
}

void ArrayAccess::CheckStatements() {
  this->base->CheckStatements();
  if (typeid(*this->base->GetType()) != typeid(ArrayType))
    ReportError::BracketsOnNonArray(this->base);
  this->subscript->CheckStatements();
  if (strcmp(this->subscript->GetTypeName(), "int"))
    ReportError::SubscriptNotInteger(this->subscript);
}

FieldAccess::FieldAccess(Expr *b, Identifier *f) 
  : LValue(b? Join(b->GetLocation(), f->GetLocation()) : *f->GetLocation()) {
  Assert(f != NULL); // b can be be NULL (just means no explicit base)
  this->base = b; 
  if (this->base) base->SetParent(this); 
  (this->field=f)->SetParent(this);
}

void FieldAccess::CheckStatements() {
  Decl *decl = NULL; // to keep the result of looking up the symbol table
  if (this->base)
    {
      this->base->CheckStatements();  // whether base is declared
      const char *name = this->base->GetTypeName();

      if (name)
	{
	  Node *parent = this->GetParent();
	  Decl *cldecl = NULL; // look for ClassDecl
	  // whether the base is this
	  // otherwise the variable is inaccessible
	  while (parent)
	    {
	      Hashtable<Decl*> *sym_table = parent->GetSymTable();
	      if (sym_table)
		if ((cldecl = sym_table->Lookup(name)) != NULL)
		  {
		    decl = this->field->CheckIdDecl(cldecl->GetSymTable(), this->field->GetName());
                    if ((decl == NULL) || (typeid(*decl) != typeid(VarDecl)))
       	              ReportError::FieldNotFoundInBase(this->field, new Type(name));
		  }
	      parent = parent->GetParent();
	    }
	  if (cldecl == NULL)
	    {
	      if ((cldecl = Program::sym_table->Lookup(name)) != NULL) // look up global symbol table
	        {
	          decl = this->field->CheckIdDecl(cldecl->GetSymTable(), this->field->GetName());
	          if ((decl != NULL) && (typeid(*decl) == typeid(VarDecl)))
	            ReportError::InaccessibleField(this->field, new Type(name)); // data member is private
	          else
	            ReportError::FieldNotFoundInBase(this->field, new Type(name)); // no such field
	        }
	      else // for those with no symbol tables, e.g. int[]
		ReportError::FieldNotFoundInBase(this->field, new Type(name));
	    }
	}
    }
  else
    {
      // no base, just check whether the field is declared
      decl = this->field->CheckIdDecl();
      if (decl == NULL || typeid(*decl) != typeid(VarDecl))
        {
          ReportError::IdentifierNotDeclared(this->field, LookingForVariable);
          decl = NULL; // to force not to get the type
                       // and avoid cascading error reports
        }
    }
  if (decl != NULL)
    this->type = decl->GetType(); 
}

Location *FieldAccess::Emit() {
  if (this->base)
    {
      // to be implemented
      return NULL;
    }
  else
    {
      Decl *decl = this->field->CheckIdDecl();
      if (decl && typeid(*decl) == typeid(VarDecl))
        {
          return dynamic_cast<VarDecl*>(decl)->GetMemLoc();
        }
      else
        return NULL;
    }
}

Call::Call(yyltype loc, Expr *b, Identifier *f, List<Expr*> *a) : Expr(loc)  {
  Assert(f != NULL && a != NULL); // b can be be NULL (just means no explicit base)
  this->base = b;
  if (this->base) base->SetParent(this);
  (this->field=f)->SetParent(this);
  (this->actuals=a)->SetParentAll(this);
}

void Call::CheckArguments(FnDecl *fndecl) {
  List<VarDecl*> *formals = fndecl->GetFormals();
  int formals_num = formals->NumElements();
  int args_num = this->actuals->NumElements();
  if (formals_num != args_num)
    {
      ReportError::NumArgsMismatch(this->field, formals_num, args_num);
      return;
    }
  else
    {
      for (int i = 0; i < formals_num; i++)
	{
	  VarDecl *vardecl = formals->Nth(i);
	  const char *expected = vardecl->GetTypeName();
	  Expr *expr = this->actuals->Nth(i);
	  const char *given = expr->GetTypeName();

          if (given && expected)
            {
              Decl *gdecl = Program::sym_table->Lookup(given);
              Decl *edecl = Program::sym_table->Lookup(expected);

              if (gdecl && edecl) // objects
                {
                  if (strcmp(given, expected))
		    if (typeid(*gdecl) == typeid(ClassDecl))
		      {
			ClassDecl *gcldecl = dynamic_cast<ClassDecl*>(gdecl);
			if (!gcldecl->IsCompatibleWith(edecl))
			  ReportError::ArgMismatch(expr, (i+1), new Type(given), new Type(expected));
		      }
                }
              else if (edecl && strcmp(given, "null")) // null arguments
		ReportError::ArgMismatch(expr, (i+1), new Type(given), new Type(expected));
              else if (gdecl == NULL && edecl == NULL && strcmp(given, expected)) // non-object arguments
                ReportError::ArgMismatch(expr, (i+1), new Type(given), new Type(expected));
	    }
	}
    }
}

void Call::CheckStatements() {
  if (this->actuals)
    {
      for (int i = 0; i < actuals->NumElements(); i++)
	this->actuals->Nth(i)->CheckStatements();
    }

  Decl *decl = NULL;

  if (this->base)
    {
      this->base->CheckStatements();
      const char *name = this->base->GetTypeName();
      // all the methods are public
      // no need to check the accessibility
      if (name)
        {
          if ((decl = Program::sym_table->Lookup(name)) != NULL)
	    {
	      decl = this->field->CheckIdDecl(decl->GetSymTable(), this->field->GetName());
	      if ((decl == NULL) || (typeid(*decl) != typeid(FnDecl)))
		ReportError::FieldNotFoundInBase(this->field, new Type(name));
	      else
		CheckArguments(dynamic_cast<FnDecl*>(decl));
	    }
	  else if ((typeid(*this->base->GetType()) != typeid(ArrayType))
		   || strcmp(this->field->GetName(), "length")) // arr.length() is supported
	    {
	      ReportError::FieldNotFoundInBase(this->field, new Type(name));
	    }
        }
    }
  else
    {
      // no base, just check whether the field is declared
      decl = this->field->CheckIdDecl();
      if ((decl == NULL) || (typeid(*decl) != typeid(FnDecl)))
        {
	  ReportError::IdentifierNotDeclared(this->field, LookingForFunction);
	  decl = NULL; // to force not to get the type
                       // and avoid cascading error reports
        }
      else
	CheckArguments(dynamic_cast<FnDecl*>(decl));
    }
  if (decl != NULL)
    this->type = decl->GetType(); // returnType
}

NewExpr::NewExpr(yyltype loc, NamedType *c) : Expr(loc) { 
  Assert(c != NULL);
  (this->cType=c)->SetParent(this);
}

void NewExpr::CheckStatements() {
  if (this->cType)
    {
      const char *name = this->cType->GetTypeName();
      if (name)
        {
          Decl *decl = Program::sym_table->Lookup(name);
          if ((decl == NULL) || (typeid(*decl) != typeid(ClassDecl)))
            ReportError::IdentifierNotDeclared(new Identifier(*this->cType->GetLocation(), name), LookingForClass);
        }
    }
}

NewArrayExpr::NewArrayExpr(yyltype loc, Expr *sz, Type *et) : Expr(loc) {
  Assert(sz != NULL && et != NULL);
  (this->size=sz)->SetParent(this); 
  (this->elemType=et)->SetParent(this);
}

const char *NewArrayExpr::GetTypeName() {
  if (this->elemType)
    {
      string delim = "[]";
      string str = this->elemType->GetTypeName() + delim;
      return str.c_str();
    }
  else
    return NULL;
}

void NewArrayExpr::CheckStatements() {
  this->size->CheckStatements();
  if (strcmp(this->size->GetTypeName(), "int"))
    ReportError::NewArraySizeNotInteger(this->size);
  this->elemType->CheckTypeError();
}

ReadLineExpr::ReadLineExpr(yyltype loc)
  : Expr(loc) {
  Expr::type = Type::stringType;
}

ReadIntegerExpr::ReadIntegerExpr(yyltype loc)
  : Expr(loc) {
  Expr::type = Type::intType;
}

PostfixExpr::PostfixExpr(yyltype loc, LValue *lv, Operator *op)
  : Expr(loc) {
  Assert(lv != NULL && op != NULL);
  (this->lvalue=lv)->SetParent(this);
  (this->optr=op)->SetParent(this);
}

void PostfixExpr::CheckStatements() {
  if (this->lvalue)
    {
      this->lvalue->CheckStatements();
      const char *name = this->lvalue->GetTypeName();
      if (strcmp(name, "int") && strcmp(name, "double"))
	ReportError::IncompatibleOperand(this->optr, this->lvalue->GetType());
    }
}
