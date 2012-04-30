/* File: ast_type.h
 * ----------------
 * In our parse tree, Type nodes are used to represent and
 * store type information. The base Type class is used
 * for built-in types, the NamedType for classes and interfaces,
 * and the ArrayType for arrays of other types.  
 */
 
#ifndef _H_ast_type
#define _H_ast_type

#include <string>

#include "ast.h"
#include "list.h"


class Type : public Node 
{
  protected:
    char *typeName;
    virtual void print(ostream &out) const { out << typeName;}

  public :
    static Type *intType, *doubleType, *boolType, *voidType,
                *nullType, *stringType, *errorType;

    Type(yyltype loc) : Node(loc) {}
    Type(const char *str);
    virtual char *GetTypeName() { return typeName; }
    virtual bool HasSameType(Type *t);
    virtual void CheckTypeError() {}
    friend ostream& operator<<(ostream &out, Type *type) { type->print(out); return out; }
};

class NamedType : public Type 
{
  protected:
    Identifier *id;
    virtual void print(ostream &out) const { out << id; }
    
  public:
    NamedType(Identifier *i);
    Identifier *GetID() { return id; }
    bool HasSameType(Type *nt);
    char *GetTypeName() { return id->GetName(); }
    void CheckSemantics();
    void CheckTypeError();

};

class ArrayType : public Type 
{
  protected:
    Type *elemType;
    virtual void print(ostream &out) const { out << elemType; }
  public:
    ArrayType(yyltype loc, Type *elemType);
    Type *GetElemType() { return elemType; }
    bool HasSameType(Type *at);
    char *GetTypeName() { return elemType->GetTypeName(); }
    void CheckSemantics();
    void CheckTypeError();
};

#endif
