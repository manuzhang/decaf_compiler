/* File: ast_stmt.cc
 * -----------------
 * Implementation of statement node classes.
 */

#include <typeinfo>

#include "ast_stmt.h"
#include "ast_type.h"
#include "ast_decl.h"
#include "ast_expr.h"
#include "errors.h"

Hashtable<Decl*> *Program::sym_table  = new Hashtable<Decl*>;

Program::Program(List<Decl*> *d) {
  Assert(d != NULL);
  (this->decls=d)->SetParentAll(this);
}

void Program::CheckStatements() {
  for (int i = 0; i < this->decls->NumElements(); i++)
    this->decls->Nth(i)->CheckStatements();
}

void Program::CheckDeclError() {
  if (this->decls)
    {
      // check if identifiers in the global scope are unique
      for (int i = 0; i < this->decls->NumElements(); i++)
	{
          Decl *cur = decls->Nth(i);
          Decl *prev;
          const char *name = cur->GetID()->GetName();
	  if (name)
	    {
	      if ((prev = Program::sym_table->Lookup(name)) != NULL)
		ReportError::DeclConflict(cur, prev);
	      else
		sym_table->Enter(name, cur);
	    }
	}
      for (int i = 0; i < this->decls->NumElements(); i++)
	this->decls->Nth(i)->CheckDeclError();
      // all the declarations should be added to hashtables of their scopes
    }

}

StmtBlock::StmtBlock(List<VarDecl*> *d, List<Stmt*> *s) {
  Assert(d != NULL && s != NULL);
  (this->decls=d)->SetParentAll(this);
  (this->stmts=s)->SetParentAll(this);
  this->sym_table  = new Hashtable<Decl*>;
}

void StmtBlock::CheckStatements() {
  if (this->stmts)
    {
      for (int i = 0; i < this->stmts->NumElements(); i++)
        {
          Stmt *stmt = this->stmts->Nth(i);
          stmt->CheckStatements();
        }
    }
}

