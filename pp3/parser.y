/* File: parser.y
 * --------------
 * Bison input file to generate the parser for the compiler.
 */

%{

#include "scanner.h" // for yylex
#include "parser.h"
#include "errors.h"

void yyerror(const char *msg); // standard error-handling routine

%}

 
/* yylval 
 * ------
 */
%union {
    int integerConstant;
    bool boolConstant;
    char *stringConstant;
    double doubleConstant;
    char identifier[MaxIdentLen+1]; // +1 for terminating null
    Decl *decl;
    List<Decl*> *declList;
    Type *type;
    NamedType *cType;
    List<NamedType*> *cTypeList;
    FnDecl *fDecl;
    VarDecl *var;
    List<VarDecl*> *varList;
    Expr *expr;
    List<Expr*> *exprList;
    Stmt *stmt;
    List<Stmt*> *stmtList;
    LValue *lvalue;
}


/* Tokens
 * ------
 */
%token   T_Void T_Bool T_Int T_Double T_String T_Class 
%token   T_LessEqual T_GreaterEqual T_Equal T_NotEqual T_Dims
%token   T_And T_Or T_Null T_Extends T_This T_Interface T_Implements
%token   T_While T_For T_If T_Else T_Return T_Break
%token   T_New T_NewArray T_Print T_ReadInteger T_ReadLine

%token   <identifier> T_Identifier
%token   <stringConstant> T_StringConstant 
%token   <integerConstant> T_IntConstant
%token   <doubleConstant> T_DoubleConstant
%token   <boolConstant> T_BoolConstant


/* Non-terminal types
 * ------------------
 */
%type <expr>      Constant Expr Call OptExpr
%type <lvalue>    LValue
%type <type>      Type 
%type <cType>     OptExt 
%type <cTypeList> OptImpl ImpList
%type <decl>      ClassDecl Decl Field IntfDecl
%type <fDecl>     FnDecl FnHeader
%type <declList>  FieldList DeclList IntfList
%type <var>       Variable VarDecl
%type <varList>   Formals FormalList VarDecls
%type <exprList>  Actuals ExprList
%type <stmt>      Stmt StmtBlock OptElse
%type <stmtList>  StmtList

  
/* Precedence and associativity
 * ----------------------------
 * Here we establish the precedence and associativity of the
 * tokens as needed to resolve conflicts and remove ambiguity.
 */
%left     '='
%left      T_Or
%left      T_And 
%nonassoc  T_Equal T_NotEqual
%nonassoc  '<' '>' T_LessEqual T_GreaterEqual
%left      '+' '-'
%left      '*' '/' '%'  
%nonassoc  T_UnaryMinus '!' 
%nonassoc  '.' '['
%nonassoc  T_Lower_Than_Else
%nonassoc  T_Else

%%
/* Rules
 * -----
	 
 */
Program   :    DeclList            { 
                                      @1; 
                                      Program *program = new Program($1);
                                      // if no errors, advance to next phase
                                      if (ReportError::NumErrors() == 0) 
                                          program->Check(); 
                                    }
          ;


DeclList  :    DeclList Decl        { ($$=$1)->Append($2); }
          |    Decl                 { ($$ = new List<Decl*>)->Append($1); }
          ;

Decl      :    ClassDecl
          |    FnDecl               { $$=$1; }
          |    VarDecl              { $$=$1; }
          |    IntfDecl 
          ;

VarDecl   :    Variable ';' 
          ;
 
Variable  :    Type T_Identifier    { $$ = new VarDecl(new Identifier(@2, $2), $1); }
          ;

Type      :    T_Int                { $$ = Type::intType; }
          |    T_Bool               { $$ = Type::boolType; }
          |    T_String             { $$ = Type::stringType; }
          |    T_Double             { $$ = Type::doubleType; }
          |    T_Identifier         { $$ = new NamedType(new Identifier(@1,$1)); }
          |    Type T_Dims          { $$ = new ArrayType(Join(@1, @2), $1); }
          ;

IntfDecl  :    T_Interface T_Identifier '{' IntfList '}' 
                                    { $$ = new InterfaceDecl(new Identifier(@2, $2), $4); }
          ; 

