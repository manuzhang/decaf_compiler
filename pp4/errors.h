/**
 * File: errors.h
 * --------------
 * This file defines an error-reporting class with a set of already
 * implemented static methods for reporting the standard Decaf errors.
 * You should report all errors via this class so that your error
 * messages will have the same wording/spelling as ours and thus
 * diff can easily compare the two. If needed, you can add new
 * methods if you have some fancy error-reporting, but for the most
 * part, you will just use the class as given.
 */

#ifndef _errors_h_
#define _errors_h_

#include <string>
#include "location.h"
using namespace std;
class Type;
class Identifier;
class Expr;
class BreakStmt;
class ReturnStmt;
class This;
class Decl;
class Operator;

/**
 * General notes on using this class
 * ----------------------------------
 * Each of the methods in thie class matches one of the standard Decaf
 * errors and reports a specific problem such as an unterminated string,
 * type mismatch, declaration conflict, etc. You will call these methods
 * to report problems encountered during the analysis phases. All methods
 * on this class are static, thus you can invoke methods directly via
 * the class name, e.g.
 *
 *    if (missingEnd) { 
 *       ReportError::UntermString(&yylloc, str);
 *    }
 *
 * For some methods, the first argument is the pointer to the location
 * structure that identifies where the problem is (usually this is the
 * location of the offending token). You can pass NULL for the argument
 * if there is no appropriate position to point out. For other methods,
 * location is accessed by messaging the node in error which is passed
 * as an argument. You cannot pass NULL for these arguments.
 */

typedef enum {LookingForType, LookingForClass, LookingForInterface, LookingForVariable, LookingForFunction} reasonT;

class ReportError {
 public:

  // Errors used by scanner
  static void UntermComment(); 
  static void LongIdentifier(yyltype *loc, const char *ident);
  static void UntermString(yyltype *loc, const char *str);
  static void UnrecogChar(yyltype *loc, char ch);

  
  // Errors used by semantic analyzer for declarations
  static void DeclConflict(Decl *newDecl, Decl *prevDecl);
  static void OverrideMismatch(Decl *fnDecl);
  static void InterfaceNotImplemented(Decl *classDecl, Type *intfType);


  // Errors used by semantic analyzer for identifiers
  static void IdentifierNotDeclared(Identifier *ident, reasonT whyNeeded);

  
  // Errors used by semantic analyzer for expressions
  static void IncompatibleOperand(Operator *op, Type *rhs); // unary
  static void IncompatibleOperands(Operator *op, Type *lhs, Type *rhs); // binary
  static void ThisOutsideClassScope(This *th);

  
 // Errors used by semantic analyzer for array acesss & NewArray
  static void BracketsOnNonArray(Expr *baseExpr); 
  static void SubscriptNotInteger(Expr *subscriptExpr);
  static void NewArraySizeNotInteger(Expr *sizeExpr);


  // Errors used by semantic analyzer for function/method calls
  static void NumArgsMismatch(Identifier *fnIdentifier, int numExpected, int numGiven);
  static void ArgMismatch(Expr *arg, int argIndex, Type *given, Type *expected);
  static void PrintArgMismatch(Expr *arg, int argIndex, Type *given);


  // Errors used by semantic analyzer for field access
  static void FieldNotFoundInBase(Identifier *field, Type *base);
  static void InaccessibleField(Identifier *field, Type *base);


  // Errors used by semantic analyzer for control structures
  static void TestNotBoolean(Expr *testExpr);
  static void ReturnMismatch(ReturnStmt *rStmt, Type *given, Type *expected);
  static void BreakOutsideLoop(BreakStmt *bStmt);


    // Errors used by code-generator/linker
  static void NoMainFound();

  // Generic method to report a printf-style error message
  static void Formatted(yyltype *loc, const char *format, ...);


  // Returns number of error messages printed
  static int NumErrors() { return numErrors; }
  
 private:
  static void UnderlineErrorInLine(const char *line, yyltype *pos);
  static void OutputError(yyltype *loc, string msg);
  static int numErrors;
};
  
// Wording to use for runtime error messages
static const char * const err_arr_out_of_bounds = "Decaf runtime error: Array subscript out of bounds\\n";
static const char * const err_arr_bad_size = "Decaf runtime error: Array size is <= 0\\n";
 
#endif