void StmtBlock::CheckDeclError() {
  if (this->decls)
    {
      for (int i = 0; i < this->decls->NumElements(); i++)
        {
	  VarDecl *cur = this->decls->Nth(i);
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
  if (this->stmts)
    {
      for (int i = 0; i < this->stmts->NumElements(); i++)
        {
          Stmt *stmt = stmts->Nth(i);
          stmt->CheckDeclError();
        }
    }
}

ConditionalStmt::ConditionalStmt(Expr *t, Stmt *b) { 
  Assert(t != NULL && b != NULL);
  (this->test=t)->SetParent(this); 
  (this->body=b)->SetParent(this);
}

void ConditionalStmt::CheckStatements() {
  this->test->CheckStatements();
  if (strcmp(this->test->GetTypeName(), "bool"))
    ReportError::TestNotBoolean(this->test);

  this->body->CheckStatements();
}

void ConditionalStmt::CheckDeclError() {
  this->body->CheckDeclError();
}

ForStmt::ForStmt(Expr *i, Expr *t, Expr *s, Stmt *b): LoopStmt(t, b) { 
  Assert(i != NULL && t != NULL && s != NULL && b != NULL);
  (this->init=i)->SetParent(this);
  (this->step=s)->SetParent(this);
}

void ForStmt::CheckStatements() {
  if (this->init)
    this->init->CheckStatements();
  if (this->step)
    this->step->CheckStatements();
  ConditionalStmt::CheckStatements();
}

void WhileStmt::CheckStatements() {
  ConditionalStmt::CheckStatements();
}

IfStmt::IfStmt(Expr *t, Stmt *tb, Stmt *eb): ConditionalStmt(t, tb) { 
  Assert(t != NULL && tb != NULL); // else can be NULL
  this->elseBody = eb;
  if (this->elseBody) elseBody->SetParent(this);
}

void IfStmt::CheckDeclError() {
  ConditionalStmt::CheckDeclError();
  if (this->elseBody)
    this->elseBody->CheckDeclError();
}

void IfStmt::CheckStatements() {
  ConditionalStmt::CheckStatements();
  if (this->elseBody)
    this->elseBody->CheckStatements();
}

void BreakStmt::CheckStatements() {
  Node *parent = this->GetParent();
  while (parent)
    {
      if ((typeid(*parent) == typeid(WhileStmt)) ||
          (typeid(*parent) == typeid(ForStmt)) ||
          (typeid(*parent) == typeid(SwitchStmt)))
        return;
      parent = parent->GetParent();
    }
  ReportError::BreakOutsideLoop(this);
}

ReturnStmt::ReturnStmt(yyltype loc, Expr *e) : Stmt(loc) { 
  Assert(e != NULL);
  (expr=e)->SetParent(this);
}

void ReturnStmt::CheckStatements() {

  const char *expected;
  Node *parent = this->GetParent();
  while (parent)
    {
      if (typeid(*parent) == typeid(FnDecl))
        expected = dynamic_cast<FnDecl*>(parent)->GetTypeName();
      parent = parent->GetParent();
    }
  if (this->expr)
    {
      this->expr->CheckStatements();
      const char *given = expr->GetTypeName();

      if (given && expected)
        {
          Decl *gdecl = Program::sym_table->Lookup(given);
          Decl *edecl = Program::sym_table->Lookup(expected);

          if (gdecl && edecl) // objects
            {
              if (!strcmp(given, expected))
                return;
              else if (typeid(*gdecl) == typeid(ClassDecl))
                {
                  ClassDecl *gcldecl = dynamic_cast<ClassDecl*>(gdecl);
                  if (gcldecl->IsCompatibleWith(edecl))
                    return;
                }
            }
          else if (edecl && !strcmp(given, "null"))
            return;
          else if (!strcmp(given, expected))
            return;

          ReportError::ReturnMismatch(this, new Type(given), new Type(expected));
        }
    }
  else if (strcmp("void", expected))
    ReportError::ReturnMismatch(this, new Type("void"), new Type(expected));
}
  
PrintStmt::PrintStmt(List<Expr*> *a) {    
  Assert(a != NULL);
  (args=a)->SetParentAll(this);
}

void PrintStmt::CheckStatements() {
  if (this->args)
    {
      for (int i = 0; i < this->args->NumElements(); i++)
        {
          Expr *expr = this->args->Nth(i);
          expr->CheckStatements();
          const char *typeName = expr->GetTypeName();
          if (typeName && strcmp(typeName, "string") && strcmp(typeName, "int") && strcmp(typeName, "bool"))
            ReportError::PrintArgMismatch(expr, (i+1), new Type(typeName));
        }
    }
}

CaseStmt::CaseStmt(IntConstant *ic, List<Stmt*> *sts)
  : DefaultStmt(sts) {
  (this->intconst=ic)->SetParent(this);
}

DefaultStmt::DefaultStmt(List<Stmt*> *sts) {
  if (sts) (this->stmts=sts)->SetParentAll(this);
}

void DefaultStmt::CheckStatements() {
  if (this->stmts)
    {
      for (int i = 0; i < this->stmts->NumElements(); i++)
        {
          Stmt *stmt = this->stmts->Nth(i);
          stmt->CheckStatements();
        }
    }
}

void DefaultStmt::CheckDeclError() {
  if (this->stmts)
    {
      for (int i = 0; i < this->stmts->NumElements(); i++)
        {
          Stmt *stmt = this->stmts->Nth(i);
          stmt->CheckDeclError();
        }
    }
}

SwitchStmt::SwitchStmt(Expr *e, List<CaseStmt*> *cs, DefaultStmt *ds) {
  Assert(e != NULL && cs != NULL);
  (this->expr=e)->SetParent(this);
  (this->cases=cs)->SetParentAll(this);
  this->defaults = ds;
  if (this->defaults) (this->defaults)->SetParent(this);
}

void SwitchStmt::CheckStatements() {
  if (this->expr)
    this->expr->CheckStatements();

  if (this->cases)
    {
      for (int i = 0; i < this->cases->NumElements(); i++)
        {
          CaseStmt *stmt = this->cases->Nth(i);
          stmt->CheckStatements();
        }
    }

  if (this->defaults)
    this->defaults->CheckStatements();
}

void SwitchStmt::CheckDeclError() {
  if (this->cases)
    {
      for (int i = 0; i < this->cases->NumElements(); i++)
        {
          CaseStmt *stmt = this->cases->Nth(i);
          stmt->CheckDeclError();
        }
    }

  if (this->defaults)
    this->defaults->CheckDeclError();
}
