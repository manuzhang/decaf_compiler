/**
 * File: ast.h
 * ----------- 
 * This file defines the abstract base class Node and the concrete 
 * Identifier and Error node subclasses that are used through the tree as 
 * leaf nodes. A parse tree is a hierarchical collection of ast nodes (or, 
 * more correctly, of instances of concrete subclassses such as VarDecl,
 * ForStmt, and AssignExpr).
 * 
 * Location: Each node maintains its lexical location (line and columns in 
 * file), that location can be NULL for those nodes that don't care/use 
 * locations. The location is typcially set by the node constructor.  The 
 * location is used to provide the context when reporting semantic errors.
 *
 * Parent: Each node has a pointer to its parent. For a Program node, the 
 * parent is NULL, for all other nodes it is the pointer to the node one level
 * up in the parse tree.  The parent is not set in the constructor (during a 
 * bottom-up parse we don't know the parent at the time of construction) but 
 * instead we wait until assigning the children into the parent node and then 
 * set up links in both directions. The parent link is typically not used 
 * during parsing, but is more important in later phases.
 *
 * Code generation: For pp4 you are adding "Emit" behavior to the ast
 * node classes. Your code generator should do an postorder walk on the
 * parse tree, and when visiting each node, emitting the necessary
 * instructions for that construct.

 */

#ifndef _H_ast
#define _H_ast

#include <stdlib.h>   // for NULL

#include <iostream>

#include "errors.h"
#include "hashtable.h"
#include "list.h"
#include "location.h"

class Decl;
class FnDecl;
class ClassDecl;
class Location;

class Node  {
 protected:
  yyltype *location;
  Node *parent;

 public:
  Node(yyltype loc);
  Node();
  virtual ~Node() {}
    
  yyltype *GetLocation()   { return location; }
  void SetParent(Node *p)  { parent = p; }
  Node *GetParent()        { return parent; }

  virtual Hashtable<Decl*> *GetSymTable() { return NULL; }

  virtual void CheckDeclError() {}
  virtual void CheckStatements() {}
  virtual Location *Emit() { return NULL; }

  // get enclosing function to backpatch the frame size
  FnDecl *GetEnclosFunc(Node *node);
  // for methods
  ClassDecl *GetEnclosClass(Node *node);
};
   

class Identifier : public Node 
{
 protected:
  char *name;
  Location *memLoc;

 public:
  Identifier(yyltype loc, const char *name);
  const char *GetName() { return name; }
  Decl *CheckIdDecl();
  Decl *CheckIdDecl(Hashtable<Decl*> *sym_table, const char *name);
  friend ostream& operator<<(ostream& out, Identifier *id) { if (id) return out << id->name; else return out;}

  Location *GetMemLoc() { return memLoc; }
  void SetMemLoc(Location *loc) { memLoc = loc; }
};


// This node class is designed to represent a portion of the tree that 
// encountered syntax errors during parsing. The partial completed tree
// is discarded along with the states being popped, and an instance of
// the Error class can stand in as the placeholder in the parse tree
// when your parser can continue after an error.
class Error : public Node
{
 public:
 Error() : Node() {}
};

#endif
