/* File: ast_expr.cc
 * -----------------
 * Implementation of expression node classes.
 */

#include <string.h>

#include <iostream>
#include <typeinfo>

#include "ast_expr.h"
#include "ast_type.h"
#include "ast_decl.h"
#include "codegen.h"
#include "errors.h"
#include "tac.h"

using std::cout;
using std::endl;

bool Expr::HasBase() {
  if (this->GetBase())
    return true;
  else
    {
      Decl *decl = this->GetField()->CheckIdDecl();
      if (decl)
        {
	  if (decl->GetEnclosFunc(decl) == NULL
              && decl->GetEnclosClass(decl) != NULL)
            return true;
        }
    }
  return false;
}

IntConstant::IntConstant(yyltype loc, int val)
  : Expr(loc) {
  this->value = val;
  Expr::type = Type::intType;
}

Location *IntConstant::Emit() {
  FnDecl *fndecl = this->GetEnclosFunc(this);
  if (fndecl)
    {
      int localOffset = fndecl->UpdateFrame();
      return Program::cg->GenLoadConstant(this->value, localOffset);
    }

  return NULL;
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
  FnDecl *fndecl = this->GetEnclosFunc(this);
  if (fndecl)
    {
      int localOffset = fndecl->UpdateFrame();
      return Program::cg->GenLoadConstant(static_cast<int>(this->value), localOffset);
    }

  return NULL;

}

StringConstant::StringConstant(yyltype loc, const char *val)
  : Expr(loc) {
  Assert(val != NULL);
  this->value = strdup(val);
  Expr::type = Type::stringType;
}

Location *StringConstant::Emit() {
  FnDecl *fndecl = this->GetEnclosFunc(this);
  if (fndecl)
    {
      int localOffset = fndecl->UpdateFrame();
      return Program::cg->GenLoadConstant(this->value, localOffset);
    }

  return NULL;
}

NullConstant::NullConstant(yyltype loc)
  : Expr(loc) {
  Expr::type = Type::nullType;
}