IntfList  :    IntfList FnHeader ';'
                                    { ($$=$1)->Append($2); }
          |    /* empty */          { $$ = new List<Decl*>(); }
          ;

ClassDecl :    T_Class T_Identifier OptExt OptImpl '{' FieldList '}'
                                    { $$ = new ClassDecl(new Identifier(@2, $2), $3, $4, $6); }
          ; 
                
OptExt    :    T_Extends T_Identifier    
                                    { $$ = new NamedType(new Identifier(@2, $2)); }
          |    /* empty */          { $$ = NULL; }
          ;

OptImpl   :    T_Implements ImpList 
                                    { $$ = $2; }
          |    /* empty */          { $$ = new List<NamedType*>; }
          ;

ImpList   :    ImpList ',' T_Identifier    
                                    { ($$=$1)->Append(new NamedType(new Identifier(@3, $3))); }
          |    T_Identifier         { ($$=new List<NamedType*>)->Append(new NamedType(new Identifier(@1, $1))); }
          ;

FieldList :    FieldList Field      { ($$=$1)->Append($2); }
          |    /* empty */          { $$ = new List<Decl*>(); }
          ;

Field     :    VarDecl              { $$ = $1; }
          |    FnDecl               { $$ = $1; }
          ;
          

FnHeader  :    Type T_Identifier '(' Formals ')'  
                                    { $$ = new FnDecl(new Identifier(@2, $2), $1, $4); }
          |    T_Void T_Identifier '(' Formals ')' 
                                    { $$ = new FnDecl(new Identifier(@2, $2), Type::voidType, $4); }
          ;

Formals   :    FormalList           { $$ = $1; }
          |    /* empty */          { $$ = new List<VarDecl*>; }
          ;

FormalList:    FormalList ',' Variable  
                                    { ($$=$1)->Append($3); }
          |    Variable             { ($$ = new List<VarDecl*>)->Append($1); }
          ;

FnDecl    :    FnHeader StmtBlock   { ($$=$1)->SetFunctionBody($2); }
          ;

StmtBlock :    '{' VarDecls StmtList '}' 
                                    { $$ = new StmtBlock($2, $3); }
          ;

VarDecls  :    VarDecls VarDecl     { ($$=$1)->Append($2); }
          |    /* empty */          { $$ = new List<VarDecl*>; }
          ;

StmtList  :    Stmt StmtList        { $$ = $2; $$->InsertAt($1, 0); }
          |    /* empty */          { $$ = new List<Stmt*>; }
          ;

Stmt      :    OptExpr ';'          { $$ = $1; }
          |    StmtBlock
          |    T_If '(' Expr ')' Stmt OptElse 
                                    { $$ = new IfStmt($3, $5, $6); }
          |    T_While '(' Expr ')' Stmt 
                                    { $$ = new WhileStmt($3, $5); }
          |    T_For '(' OptExpr ';' Expr ';' OptExpr ')' Stmt 
                                    { $$ = new ForStmt($3, $5, $7, $9); } 
          |    T_Return Expr ';'      
                                    { $$ = new ReturnStmt(@2, $2); }
          |    T_Return ';'      
                                    { $$ = new ReturnStmt(@1, new EmptyExpr()); }
          |    T_Print '(' ExprList ')' ';'  
                                    { $$ = new PrintStmt($3); }
          |    T_Break ';'          { $$ = new BreakStmt(@1); }
          ;

LValue    :    T_Identifier          { $$ = new FieldAccess(NULL, new Identifier(@1, $1)); }
          |    Expr '.' T_Identifier { $$ = new FieldAccess($1, new Identifier(@3, $3)); } 
          |    Expr '[' Expr ']'     { $$ = new ArrayAccess(Join(@1, @4), $1, $3); }
          ;

Call      :    T_Identifier '(' Actuals ')' 
                                    { $$ = new Call(Join(@1,@4), NULL, new Identifier(@1,$1), $3); }
          |    Expr '.' T_Identifier '(' Actuals ')' 
                                    { $$ = new Call(Join(@1,@6), $1, new Identifier(@3,$3), $5); }
          ;

