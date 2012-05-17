/* File: ast_expr.h
* ----------------
* The Expr class and its subclasses are used to represent
* expressions in the parse tree. For each expression in the
* language (add, call, New, etc.) there is a corresponding
* node class for that construct.
*
* pp4: You will need to extend the Expr classes to implement
* code generation for expressions.
*/


#ifndef _H_ast_expr
#define _H_ast_expr

#include <string>

#include "ast.h"
#include "ast_stmt.h"
#include "ast_type.h"
#include "list.h"

class FnDecl;

class Location;

class Expr : public Stmt
{
  protected:
    Type *type;

  public:
    Expr(yyltype loc) : Stmt(loc) {}
    Expr() : Stmt() {}
    virtual Type *GetType() { return type; }
    virtual const char *GetTypeName() { if (type) return type->GetTypeName(); else return NULL;}

    virtual Expr *GetBase() { return NULL; }
    virtual Identifier *GetField() { return NULL; }
    virtual bool HasBase();

    virtual Location *StoreEmit() { return NULL; }
};

/* This node type is used for those places where an expression is optional.
* We could use a NULL pointer, but then it adds a lot of checking for
* NULL. By using a valid, but no-op, node, we save that trouble */
class EmptyExpr : public Expr
{
};

class IntConstant : public Expr
{
  protected:
    int value;

  public:
    IntConstant(yyltype loc, int val);
    Location *Emit();
};

class DoubleConstant : public Expr
{
  protected:
    double value;
    
  public:
    DoubleConstant(yyltype loc, double val);
};

class BoolConstant : public Expr
{
  protected:
    bool value;
    
  public:
    BoolConstant(yyltype loc, bool val);
    Location *Emit();
};

class StringConstant : public Expr
{
  protected:
    char *value;
    
  public:
    StringConstant(yyltype loc, const char *val);
    Location *Emit();
};

class NullConstant: public Expr
{
  public:
    NullConstant(yyltype loc);
    Location *Emit();
};

class Operator : public Node
{
  protected:
    char tokenString[4];
    
  public:
    Operator(yyltype loc, const char *tok);
    friend ostream &operator<<(ostream &out, Operator *op) { if (op) return out << op->tokenString; else return out; }
    const char *GetToken() { return tokenString; }
    void SetToken(const char *tok);
 };
 
class CompoundExpr : public Expr
{
  protected:
    Operator *op;
    Expr *left, *right; // left will be NULL if unary
    
  public:
    CompoundExpr(Expr *lhs, Operator *op, Expr *rhs); // for binary
    CompoundExpr(Operator *op, Expr *rhs); // for unary

    Operator *GetOp() { return op; }
};

class ArithmeticExpr : public CompoundExpr
{
  public:
    ArithmeticExpr(Expr *lhs, Operator *op, Expr *rhs) : CompoundExpr(lhs,op,rhs) {}
    ArithmeticExpr(Operator *op, Expr *rhs) : CompoundExpr(op,rhs) {}
    void CheckStatements();
    Type *GetType() { return right->GetType(); }
    const char *GetTypeName() { return right->GetTypeName(); }

    Location *Emit();
};

class RelationalExpr : public CompoundExpr
{
  public:
    RelationalExpr(Expr *lhs, Operator *op, Expr *rhs) : CompoundExpr(lhs,op,rhs) {}
    void CheckStatements();
    Type *GetType() { return Type::boolType; }
    const char *GetTypeName() { return "bool"; }

    Location *Emit();
};

class EqualityExpr : public CompoundExpr
{
  public:
    EqualityExpr(Expr *lhs, Operator *op, Expr *rhs) : CompoundExpr(lhs,op,rhs) {}
    void CheckStatements();
    Type *GetType() { return Type::boolType; }
    const char *GetTypeName() { return "bool"; }

    Location *Emit();
};

class LogicalExpr : public CompoundExpr
{
  public:
    LogicalExpr(Expr *lhs, Operator *op, Expr *rhs) : CompoundExpr(lhs,op,rhs) {}
    LogicalExpr(Operator *op, Expr *rhs) : CompoundExpr(op,rhs) {}
    void CheckStatements();
    Type *GetType() { return Type::boolType; }
    const char *GetTypeName() { return "bool"; }

