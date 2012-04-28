/* File: ast_stmt.cc
 * -----------------
 * Implementation of statement node classes.
 */
#include "ast_stmt.h"
#include "ast_type.h"
#include "ast_decl.h"
#include "ast_expr.h"
#include "errors.h"

Program::Program(List<Decl*> *d) {
    Assert(d != NULL);
    (decls=d)->SetParentAll(this);
    sym_table  = new Hashtable<Decl*>;
}


void Program::CheckDeclConflict() {
  if (decls)
    {
      for (int i = 0; i < decls->NumElements(); i++)
        {
         Decl *cur = decls->Nth(i);
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
}

StmtBlock::StmtBlock(List<VarDecl*> *d, List<Stmt*> *s) {
    Assert(d != NULL && s != NULL);
    (decls=d)->SetParentAll(this);
    (stmts=s)->SetParentAll(this);
    sym_table  = new Hashtable<Decl*>;
}

void StmtBlock::CheckDeclConflict() {
  if (decls)
    {
      for (int i = 0; i < decls->NumElements(); i++)
        {
         Decl *cur = decls->Nth(i);
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
  if (stmts)
    {
      for (int i = 0; i < stmts->NumElements(); i++)
        {
          Stmt *stmt = stmts->Nth(i);
          stmt->CheckDeclConflict();
        }
    }
}

ConditionalStmt::ConditionalStmt(Expr *t, Stmt *b) { 
    Assert(t != NULL && b != NULL);
    (test=t)->SetParent(this); 
    (body=b)->SetParent(this);
}

void ConditionalStmt::CheckDeclConflict() {
  if (body)
    body->CheckDeclConflict();
}

ForStmt::ForStmt(Expr *i, Expr *t, Expr *s, Stmt *b): LoopStmt(t, b) { 
    Assert(i != NULL && t != NULL && s != NULL && b != NULL);
    (init=i)->SetParent(this);
    (step=s)->SetParent(this);
}


IfStmt::IfStmt(Expr *t, Stmt *tb, Stmt *eb): ConditionalStmt(t, tb) { 
    Assert(t != NULL && tb != NULL); // else can be NULL
    elseBody = eb;
    if (elseBody) elseBody->SetParent(this);
}

void IfStmt::CheckDeclConflict() {
  ConditionalStmt::CheckDeclConflict();
  if (elseBody)
    elseBody->CheckDeclConflict();
}

ReturnStmt::ReturnStmt(yyltype loc, Expr *e) : Stmt(loc) { 
    Assert(e != NULL);
    (expr=e)->SetParent(this);
}

  
PrintStmt::PrintStmt(List<Expr*> *a) {    
    Assert(a != NULL);
    (args=a)->SetParentAll(this);
}

CaseStmt::CaseStmt(IntConstant *ic, List<Stmt*> *sts) {
    (intconst=ic)->SetParent(this);
    (stmts=sts)->SetParentAll(this);
}

void CaseStmt::CheckDeclConflict() {
  if (stmts)
    {
      for (int i = 0; i < stmts->NumElements(); i++)
        {
          Stmt *stmt = stmts->Nth(i);
          stmt->CheckDeclConflict();
        }
    }
}


DefaultStmt::DefaultStmt(List<Stmt*> *sts) {
    if (sts) (stmts=sts)->SetParentAll(this);
}

SwitchStmt::SwitchStmt(Expr *e, List<CaseStmt*> *cs, DefaultStmt *ds) {
    Assert(e != NULL && cs != NULL);
    (expr=e)->SetParent(this);
    (cases=cs)->SetParentAll(this);
    if (ds) (defaults=ds)->SetParent(this);
}

void SwitchStmt::CheckDeclConflict() {
  if (cases)
    {
      for (int i = 0; i < cases->NumElements(); i++)
        {
          CaseStmt *stmt = cases->Nth(i);
          stmt->CheckDeclConflict();
        }
    }
}
