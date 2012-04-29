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
#include "list.h"
#include "hashtable.h"

class Type;
class NamedType;
class Identifier;
class Stmt;


class Decl : public Node 
{
  protected:
    Identifier *id;
  
  public:
    Decl(Identifier *name);
    Identifier *GetID() { return id; }
    friend ostream& operator<<(ostream &out, Decl *decl) { return out << decl->id; }
    virtual void CheckDeclError() = 0;
};

class VarDecl : public Decl 
{
  protected:
    Type *type;
    
  public:
    VarDecl(Identifier *name, Type *type);
    Type *GetType() { return type; }
    bool HasSameTypeSig(VarDecl *vd);
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
    void CheckDeclError();
    Hashtable<Decl*> *sym_table;
};

class InterfaceDecl : public Decl 
{
  protected:
    List<Decl*> *members;

  public:
    InterfaceDecl(Identifier *name, List<Decl*> *members);
    void CheckDeclError();
    List<Decl*> *GetMembers() { return members; }
    Hashtable<Decl*> *sym_table;
};

class FnDecl : public Decl 
{
  protected:
    List<VarDecl*> *formals;
    Type *returnType;
    Stmt *body;
    
  public:
    FnDecl(Identifier *name, Type *returnType, List<VarDecl*> *formals);
    void SetFunctionBody(Stmt *b);
    void CheckDeclError();
    Type *GetReturnType() { return returnType; }
    List<VarDecl*> *GetFormals() { return formals; }
    bool HasSameTypeSig(FnDecl *fd);
    Hashtable<Decl*> *sym_table;
};


#endif
