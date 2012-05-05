/* File: ast_type.h
 * ----------------
 * In our parse tree, Type nodes are used to represent and
 * store type information. The base Type class is used
 * for built-in types, the NamedType for classes and interfaces,
 * and the ArrayType for arrays of other types.  
 *
 * pp4: You will need to extend the Type classes to implement
 * code generation for types.
 */
 
#ifndef _H_ast_type
#define _H_ast_type

#include <string.h>

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
    virtual Type *GetElemType() { return this; }
    virtual const char *GetTypeName() { return typeName; }
    virtual bool HasSameType(Type *t);
    virtual void CheckTypeError() {}
    friend ostream& operator<<(ostream &out, Type *type) { if (type) type->print(out); return out; }
};

class NamedType : public Type 
{
  protected:
    Identifier *id;
    virtual void print(ostream &out) const { out << id; }
    
  public:
    NamedType(Identifier *i);
    Identifier *GetID() { return id; }
    Type *GetElemType() { return this; }
    const char *GetTypeName() { if (id) return id->GetName(); else return NULL; }
    bool HasSameType(Type *nt);
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
    const char *GetTypeName();
    bool HasSameType(Type *at);
    void CheckTypeError();
};

#endif
