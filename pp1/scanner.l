/* File:  scanner.l
 * ----------------
 * Lex inupt file to generate the scanner for the compiler.
 */

%{

/* The text within this first region delimited by %{ and %} is assumed to
 * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
 * of the definitions of the yylex() function. Add other header file inclusions
 * or C++ variable declarations/prototypes that are needed by your code here.
 */

#include <string.h>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"

/* Global variable: yylval
 * -----------------------
 * This global variable is how we get attribute information about the token
 * just scanned to the client. The scanner sets the global variable
 * appropriately and since it's global the client can just read it.  In the
 * future, this variable will be declared for us in the y.tab.c file
 * produced by Yacc, but for now, we declare it manually.
 */
YYSTYPE yylval;  // manually declared for pp1, later Yacc provides

/* Global variable: yylloc
 * -----------------------
 * This global variable is how we get position information about the token
 * just scanned to the client. (Operates similarly to yylval above)
 */
struct yyltype yylloc; // manually dclared for pp1, later Yacc provides

/* Macro: YY_USER_ACTION 
 * ---------------------
 * This flex built-in macro can be defined to provide an action which is
 * always executed prior to any matched rule's action. Basically, it is
 * a way of having a piece of code common to all actions factored out to
 * this routine.  We already defined it for you and left the empty
 * function DoBeforeEachAction ready for your use as needed. It will
 * be called once for each pattern scanned from the file, before
 * executing its action.
 */
static void DoBeforeEachAction(); 
#define YY_USER_ACTION DoBeforeEachAction();

int lineno = 1;
int colno = 1;
%}

 /* The section before the first %% is the Definitions section of the lex
  * input file. Here is where you set options for the scanner, define lex
  * states, and can set up definitions to give names to regular expressions
  * as a simple substitution mechanism that allows for more readable
  * entries in the Rules section later. 
  */
whitespace         [ \t\r\n]
punctuation        [!\;,\.\[\]\{\}\(\)]
arithmetic         [\+\-\*\/%]
relational         [<>=]
operator           {arithmetic}|{relational} 
sign               (+|-)?
decimal            [0-9]+
hexadecimal        (0x|0X)[0-9a-fA-F]+
chars              \"[^\"\n]*\"
boolean            true|false   
integer            {sign}({decimal}|{hexadecimal})   
float              {sign}{decimal}.{decimal}?(E|e){sign}{decimal}

%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 

 /* skip over white space */
{whitespace}           ;

 /* recognize all keywords and return the correct token from scanner.h */
void                   { return T_Void; }
int                    { return T_Int; }
double                 { return T_Double; }
bool                   { return T_Bool; }
string                 { return T_String; }
class                  { return T_Class; }
interface              { return T_Interface; }
null                   { return T_Null; }
this                   { return T_This; }
extends                { return T_Extends; }
implements             { return T_Implements; }
for                    { return T_For; }
while                  { return T_While; }
if                     { return T_If; }
else                   { return T_Else; }
return                 { return T_Return; }
break                  { return T_Break; }
new                    { return T_New; }
NewArray               { return T_NewArray; }
Print                  { return T_Print; }
ReadInteger            { return T_ReadInteger; }
ReadLine               { return T_ReadLine; }

 
 /* recognize punctuation and single-char operators 
  * and return the ASCII value as the token 
  */
{punctuation}|
{operator}             { return yytext[0] - '\0'; }


 /* recognize two-character operators and return the correct token */
<=                     { return T_LessEqual; }
>=                     { return T_GreaterEqual; }
==                     { return T_Equal; }
!=                     { return T_NotEqual; }
\[\]                   { return T_Dims; }
&&                     { return T_And; }
\|\|                   { return T_Or; }

 /* recognize int, double, bool and string constants,
  * return the correct token
  * and set appropriate filed of yylval 
  */
{chars}                  { stringConstant = yytext;
                           return T_StringConstant;
                         }
{boolean}                { if (strcmp("true", yytext) == 0)
                               yylval.boolConstant = true;
                           else
			       yylval.boolConstant = false;
                           return T_BoolConstant;
                         }
{integer}                { yylval.integerConstant = atoi(yytext); return T_IntConstant; }
{float}                  { yylval.doubleConstant = atof(yytext); return T_DoubleConstant; }

 /* recognize identifiers, 
  * return the correct token and set appropriate fields of yylval 
  */
[a-zA-Z][a-zA-Z0-9_]*   { if (yyleng > MaxIdentLen)
                             {
			       ReportError::LongIdentifier(&yylloc, yytext);
			     }
			  else 
			     { 
			       strcpy(yylval.identifier, yytext);
                               return T_Identifier;
			     }
		        }

 /* consume single-line comment */
(\/\/.*\n)|
(\/\*.*\*\/)            ;

 /* consume multi-line comments 
  * report unterminated comment
  */
\/\*(.|[\n\r])*?\*\/    ;
\/\*(.|[\n\r])*?<<EOF>> { UntermComment(); }

 /* report lexical error for improper strings 
  * and invalid characters
  */
\"[^\"]*\n              { UntermString(&loc, yytext); }

.                       { UnrecogChar(&loc, yytext[0]); }

%%
/* The closing %% above marks the end of the Rules section and the beginning
 * of the User Subroutines section. All text from here to the end of the
 * file is copied verbatim to the end of the generated lex.yy.c file.
 * This section is where you put definitions of helper functions.
 */


/* Function: InitScanner
 * ---------------------
 * This function will be called before any calls to yylex().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yy_flex_debug that controls whether flex prints debugging information
 * about each token and what rule was matched. If set to false, no information
 * is printed. Setting it to true will give you a running trail that might
 * be helpful when debugging your scanner. Please be sure the variable is
 * set to false when submitting your final version.
 */
void InitScanner()
{
    PrintDebug("lex", "Initializing scanner");
    yy_flex_debug = true;
}


/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
  yylloc.first_line = lineno;
  int i;
  for (i = 0; i < yyleng; i++)
    if (yytext[i] == '\n')
       lineno++;
  yylloc.last_line = lineno;

  yylloc.fitst_column = colno;
  colno = colno + yyleng;
  yylloc.last_column = colno;
}
