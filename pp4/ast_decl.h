/* File: ast_decl.h
 * ----------------
 * In our parse tree, Decl nodes are used to represent and
 * manage declarations. There are 4 subclasses of the base class,
 * specialized for declarations of variables, functions, classes,
 * and interfaces.
 *
 * pp4: You will need to extend the Decl classes to implement
 * code generation for declarations.
 */

#ifndef _H_ast_decl
#define _H_ast_decl

#include <string>

#include "ast.h"
#include "ast_type.h"
#include "hashtable.h"
#include "list.h"

using std::string;

class Identifier;
class StmtBlock;

class BeginFunc;
class Location;

class Decl : public Node 
{
 protected:
  Identifier *id;
  
 public:
  Decl(Identifier *name);
  Identifier *GetID() { return id; }
  friend ostream& operator<<(ostream &out, Decl *decl) { if (decl) return out << decl->id; else return out; }
  virtual const char *GetTypeName() { return NULL; }
  virtual Type *GetType() { return NULL; }

  virtual void SetLabels() {}
};

class VarDecl : public Decl 
{
 protected:
  Type *type;


 public:
  VarDecl(Identifier *name, Type *type);
  Type *GetType() { return type; }
  const char *GetTypeName() { if (type) return type->GetTypeName(); else return NULL; }
  bool HasSameTypeSig(VarDecl *vd);
  void CheckDeclError();

  Location *Emit();
};


class ClassDecl : public Decl 
{
 protected:
  List<Decl*> *members;
  NamedType *extends;
  List<NamedType*> *implements;
  Hashtable<Decl*> *sym_table;

  List<const char *> *methodlabels;
  List<const char *> *fieldlabels;
  int instanceOffset;

 public:
  ClassDecl(Identifier *name, NamedType *extends, 
	    List<NamedType*> *implements, List<Decl*> *members);
  List<Decl*> *GetMembers() { return members; }
  NamedType *GetExtends() { return extends; }
  List<NamedType*> *GetImplements() { return implements; }
  void CheckStatements();
  void CheckDeclError();
  bool IsCompatibleWith(Decl *decl);
  Hashtable<Decl*> *GetSymTable() { return sym_table; }

  List<const char *> *GetMethodLabels() { return methodlabels; }
  List<const char *> *GetFieldLabels() { return fieldlabels; }
  void SetLabels();
  Location *Emit();
  int UpdateInstanceOffset();
  int GetInstanceOffset();
 };

class InterfaceDecl : public Decl 
{
 protected:
  List<Decl*> *members;
  Hashtable<Decl*> *sym_table;

 public:
  InterfaceDecl(Identifier *name, List<Decl*> *members);
  void CheckDeclError();
  List<Decl*> *GetMembers() { return members; }
  Hashtable<Decl*> *GetSymTable() { return sym_table; }

};

class FnDecl : public Decl 
{
 protected:
  List<VarDecl*> *formals;
  Type *returnType;
  StmtBlock *body;
  Hashtable<Decl*> *sym_table;

  BeginFunc *beginFunc;
  int frameSize;
  int localOffset;
  int paramOffset;
  string label;

 public:
  FnDecl(Identifier *name, Type *returnType, List<VarDecl*> *formals);
  void SetFunctionBody(StmtBlock *b);
  void CheckStatements();
  void CheckDeclError();
  Type *GetType() { return returnType; }
  List<VarDecl*> *GetFormals() { return formals; }
  const char *GetTypeName() { if (returnType) return returnType->GetTypeName(); else return NULL; }
  bool HasSameTypeSig(FnDecl *fd);
  Hashtable<Decl*> *GetSymTable() { return sym_table; }

  BeginFunc *GetBeginFunc() { return beginFunc; }
  int GetFrameSize() { return frameSize; }
  Location *Emit();
  const char *GetLabel() { return label.c_str(); }
  int UpdateFrame(); // update frame and localOffset by Codegenrator::VarSize, return the previous localOffset
  void SetLabels();
};


#endif