Location *NullConstant::Emit() {
  FnDecl *fndecl = this->GetEnclosFunc(this);
  int localOffset = 0;
  if (fndecl)
    {
      localOffset = fndecl->UpdateFrame();
      return Program::cg->GenLoadConstant(0, localOffset);
    }
  return NULL;
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
  
void ArithmeticExpr::CheckStatements() {
  Type *lt = NULL, *rt = NULL;

  if (this->left) // binary
    {
      this->left->CheckStatements();
      lt = this->left->GetType();
    }

  this->right->CheckStatements();
  rt = this->right->GetType();
  if (lt && rt) // binary
    {
      if ((lt != Type::intType && lt != Type::doubleType) ||
	  (rt != Type::intType && rt != Type::doubleType) ||
	  (lt != rt))
        ReportError::IncompatibleOperands(this->op, lt, rt);
    }
  else if (rt) // unary
    {
      if (rt != Type::intType && rt != Type::doubleType)
        ReportError::IncompatibleOperand(this->op, rt);
    }
}

Location *ArithmeticExpr::Emit() {
  if (this->right)
    {

      FnDecl *fndecl = this->GetEnclosFunc(this);
      if (fndecl)
	{
	  const char *token = this->GetOp()->GetToken();
	  if (this->left) // binary
	    {
	      int localOffset = fndecl->UpdateFrame();
	      return Program::cg->GenBinaryOp(token, this->left->Emit(), this->right->Emit(), localOffset);
	    }
	  else
	    {
	      int localOffset = fndecl->UpdateFrame();
	      Location *zero = Program::cg->GenLoadConstant(0, localOffset);
	      localOffset = fndecl->UpdateFrame();
	      return Program::cg->GenBinaryOp(token, zero, this->right->Emit(), localOffset);
	    }
	}
    }

  return NULL;
}

void RelationalExpr::CheckStatements() {
  this->left->CheckStatements();
  Type *lt = this->left->GetType();

  this->right->CheckStatements();
  Type *rt = this->right->GetType();

  if (lt && rt) // binary
    {
      if ((lt != Type::intType && lt != Type::doubleType) ||
          (rt != Type::intType && rt != Type::doubleType) ||
          (lt != rt))	
        ReportError::IncompatibleOperands(this->op, lt, rt);
    }
}

Location *RelationalExpr::Emit() {
  if (this->left && this->right)
    {
      FnDecl *fndecl = this->GetEnclosFunc(this);
      if (fndecl) // local variable
        {
          const char *token = this->GetOp()->GetToken();
          Location *left_loc = this->left->Emit();
          Location *right_loc = this->right->Emit();
          if (!strcmp(token, "<"))
            {
              int localOffset = fndecl->UpdateFrame();
              return Program::cg->GenBinaryOp(token, left_loc, right_loc, localOffset);
            }
          else if (!strcmp(token, ">"))
            {
	      int localOffset = fndecl->UpdateFrame();
	      return Program::cg->GenBinaryOp("<", right_loc, left_loc, localOffset);
	    }
          else if (!strcmp(token, "<="))
            {
              int localOffset = fndecl->UpdateFrame();
              Location *new_left = Program::cg->GenBinaryOp("<", left_loc, right_loc, localOffset);
              localOffset = fndecl->UpdateFrame();
              Location *new_right = Program::cg->GenBinaryOp("==", left_loc, right_loc, localOffset);
              localOffset = fndecl->UpdateFrame();
              return Program::cg->GenBinaryOp("||", new_left, new_right, localOffset);
            }
          else if (!strcmp(token, ">="))
            {
              int localOffset = fndecl->UpdateFrame();
              Location *new_left = Program::cg->GenBinaryOp("<", right_loc, left_loc, localOffset);
              localOffset = fndecl->UpdateFrame();
              Location *new_right = Program::cg->GenBinaryOp("==", left_loc, right_loc, localOffset);
              localOffset = fndecl->UpdateFrame();
              return Program::cg->GenBinaryOp("||", new_left, new_right, localOffset);
            }
        }
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


Location *EqualityExpr::Emit() {
  if (this->left && this->right)
    {
      int localOffset = 0;
      FnDecl *fndecl = this->GetEnclosFunc(this);
      if (fndecl) // local variable
        {
	  if (this->left->GetType() == Type::stringType && this->right->GetType() == Type::stringType)
	    {
	      localOffset = fndecl->UpdateFrame();
	      return Program::cg->GenBuiltInCall(StringEqual, this->left->Emit(), this->right->Emit(), localOffset);
	    }
	  else
	    {
	      const char *token = this->GetOp()->GetToken();

              Location *left_loc = this->left->Emit();
              Location *right_loc = this->right->Emit();

	      if (!strcmp(token, "!="))
	        {
	          int localOffset = fndecl->UpdateFrame();
	          Location *less = Program::cg->GenBinaryOp("<", left_loc, right_loc, localOffset);

	          localOffset = fndecl->UpdateFrame();
	          Location *greater = Program::cg->GenBinaryOp("<", right_loc, left_loc, localOffset);

	          localOffset = fndecl->UpdateFrame();
	          return Program::cg->GenBinaryOp("||", less, greater, localOffset);
	        }
	      else
	        {
	          int localOffset = fndecl->UpdateFrame();
	          return Program::cg->GenBinaryOp(token, left_loc, right_loc, localOffset);
	        }
	    }
        }
    }

  return NULL;

}

void LogicalExpr::CheckStatements() {
  Type *lt = NULL, *rt = NULL;
  if (this->left)
    {
      this->left->CheckStatements();
      lt = this->left->GetType();
    }
  this->right->CheckStatements();
  rt = this->right->GetType();
  if (lt && rt)
    {
      if ((lt != Type::boolType) || (rt != Type::boolType))
        ReportError::IncompatibleOperands(this->op, lt, rt);
    }
  else if (rt)
    {
      if (rt != Type::boolType)
        ReportError::IncompatibleOperand(this->op, rt);
    }

}

Location *LogicalExpr::Emit() {
  if (this->right)
    {
      FnDecl *fndecl = this->GetEnclosFunc(this);

      if (fndecl) // local variable
        {
          if (this->left) // binary
	    {
	      int localOffset = fndecl->UpdateFrame();

	      return Program::cg->GenBinaryOp(this->GetOp()->GetToken(), this->left->Emit(), this->right->Emit(), localOffset);
	    }
          else // unary Not
            {
	      int localOffset = fndecl->UpdateFrame();
	      Location *one = Program::cg->GenLoadConstant(1, localOffset);
	      localOffset = fndecl->UpdateFrame();
              return Program::cg->GenBinaryOp("-", one, this->right->Emit(), localOffset);
            }
        }
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
  int localOffset = 0;
  if (this->left && this->right)
    {
      if (typeid(*this->right) == typeid(ReadLineExpr)) // make a copy; otherwise could be changed by following call
        {

        }

      Location *right_loc = this->right->Emit();
      if (this->left->HasBase())
        {
          Location *left_loc = this->left->StoreEmit();
          Program::cg->GenStore(left_loc, right_loc);
          return left_loc;
        }
      else
        {
          Location *left_loc = this->left->Emit();
          Program::cg->GenAssign(left_loc, right_loc);
          return left_loc;
        }
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

Location *This::Emit() {
  FnDecl *fndecl = this->GetEnclosFunc(this);
  if (fndecl)
    return fndecl->GetFormals()->Nth(0)->GetID()->GetMemLoc();
  return NULL;
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

Location *ArrayAccess::Emit() {
  Location *address = this->StoreEmit();
  int localOffset;
  FnDecl *fndecl = this->GetEnclosFunc(this);
  if (fndecl)
    {
      localOffset = fndecl->UpdateFrame();
      return Program::cg->GenLoad(address, localOffset);
    }
  return NULL;
}

Location *ArrayAccess::StoreEmit() {
  if (this->base && this->subscript)
    {
      int localOffset = 0;
      FnDecl *fndecl = this->GetEnclosFunc(this);
      if (fndecl)
        {
          // access array size
          Location *base_loc = this->base->Emit();
      
          localOffset = fndecl->UpdateFrame();
          Location *size = Program::cg->GenLoad(base_loc, localOffset);

          // whether out of bounds
          localOffset = fndecl->UpdateFrame();

          Location *subs = this->subscript->Emit();
          Location *test_max = Program::cg->GenBinaryOp("<", subs, size, localOffset);
          localOffset = fndecl->UpdateFrame();
	  Location *minus = Program::cg->GenLoadConstant(-1, localOffset);

          localOffset = fndecl->UpdateFrame();
          Location *test_min = Program::cg->GenBinaryOp("<", minus, subs, localOffset);

          char *label_0 = Program::cg->NewLabel();
          char *label_1 = Program::cg->NewLabel();

          localOffset = fndecl->UpdateFrame();
          Location *test = Program::cg->GenBinaryOp("&&", test_min, test_max, localOffset);

          Program::cg->GenIfZ(test, label_0);

          // access the element
          localOffset = fndecl->UpdateFrame();
          Location *varsize_loc = Program::cg->GenLoadConstant(CodeGenerator::VarSize, localOffset);
          localOffset = fndecl->UpdateFrame();
          Location *tmp = Program::cg->GenBinaryOp("*", subs, varsize_loc, localOffset);
          localOffset = fndecl->UpdateFrame();
          Location *offset_loc = Program::cg->GenBinaryOp("+", tmp, varsize_loc, localOffset);
          Location *address = Program::cg->GenBinaryOp("+", base_loc, offset_loc, localOffset);

          Program::cg->GenGoto(label_1);

	  // report error
          Program::cg->GenLabel(label_0);
          const char *error_msg = "Decaf runtime error: Array script out of bounds";
          Program::PrintError(error_msg, fndecl);

          Program::cg->GenLabel(label_1);

          return address;
        }
    }

  return NULL;
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
	  // whether the base is this of subclasses
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
  FnDecl *fndecl = this->GetEnclosFunc(this);
  int localOffset = 0;

  if (fndecl)
    {
      if (this->base)
	{
          Location *base_loc = this->base->Emit();

	  ClassDecl *classdecl = NULL;
	  if (typeid(*this->base) == typeid(This))
	    classdecl = this->GetEnclosClass(this);
	  else
	    {
	      Decl *decl = Program::sym_table->Lookup(this->base->GetTypeName());
	      if (decl && typeid(*decl) == typeid(ClassDecl))
	        classdecl = dynamic_cast<ClassDecl*>(decl);
	    }
	  if (classdecl)
	    return this->LoadField(base_loc, classdecl, fndecl);
 	}
      else
	{
	  Decl *decl = this->field->CheckIdDecl();
     	  if (decl)
     	    {
     	      ClassDecl *classdecl = decl->GetEnclosClass(decl);
    	      if ((decl->GetEnclosFunc(decl) != NULL) // locals or params
     	          || classdecl == NULL) // globals
	        return decl->GetID()->GetMemLoc();
     	      else // this omitted
     	        {
		  Location *base_loc = fndecl->GetFormals()->Nth(0)->GetID()->GetMemLoc();
     	          return this->LoadField(base_loc, classdecl, fndecl);
     	        }
	    }
	}
    }
  return NULL;
}

Location *FieldAccess::StoreEmit() {
  FnDecl *fndecl = this->GetEnclosFunc(this);
  int localOffset = 0;

  if (fndecl)
    {
      if (this->base)
        {
          Location *base_loc = this->base->Emit();

          ClassDecl *classdecl = NULL;
          if (typeid(*this->base) == typeid(This))
            classdecl = this->GetEnclosClass(this);
          else
            {
              Decl *decl = Program::sym_table->Lookup(this->base->GetTypeName());
              if (decl && typeid(*decl) == typeid(ClassDecl))
                classdecl = dynamic_cast<ClassDecl*>(decl);

            }
          if (classdecl)
            return this->StoreField(base_loc, classdecl, fndecl);
        }
      else
        {
          Decl *decl = this->field->CheckIdDecl();
          if (decl)
            {
              ClassDecl *classdecl = decl->GetEnclosClass(decl);
              if (decl->GetEnclosFunc(decl) != NULL
                  || classdecl == NULL) // locals or params
                return decl->GetID()->GetMemLoc();
              else // this omitted
                {
        	  Location *base_loc = fndecl->GetFormals()->Nth(0)->GetID()->GetMemLoc();
                  return this->StoreField(base_loc, classdecl, fndecl);
                }
            }
        }
    }
  return NULL;
}

Location *FieldAccess::LoadField(Location *base_loc, ClassDecl *classdecl, FnDecl *fndecl) {
  if (classdecl)
    {
      int localOffset = 0;
      List<const char *> *fieldlabels = classdecl->GetFieldLabels();
      for (int i = 0; i < fieldlabels->NumElements(); i++)
        {
          if (!strcmp(fieldlabels->Nth(i), this->field->GetName()))
            {
              localOffset = fndecl->UpdateFrame();
              return Program::cg->GenLoad(base_loc, localOffset, (i + 1) * CodeGenerator::VarSize);
            }
        }
    }
  return NULL;
}

Location *FieldAccess::StoreField(Location *base_loc, ClassDecl *classdecl, FnDecl *fndecl) {
  if (classdecl)
    {
      int localOffset = 0;
      List<const char *> *fieldlabels = classdecl->GetFieldLabels();
      for (int i = 0; i < fieldlabels->NumElements(); i++)
        {
          if (!strcmp(fieldlabels->Nth(i), this->field->GetName()))
            {
              localOffset = fndecl->UpdateFrame();
              Location *offset_loc = Program::cg->GenLoadConstant((i + 1) * CodeGenerator::VarSize, localOffset);
              localOffset = fndecl->UpdateFrame();
              return Program::cg->GenBinaryOp("+", base_loc, offset_loc, localOffset);
            }
        }
    }
  return NULL;
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
	  else if ((typeid(*this->base->GetType()) == typeid(ArrayType))
		   && !strcmp(this->field->GetName(), "length")) // arr.length() is supported
	    {
	      this->type = Type::intType;
	    }
	  else
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

Location *Call::Emit() {
  Location *rtvalue = NULL;
  int localOffset = 0;

  FnDecl *fndecl = this->GetEnclosFunc(this);
  if (fndecl)
    {
      if (this->base)
	{
	  // arr.length()
	  if (typeid(*this->base->GetType()) == typeid(ArrayType) && !strcmp(this->field->GetName(), "length"))
	    {
	      localOffset = fndecl->UpdateFrame();
	      return Program::cg->GenLoad(this->base->Emit(), localOffset);
	    }

	  Location *base_loc = this->base->Emit();

	  Decl *decl = NULL;

	  const char *classname = this->base->GetTypeName();
	  if ((decl = Program::sym_table->Lookup(classname)) != NULL)
	    rtvalue = RuntimeCall(base_loc, dynamic_cast<ClassDecl*>(decl), fndecl);

	 
	  return rtvalue;
	}
      else
	{
	  Decl *decl = this->field->CheckIdDecl();
	  if (decl && typeid(*decl) == typeid(FnDecl))
	    {
	      ClassDecl *classdecl = decl->GetEnclosClass(decl); // could be base class
	      if (classdecl) // "this" is omitted
		{
	          Location *base_loc = fndecl->GetFormals()->Nth(0)->GetID()->GetMemLoc();
	          rtvalue = RuntimeCall(base_loc, this->GetEnclosClass(this), fndecl);
		}
	      else
		{
		  int args_num = PushArguments(this->actuals);
		  FnDecl *call = dynamic_cast<FnDecl*>(decl);
		  if (decl->GetType() == Type::voidType)
		    {
		      rtvalue = Program::cg->GenLCall(call->GetLabel(), false);
		    }
		  else
		    {
		      localOffset = fndecl->UpdateFrame();
		      rtvalue = Program::cg->GenLCall(call->GetLabel(), true, localOffset);
		    }
		  Program::cg->GenPopParams(args_num * CodeGenerator::VarSize);
		}
	      return rtvalue;
	    }
	}
    }
  return NULL;
}

int Call::PushArguments(List<Expr*> *args) {
  int args_num = 0;
  if (args)
    {
      args_num = args->NumElements();
      //for (int i = 0; i < args_num; i++)
      for (int i = args_num - 1; i >= 0; i--)
	{
	  Expr *arg = args->Nth(i);
	  Program::cg->GenPushParam(arg->Emit());
	}
    }
  return args_num;
}

Location *Call::RuntimeCall(Location *base_loc, ClassDecl *classdecl, FnDecl *fndecl) {
  Location *func = NULL, *rtvalue = NULL;

  int localOffset;

  localOffset = fndecl->UpdateFrame();
  Location *vtable = Program::cg->GenLoad(base_loc, localOffset);

  List<const char *> *methodlabels = classdecl->GetMethodLabels();
  for (int i = 0; i < methodlabels->NumElements(); i++)
    {
      const char *methodname = strchr(methodlabels->Nth(i), '.') + 1;
      if (!strcmp(methodname, this->field->GetName()))
	{
	  localOffset = fndecl->UpdateFrame();
	  func = Program::cg->GenLoad(vtable, localOffset, i * CodeGenerator::VarSize);
	  break;
	}
    }

  // push arguments and the default "this"
  int args_num = PushArguments(this->actuals);
  Program::cg->GenPushParam(base_loc);

  if (func)
    {
      if (this->GetType() == Type::voidType)
	{
	  rtvalue = Program::cg->GenACall(func, false);
	}
      else
	{
	  localOffset = fndecl->UpdateFrame();
	  rtvalue = Program::cg->GenACall(func, true, localOffset);
	}
    }
  Program::cg->GenPopParams((args_num + 1) * CodeGenerator::VarSize);
  return rtvalue;
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

Location *NewExpr::Emit() {
  FnDecl *fndecl = this->GetEnclosFunc(this);
  int localOffset = 0;

  if (fndecl)
    {      
      const char *name = this->cType->GetTypeName();
      Decl *decl = Program::sym_table->Lookup(name);
      if (decl && typeid(*decl) == typeid(ClassDecl))
        {
	  ClassDecl *classdecl = dynamic_cast<ClassDecl*>(decl);
	  List<const char *> *fieldlabels = classdecl->GetFieldLabels();
	  int field_num = fieldlabels->NumElements();
	  localOffset = fndecl->UpdateFrame();
	  Location *var_size = Program::cg->GenLoadConstant(CodeGenerator::VarSize * (field_num + 1), localOffset);
	  localOffset = fndecl->UpdateFrame();
	  Location *dst = Program::cg->GenBuiltInCall(Alloc, var_size, NULL, localOffset);
	  localOffset = fndecl->UpdateFrame();
	  Location *src =  Program::cg->GenLoadLabel(this->cType->GetTypeName(), localOffset);
	  Program::cg->GenStore(dst, src);
	  return dst;
        }
    }

  return NULL;
}

NewArrayExpr::NewArrayExpr(yyltype loc, Expr *sz, Type *et) : Expr(loc) {
  Assert(sz != NULL && et != NULL);
  (this->size=sz)->SetParent(this); 
  (this->elemType=et)->SetParent(this);
}

Location *NewArrayExpr::Emit() {
  if (this->size && this->elemType)
    {

      FnDecl *fndecl = this->GetEnclosFunc(this);
      if (fndecl)
	{
	  char *label_0 = Program::cg->NewLabel();

	  Location *size_loc = this->size->Emit();

	  int localOffset = fndecl->UpdateFrame();
	  Location *zero = Program::cg->GenLoadConstant(0, localOffset);

	  localOffset = fndecl->UpdateFrame();
	  Location *less = Program::cg->GenBinaryOp("<", size_loc, zero, localOffset);

	  localOffset = fndecl->UpdateFrame();
	  Location *equal = Program::cg->GenBinaryOp("==", size_loc, zero, localOffset);

	  localOffset = fndecl->UpdateFrame();
	  Location *test = Program::cg->GenBinaryOp("||", less, equal, localOffset);
	  Program::cg->GenIfZ(test, label_0);

	  // if array size is negative or 0, print error messages
	  const char *error_msg = "Decaf runtime error: Array size is <= 0";
	  Program::PrintError(error_msg, fndecl);

	  Program::cg->GenLabel(label_0);

	  // plus one position to store the size of the array
	  localOffset = fndecl->UpdateFrame();
	  Location *var_size = Program::cg->GenLoadConstant(CodeGenerator::VarSize, localOffset);
	  localOffset = fndecl->UpdateFrame();
	  Location *bytes = Program::cg->GenBinaryOp("*", size_loc, var_size, localOffset);
	  localOffset = fndecl->UpdateFrame();
	  bytes = Program::cg->GenBinaryOp("+", bytes, var_size, localOffset);

	  localOffset = fndecl->UpdateFrame();
	  Location  *address = Program::cg->GenBuiltInCall(Alloc, bytes, NULL, localOffset);
	  // first position for the size of the array
	  Program::cg->GenStore(address, size_loc);
	  return address;
	}
    }

  return NULL;
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

Location *ReadLineExpr::Emit() {
  FnDecl *fndecl = this->GetEnclosFunc(this);
  if (fndecl)
    {
      int localOffset = fndecl->UpdateFrame();
      return Program::cg->GenBuiltInCall(ReadLine, NULL, NULL, localOffset);
    }
  return NULL;
}

ReadIntegerExpr::ReadIntegerExpr(yyltype loc)
  : Expr(loc) {
  Expr::type = Type::intType;
}

Location *ReadIntegerExpr::Emit() {
  FnDecl *fndecl = this->GetEnclosFunc(this);
  if (fndecl)
    {
      int localOffset = fndecl->UpdateFrame();
      return Program::cg->GenBuiltInCall(ReadInteger, NULL, NULL, localOffset);
    }
  return NULL;
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

Location *PostfixExpr::Emit() {
  if (this->lvalue)
    {
      Expr *expr = new AssignExpr(this->lvalue, new Operator(*this->GetLocation(), "="), new ArithmeticExpr(this->lvalue, new Operator(*this->GetLocation(), "+"), new IntConstant(*this->GetLocation(), 1)));

      expr->SetParent(this);

      FnDecl *fndecl = this->GetEnclosFunc(this);
      if (fndecl)
	{
	  Location *value = this->lvalue->Emit();

	  int localOffset = fndecl->UpdateFrame();
	  Location *one = Program::cg->GenLoadConstant(1, localOffset);

          localOffset = fndecl->UpdateFrame();
	  if (!strcmp(this->optr->GetToken(), "++"))
	    {
	      Location *plus = Program::cg->GenBinaryOp("+", value, one, localOffset);
	      Program::cg->GenAssign(value, plus);
	    }
	  else
	    {
	      Location *minus = Program::cg->GenBinaryOp("-", value, one, localOffset);
	      Program::cg->GenAssign(value, minus);
	    }
	  return value;
	}
    }

  return NULL;
}