OptExpr   :    Expr                 { $$ = $1; }
          |    /* empty */          { $$ = new EmptyExpr(); }
          ;

Expr      :    LValue               { $$ = $1; }
          |    Call
          |    Constant
          |    LValue '=' Expr      { $$ = new AssignExpr($1, new Operator(@2,"="), $3); }
          |    Expr '+' Expr        { $$ = new ArithmeticExpr($1, new Operator(@2, "+"), $3); }
          |    Expr '-' Expr        { $$ = new ArithmeticExpr($1, new Operator(@2, "-"), $3); }
          |    Expr '/' Expr        { $$ = new ArithmeticExpr($1, new Operator(@2,"/"), $3); }
          |    Expr '*' Expr        { $$ = new ArithmeticExpr($1, new Operator(@2,"*"), $3); }
          |    Expr '%' Expr        { $$ = new ArithmeticExpr($1, new Operator(@2,"%"), $3); }
          |    Expr T_Equal Expr    { $$ = new EqualityExpr($1, new Operator(@2,"=="), $3); }
          |    Expr T_NotEqual Expr { $$ = new EqualityExpr($1, new Operator(@2,"!="), $3); }
          |    Expr '<' Expr        { $$ = new RelationalExpr($1, new Operator(@2,"<"), $3); }
          |    Expr '>' Expr        { $$ = new RelationalExpr($1, new Operator(@2,">"), $3); }
          |    Expr T_LessEqual Expr 
                                    { $$ = new RelationalExpr($1, new Operator(@2,"<="), $3); }
          |    Expr T_GreaterEqual Expr 
                                    { $$ = new RelationalExpr($1, new Operator(@2,">="), $3); }
          |    Expr T_And Expr      { $$ = new LogicalExpr($1, new Operator(@2,"&&"), $3); }
          |    Expr T_Or Expr       { $$ = new LogicalExpr($1, new Operator(@2,"||"), $3); }
          |    '(' Expr ')'         { $$ = $2; }
          |    '-' Expr  %prec T_UnaryMinus 
                                    { $$ = new ArithmeticExpr(new Operator(@1,"-"), $2); }
          |    '!' Expr             { $$ = new LogicalExpr(new Operator(@1,"!"), $2); }
          |    T_ReadInteger '(' ')'   
                                    { $$ = new ReadIntegerExpr(Join(@1,@3)); }
          |    T_ReadLine '(' ')'   { $$ = new ReadLineExpr(Join(@1,@3)); }
          |    T_New T_Identifier
                                    { $$ = new NewExpr(Join(@1,@2),new NamedType(new Identifier(@2,$2))); }
          |    T_NewArray '(' Expr ',' Type ')' 
                                    { $$ = new NewArrayExpr(Join(@1,@6),$3, $5); }
          |    T_This               { $$ = new This(@1); }
          ;

Constant  :    T_IntConstant        { $$ = new IntConstant(@1,$1); }
          |    T_BoolConstant       { $$ = new BoolConstant(@1,$1); }
          |    T_DoubleConstant     { $$ = new DoubleConstant(@1,$1); }
          |    T_StringConstant     { $$ = new StringConstant(@1,$1); }
          |    T_Null               { $$ = new NullConstant(@1); }
          ;

Actuals   :    ExprList             { $$ = $1; }
          |    /* empty */          { $$ = new List<Expr*>; }
          ;

ExprList  :    ExprList ',' Expr    { ($$=$1)->Append($3); }
          |    Expr                 { ($$ = new List<Expr*>)->Append($1); }
          ;

OptElse   :    T_Else Stmt          { $$ = $2; }
          |    /* empty */   %prec T_Lower_Than_Else 
                                    { $$ = NULL; }
          ;

%%


/* Function: InitParser
 * --------------------
 * This function will be called before any calls to yyparse().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the parser (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yydebug that controls whether yacc prints debugging information about
 * parser actions (shift/reduce) and contents of state stack during parser.
 * If set to false, no information is printed. Setting it to true will give
 * you a running trail that might be helpful when debugging your parser.
 * Please be sure the variable is set to false when submitting your final
 * version.
 */
void InitParser()
{
   PrintDebug("parser", "Initializing parser");
   yydebug = false;
}
