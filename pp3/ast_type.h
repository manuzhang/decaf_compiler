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

  public :
    static Type *intType, *doubleType, *boolType, *voidType,
                *nullType, *stringType, *errorType;

    Type(yyltype loc) : Node(loc) {}
    Type(const char *str);
    char *GetTypeName() { return typeName; }
    virtual bool HasSameType(Type *t);
    virtual void CheckTypeError() {}
};

class NamedType : public Type 
{
  protected:
    Identifier *id;
    
  public:
    NamedType(Identifier *i);
    Identifier *GetID() { return id; }
    bool HasSameType(Type *nt);
    void CheckSemantics();
    void CheckTypeError();
};

class ArrayType : public Type 
{
  protected:
    Type *elemType;

  public:
    ArrayType(yyltype loc, Type *elemType);
    Type *GetElemType() { return elemType; }
    bool HasSameType(Type *at);
    void CheckSemantics();
    void CheckTypeError();
};

#endif
