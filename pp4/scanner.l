/* File:  scanner.l
 * ----------------
 * Lex input file to generate the scanner
 */

%{

/* The text within this first region delimited by %{ and %} is assumed to
 * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
 * of the definitions of the yylex() function. Add other header file inclusions
 * or C++ variable declarations/prototypes that are needed by your code here.
 */

#include <string.h>
#include <ctype.h>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"
#include "parser.h" // for token codes, yylval
#include "list.h"

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

#define TAB_SIZE 8

int lineno, colno;
List<const char*> savedlines;
%}

 /* The section before the first %% is the Definitions section of the lex
  * input file. Here is where you set options for the scanner, define lex
  * states, and can set up definitions to give names to regular expressions
  * as a simple substitution mechanism that allows for more readable
  * entries in the Rules section later. 
  */
PUNCTUATION        ([!:;,.[\]{}()])
ARITHMETIC         ([-+/*%])
RELATIONAL         ([<>=])
OPERATOR           ({ARITHMETIC}|{RELATIONAL})
DECIMAL            ([0-9]+)
HEXADECIMAL        (0[xX][0-9a-fA-F]+)
BEG_STRING         (\"[^"\n]*)
STRING             ({BEG_STRING}\")
BOOLEAN            (true|false)   
INTEGER            ({DECIMAL}|{HEXADECIMAL})   
FLOAT              ({DECIMAL}\.{DECIMAL}?((E|e)(\+|\-)?{DECIMAL})?)
IDENTIFIER         ([a-zA-Z][a-zA-Z0-9_]*)
SINGLE_COMMENT     ("//"[^\n]*)
BEG_COMMENT        ("/*")
END_COMMENT        ("*/")

%x COPY COMMENT
%option stack

%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 

<COPY>.*                 { 
                           savedlines.Append(strdup(yytext));
                           colno = 1;
                           yy_pop_state();
                           yyless(0);
                         }
<COPY><<EOF>>            { yy_pop_state(); }
<*>\n                    { 
                           colno = 1; lineno++;
                           if (YYSTATE == COPY)
                             savedlines.Append("");
                           else 
                             yy_push_state(COPY);
                         }

<*>[\t]                  { colno += TAB_SIZE - colno % TAB_SIZE + 1; }
[ ]+                     ;

 /* recognize all keywords and return the correct token from scanner.h */
"void"                   { return T_Void; }
"int"                    { return T_Int; }
"double"                 { return T_Double; }
"bool"                   { return T_Bool; }
"string"                 { return T_String; }
"class"                  { return T_Class; }
"interface"              { return T_Interface; }
"null"                   { return T_Null; }
"this"                   { return T_This; }
"extends"                { return T_Extends; }
"implements"             { return T_Implements; }
"for"                    { return T_For; }
"while"                  { return T_While; }
"if"                     { return T_If; }
"else"                   { return T_Else; }
"return"                 { return T_Return; }
"break"                  { return T_Break; }
"switch"                 { return T_Switch; }
"case"                   { return T_Case; }
"default"                { return T_Default; }
"new"                    { return T_New; }
"NewArray"               { return T_NewArray; }
"Print"                  { return T_Print; }
"ReadInteger"            { return T_ReadInteger; }
"ReadLine"               { return T_ReadLine; }

 

 /* recognize punctuation and single-char operators 
  * and return the ASCII value as the token 
  */
{PUNCTUATION} |
{OPERATOR}               { return yytext[0]; }


 /* recognize two-character operators and return the correct token */
"<="                     { return T_LessEqual; }
">="                     { return T_GreaterEqual; }
"=="                     { return T_Equal; }
"!="                     { return T_NotEqual; }
"[]"                     { return T_Dims; }
"&&"                     { return T_And; }
"||"                     { return T_Or; }
"++"                     { return T_Increment; }
"--"                     { return T_Decrement; }

 /* recognize int, double, bool and string constants,
  * return the correct token
  * and set appropriate filed of yylval 
  */
{STRING}                 { 
                           yylval.stringConstant = strdup(yytext);
                           return T_StringConstant;
                         }
{BEG_STRING}             {
                          ReportError::UntermString(&yylloc, yytext);       
                         }
{BOOLEAN}                { 
                           if (strcmp("true", yytext) == 0)
                               yylval.boolConstant = true;
                           else
			       yylval.boolConstant = false;
                           return T_BoolConstant;
                         }
{DECIMAL}                { 
                           yylval.integerConstant = strtol(yytext, NULL, 10); return T_IntConstant; 
			 }
{HEXADECIMAL}            {
                          yylval.integerConstant = strtol(yytext, NULL, 16); 
			  return T_IntConstant;
                         }
{FLOAT}                  { 
                           yylval.doubleConstant = atof(yytext); return T_DoubleConstant; 
			 }

 /* recognize identifiers, 
  * return the correct token and set appropriate fields of yylval 
  */
{IDENTIFIER}             { 
                          if (yyleng > MaxIdentLen)
        	            ReportError::LongIdentifier(&yylloc, yytext);
			  strncpy(yylval.identifier, yytext, MaxIdentLen);
			  yylval.identifier[MaxIdentLen] = '\0';   
			  
			  return T_Identifier;
		        }

 /* consume single-line comment */
{SINGLE_COMMENT}      ;


 /* consume multi-line comments 
  * report unterminated comment
  */

{BEG_COMMENT}           { BEGIN COMMENT; }
<COMMENT>.              ;
<COMMENT>{END_COMMENT}  { BEGIN INITIAL; }
<COMMENT><<EOF>>        { 
			  ReportError::UntermComment();
			  BEGIN INITIAL;
			}
 /* all other characters are reported as errors */
.                       { 
                          ReportError::UnrecogChar(&yylloc, yytext[0]);     
			}

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
    yy_flex_debug = false;
    yy_push_state(COPY);
    lineno = 1;
    colno = 1;
}


/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
  yylloc.first_line = yylloc.last_line = lineno;

  yylloc.first_column = colno;
  yylloc.last_column = colno + yyleng - 1;
  colno = colno + yyleng;
}

/* Function: GetLinenumbered()
 * ---------------------------
 * Returns string with contents of line numbered n or NULL if the
 * contents of that line are not available. Our scanner copies
 * each line scanned and appends each to a list so we can later
 * retrieve them to report the context for errors.
 */
const char *GetLineNumbered(int num) 
{
  if (num <= 0 || num > savedlines.NumElements())
    return NULL;

  return savedlines.Nth(num - 1);
}

