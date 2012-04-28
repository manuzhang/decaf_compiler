/* File: ast_stmt.cc
 * -----------------
 * Implementation of statement node classes.
 */
#include "ast_stmt.h"
#include "ast_type.h"
#include "ast_decl.h"
#include "ast_expr.h"
#include "hashtable.h"
#include "errors.h"

Program::Program(List<Decl*> *d) {
    Assert(d != NULL);
    (decls=d)->SetParentAll(this);
}

/*void Program::PrintChildren(int indentLevel) {
    decls->PrintAll(indentLevel+1);
    printf("\n");
}*/

void Program::CheckDeclConflict() {
  if (decls)
    {
      Hashtable<Decl*> *sym_table  = new Hashtable<Decl*>;
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
      delete sym_table;
    }
}

StmtBlock::StmtBlock(List<VarDecl*> *d, List<Stmt*> *s) {
    Assert(d != NULL && s != NULL);
    (decls=d)->SetParentAll(this);
    (stmts=s)->SetParentAll(this);
}

/*void StmtBlock::PrintChildren(int indentLevel) {
    decls->PrintAll(indentLevel+1);
    stmts->PrintAll(indentLevel+1);
}*/

ConditionalStmt::ConditionalStmt(Expr *t, Stmt *b) { 
    Assert(t != NULL && b != NULL);
    (test=t)->SetParent(this); 
    (body=b)->SetParent(this);
}

ForStmt::ForStmt(Expr *i, Expr *t, Expr *s, Stmt *b): LoopStmt(t, b) { 
    Assert(i != NULL && t != NULL && s != NULL && b != NULL);
    (init=i)->SetParent(this);
    (step=s)->SetParent(this);
}

/*void ForStmt::PrintChildren(int indentLevel) {
    init->Print(indentLevel+1, "(init) ");
    test->Print(indentLevel+1, "(test) ");
    step->Print(indentLevel+1, "(step) ");
    body->Print(indentLevel+1, "(body) ");
}

void WhileStmt::PrintChildren(int indentLevel) {
    test->Print(indentLevel+1, "(test) ");
    body->Print(indentLevel+1, "(body) ");
}*/

IfStmt::IfStmt(Expr *t, Stmt *tb, Stmt *eb): ConditionalStmt(t, tb) { 
    Assert(t != NULL && tb != NULL); // else can be NULL
    elseBody = eb;
    if (elseBody) elseBody->SetParent(this);
}

/*void IfStmt::PrintChildren(int indentLevel) {
    if (test) test->Print(indentLevel+1, "(test) ");
    if (body) body->Print(indentLevel+1, "(then) ");
    if (elseBody) elseBody->Print(indentLevel+1, "(else) ");
}*/


ReturnStmt::ReturnStmt(yyltype loc, Expr *e) : Stmt(loc) { 
    Assert(e != NULL);
    (expr=e)->SetParent(this);
}

/*void ReturnStmt::PrintChildren(int indentLevel) {
    expr->Print(indentLevel+1);
}*/
  
PrintStmt::PrintStmt(List<Expr*> *a) {    
    Assert(a != NULL);
    (args=a)->SetParentAll(this);
}

/*void PrintStmt::PrintChildren(int indentLevel) {
    args->PrintAll(indentLevel+1, "(args) ");
}*/

CaseStmt::CaseStmt(IntConstant *ic, List<Stmt*> *sts) {
    (intconst=ic)->SetParent(this);
    (stmts=sts)->SetParentAll(this);
}

/*void CaseStmt::PrintChildren(int indentLevel) {
    intconst->Print(indentLevel+1);
    if (stmts) stmts->PrintAll(indentLevel+1);
}*/

DefaultStmt::DefaultStmt(List<Stmt*> *sts) {
    if (sts) (stmts=sts)->SetParentAll(this);
}

/*void DefaultStmt::PrintChildren(int indentLevel) {
    if (stmts) stmts->PrintAll(indentLevel+1);
}*/

SwitchStmt::SwitchStmt(Expr *e, List<CaseStmt*> *cs, DefaultStmt *ds) {
    Assert(e != NULL && cs != NULL);
    (expr=e)->SetParent(this);
    (cases=cs)->SetParentAll(this);
    if (ds) (defaults=ds)->SetParent(this);
}

/*void SwitchStmt::PrintChildren(int indentLevel) {
    expr->Print(indentLevel+1);
    cases->PrintAll(indentLevel+1);
    if (defaults) defaults->Print(indentLevel+1);
}*/
