/* File: ast_type.cc
 * -----------------
 * Implementation of type node classes.
 */

#include <string.h>

#include <typeinfo>

#include "ast_type.h"
#include "ast_decl.h"
#include "ast_stmt.h"
#include "errors.h"

/* Class constants
 * ---------------
 * These are public constants for the built-in base types (int, double, etc.)
 * They can be accessed with the syntax Type::intType. This allows you to
 * directly access them and share the built-in types where needed rather that
 * creates lots of copies.
 */

Type *Type::intType    = new Type("int");
Type *Type::doubleType = new Type("double");
Type *Type::voidType   = new Type("void");
Type *Type::boolType   = new Type("bool");
Type *Type::nullType   = new Type("null");
Type *Type::stringType = new Type("string");
Type *Type::errorType  = new Type("error"); 

Type::Type(const char *n) {
    Assert(n);
    typeName = strdup(n);
}

bool Type::HasSameType(Type *t) {
  char *typeName2 = t->GetTypeName();
  if (typeName && typeName2)
    return !strcmp(typeName, typeName2);
  else
    return false;
}

NamedType::NamedType(Identifier *i) : Type(*i->GetLocation()) {
    Assert(i != NULL);
    (id=i)->SetParent(this);
} 

bool NamedType::HasSameType(Type *nt) {
  if (typeid(*nt) == typeid(NamedType))
    return !strcmp(id->GetName(), dynamic_cast<NamedType*>(nt)->GetID()->GetName());
  else
    return false;
}

void NamedType::CheckSemantics() {
  CheckTypeError();
}

void NamedType::CheckTypeError() {
  if (Program::sym_table)
    {
      char *name = id->GetName();
      if (Program::sym_table->Lookup(name) == NULL)
        ReportError::IdentifierNotDeclared(id, LookingForType);
    }
}

ArrayType::ArrayType(yyltype loc, Type *et) : Type(loc) {
    Assert(et != NULL);
    (elemType=et)->SetParent(this);
}

bool ArrayType::HasSameType(Type *at) {
  if (typeid(*at) == typeid(ArrayType))
    return elemType->HasSameType(dynamic_cast<ArrayType*>(at)->GetElemType());
  else
    return false;
}

void ArrayType::CheckSemantics() {
  CheckTypeError();
}

void ArrayType::CheckTypeError() {
  this->elemType->CheckTypeError();
}
