/* File: ast_stmt.h
 * ----------------
 * The Stmt class and its subclasses are used to represent
 * statements in the parse tree.  For each statment in the
 * language (for, if, return, etc.) there is a corresponding
 * node class for that construct. 
 *
 * pp4: You will need to extend the Stmt classes to implement
 * code generation for statements.
 */


#ifndef _H_ast_stmt
#define _H_ast_stmt

#include <string>

#include "ast.h"
#include "hashtable.h"
#include "list.h"

using std::string;

class Decl;
class VarDecl;
class FnDecl;
class Expr;
class IntConstant;

class CodeGenerator;

class Program : public Node
{
  protected:
     List<Decl*> *decls;

  public:
     Program(List<Decl*> *declList);
     void CheckStatements();
     void CheckDeclError();
     static Hashtable<Decl*> *sym_table; // global symbol table

     Location *Emit();
     static void PrintError(const char *error_msg, FnDecl *fndecl); // spim TAC for printing error messages
     static string GetClassLabel(const char *classname, const char *name);
     static string GetFuncLabel(const char *name);
     static CodeGenerator *cg; // code generator for the whole program
     static int offset; // global variable offset
     static string prefix;
};

class Stmt : public Node
{
  public:
     Stmt() : Node() {}
     Stmt(yyltype loc) : Node(loc) {}
     char *next; // label to goto after while/for/switch
};

class StmtBlock : public Stmt 
{
  protected:
    List<VarDecl*> *decls;
    List<Stmt*> *stmts;
    Hashtable<Decl*> *sym_table; // keep a symbol table for every local scope
                                 // no need for removal when leaving the scope

  public:
    StmtBlock(List<VarDecl*> *variableDeclarations, List<Stmt*> *statements);
    void CheckStatements();
    void CheckDeclError();
    Location *Emit();
    Hashtable<Decl*> *GetSymTable() { return sym_table; }
};

  
class ConditionalStmt : public Stmt
{
  protected:
    Expr *test;
    Stmt *body;

  public:
    ConditionalStmt(Expr *testExpr, Stmt *body);
    void CheckStatements();
    void CheckDeclError();
};

class LoopStmt : public ConditionalStmt 
{
  public:
    LoopStmt(Expr *testExpr, Stmt *body)
            : ConditionalStmt(testExpr, body) {}
};

class ForStmt : public LoopStmt 
{
  protected:
    Expr *init, *step;
  
  public:
    ForStmt(Expr *init, Expr *test, Expr *step, Stmt *body);
    void CheckStatements();

    Location *Emit();
};

class WhileStmt : public LoopStmt 
{
  public:
    WhileStmt(Expr *test, Stmt *body) : LoopStmt(test, body) {}
    void CheckStatements();

    Location *Emit();
 };

class IfStmt : public ConditionalStmt 
{
  protected:
    Stmt *elseBody;
  
  public:
    IfStmt(Expr *test, Stmt *thenBody, Stmt *elseBody);
    void CheckStatements();
    void CheckDeclError();

    Location *Emit();
};

class BreakStmt : public Stmt 
{
  protected:
    Stmt *enclos; // enclosing while/for/switch

  public:
    BreakStmt(yyltype loc) : Stmt(loc) {}
    void CheckStatements();

    Location *Emit();
};

class ReturnStmt : public Stmt  
{
  protected:
    Expr *expr;
  
  public:
    ReturnStmt(yyltype loc, Expr *expr);
    void CheckStatements();

    Location *Emit();
};

class PrintStmt : public Stmt
{
  protected:
    List<Expr*> *args;
    
  public:
    PrintStmt(List<Expr*> *arguments);
    void CheckStatements();
    Location *Emit();
};



class DefaultStmt : public Stmt
{
  protected:
    List<Stmt*> *stmts;

  public:
    DefaultStmt(List<Stmt*> *sts);
    void CheckStatements();
    void CheckDeclError();

    Location *Emit();
};


class CaseStmt : public DefaultStmt
{
  protected:
    IntConstant *intconst;

  public:
    CaseStmt(IntConstant *ic, List<Stmt*> *sts);
    IntConstant *GetLabel() { return intconst; }
};

class SwitchStmt : public Stmt
{
  protected:
    Expr *expr;
    List<CaseStmt*> *cases;
    DefaultStmt *defaults;

  public:
    SwitchStmt(Expr *e, List<CaseStmt*> *cs, DefaultStmt *ds);
    void CheckStatements();
    void CheckDeclError();

    Location *Emit();
};


#endif