    Location *Emit();
};

class AssignExpr : public CompoundExpr
{
  public:
    AssignExpr(Expr *lhs, Operator *op, Expr *rhs) : CompoundExpr(lhs,op,rhs) {}
    void CheckStatements();
    Type *GetType() { return left->GetType(); }
    const char *GetTypeName() { return left->GetTypeName(); }

    Location *Emit();

};

class LValue : public Expr
{
  public:
    LValue(yyltype loc) : Expr(loc) {}
};

class This : public Expr
{
  public:
    This(yyltype loc) : Expr(loc) {}
    void CheckStatements();

    Location *Emit();
};

class ArrayAccess : public LValue
{
  protected:
    Expr *base, *subscript;
    
  public:
    ArrayAccess(yyltype loc, Expr *base, Expr *subscript);
    void CheckStatements();
    Type *GetType();
    const char *GetTypeName();
    Expr *GetBase() { return base; }

    Location *Emit();
    Location *StoreEmit();

};

/* Note that field access is used both for qualified names
* base.field and just field without qualification. We don't
* know for sure whether there is an implicit "this." in
* front until later on, so we use one node type for either
* and sort it out later. */
class FieldAccess : public LValue
{
  protected:
    Expr *base; // will be NULL if no explicit base
    Identifier *field;
    Type *type; // Expr::type is protected and thus not inherited here
    
  public:
    FieldAccess(Expr *base, Identifier *field); // ok to pass NULL base
    void CheckStatements(); // its type is decided here
    Identifier *GetField() { return field; }
    Type *GetType() { return type; }
    const char *GetTypeName() { if (type) return type->GetTypeName(); else return NULL; }
    Expr *GetBase() { return base; }

    Location *Emit();
    Location *LoadField(Location *base_loc, ClassDecl *classdecl, FnDecl *fndecl);
    Location *StoreEmit();
    Location *StoreField(Location *base_loc, ClassDecl *classdecl, FnDecl *fndecl);
};

/* Like field access, call is used both for qualified base.field()
* and unqualified field(). We won't figure out until later
* whether we need implicit "this." so we use one node type for either
* and sort it out later. */
class Call : public Expr
{
  protected:
    Expr *base; // will be NULL if no explicit base
    Identifier *field;
    List<Expr*> *actuals;
    
  public:
    Call(yyltype loc, Expr *base, Identifier *field, List<Expr*> *args);
    void CheckArguments(FnDecl *fndecl); // check arguments against formal parameters
    void CheckStatements(); // its type is decided here
    Type *GetType() { return type; }
    const char *GetTypeName() { if (type) return type->GetTypeName(); else return NULL; }

    Location *Emit();
    int PushArguments(List<Expr*> *args);
    Location *RuntimeCall(Location *base_loc, ClassDecl *classdecl, FnDecl *fndecl);
};

class NewExpr : public Expr
{
  protected:
    NamedType *cType;
    
  public:
    NewExpr(yyltype loc, NamedType *clsType);
    void CheckStatements();
    Type *GetType() { return cType; }
    const char *GetTypeName() { if (cType) return cType->GetTypeName(); else return NULL;  }

    Location *Emit();
};

class NewArrayExpr : public Expr
{
  protected:
    Expr *size;
    Type *elemType;
    
  public:
    NewArrayExpr(yyltype loc, Expr *sizeExpr, Type *elemType);
    void CheckStatements();
    const char *GetTypeName();

    Location *Emit();
};

class ReadIntegerExpr : public Expr
{
  public:
    ReadIntegerExpr(yyltype loc);

    Location *Emit();
};

class ReadLineExpr : public Expr
{
  public:
    ReadLineExpr(yyltype loc);

    Location *Emit();
};


class PostfixExpr : public Expr
{
  protected:
    LValue *lvalue;
    Operator *optr;

  public:
    PostfixExpr(yyltype loc, LValue *lv, Operator *op);
    void CheckStatements();
    Type *GetType() { if (lvalue) return lvalue->GetType(); else return NULL; }
    const char *GetTypeName() { if (lvalue) return lvalue->GetTypeName(); else return NULL; }
    Operator *GetOp() { return optr; }
    Location *Emit();
};
    
#endif
