/* File: ast_decl.h
 * ----------------
 * In our parse tree, Decl nodes are used to represent and
 * manage declarations. There are 4 subclasses of the base class,
 * specialized for declarations of variables, functions, classes,
 * and interfaces.
 */

#ifndef _H_ast_decl
#define _H_ast_decl

#include "ast.h"
#include "ast_type.h"
#include "hashtable.h"
#include "list.h"

class Identifier;
class StmtBlock;


class Decl : public Node 
{
  protected:
    Identifier *id;
  
  public:
    Decl(Identifier *name);
    Identifier *GetID() { return id; }
    friend ostream& operator<<(ostream &out, Decl *decl) { return out << decl->id; }
    virtual void CheckDeclError() {}
    virtual char *GetTypeName() { return NULL; }
};

class VarDecl : public Decl 
{
  protected:
    Type *type;
    
  public:
    VarDecl(Identifier *name, Type *type);
    Type *GetType() { return type; }
    char *GetTypeName() { return type->GetTypeName(); }
    bool HasSameTypeSig(VarDecl *vd);
    void CheckStatements();
    void CheckDeclError();
};


class ClassDecl : public Decl 
{
  protected:
    List<Decl*> *members;
    NamedType *extends;
    List<NamedType*> *implements;

  public:
    ClassDecl(Identifier *name, NamedType *extends, 
              List<NamedType*> *implements, List<Decl*> *members);
    NamedType *GetExtends() { return extends; }
    void CheckStatements();
    void CheckDeclError();
    Hashtable<Decl*> *GetSymTable() { return sym_table; }
    Hashtable<Decl*> *sym_table;
};

class InterfaceDecl : public Decl 
{
  protected:
    List<Decl*> *members;

  public:
    InterfaceDecl(Identifier *name, List<Decl*> *members);
    void CheckStatements();
    void CheckDeclError();
    List<Decl*> *GetMembers() { return members; }
    Hashtable<Decl*> *GetSymTable() { return sym_table; }
    Hashtable<Decl*> *sym_table;
};

class FnDecl : public Decl 
{
  protected:
    List<VarDecl*> *formals;
    Type *returnType;
    StmtBlock *body;
    
  public:
    FnDecl(Identifier *name, Type *returnType, List<VarDecl*> *formals);
    void SetFunctionBody(StmtBlock *b);
    void CheckStatements();
    void CheckDeclError();
    Type *GetReturnType() { return returnType; }
    List<VarDecl*> *GetFormals() { return formals; }
    char *GetTypeName() { return returnType->GetTypeName(); }
    bool HasSameTypeSig(FnDecl *fd);
    Hashtable<Decl*> *GetSymTable() { return sym_table; }
    Hashtable<Decl*> *sym_table;
};


#endif
