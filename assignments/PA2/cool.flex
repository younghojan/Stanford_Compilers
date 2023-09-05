/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

char string_const[MAX_STR_CONST];
int string_const_len;
bool str_contains_null_char;
%}

/*
 * Define lexer states for single-line comments, multi-line comments, strings
 */

%option noyywrap
%x LINE_COMMENT BLOCK_COMMENT STRING

/*
 * Define names for regular expressions here.
 */

/* Arrow operator */
DARROW          =>

/* Assignment Operator */
ASSIGN          <-

/* Arithmetic operators */
ADD             "+"
SUB             "-"
DIV             "/"
MULT            "*"
MOD             "%"

/* Bit operators */
BITAND          "&"
BITOR           "|"
BITNOT          "~"
BITXOR          "^"

/* Comparison operators */
LT              "<"
EQ              "="
LE              <=

/* Other single-character symbols */
LEFTBRACE       "{"
RIGHTBRACE      "}"
LEFTBRACKET     "["
RIGHTBRACKET    "]"   
LEFTPAREN       "("
RIGHTPAREN      ")"
COMMA           ","
SEMICOLON       ";"
COLON           ":"
DOT             "."
AT              "@"

/* Keywords */
CLASS           ?i:CLASS
ELSE            ?i:ELSE
FI              ?i:FI
IF              ?i:IF
IN              ?i:IN
INHERITS        ?i:INHERITS
LET             ?i:LET
LOOP            ?i:LOOP
POOL            ?i:POOL
THEN            ?i:THEN
WHILE           ?i:WHILE
CASE            ?i:CASE
ESAC            ?i:ESAC
OF              ?i:OF
NEW             ?i:NEW
NOT             ?i:NOT
ISVOID          ?i:ISVOID
TRUE            t[rR][uU][eE]
FALSE           f[aA][lL][sS][eE]

/* White space */
NEWLINE         \n
WHITESPACE      [ \t\r\v\f]+

/* Comments */
LINECMTBEGIN    "--"
BLKCMTBEGIN     "(\*"
BLKCMTEND       "\*)"

/* Integer */
INT             [0-9]+

/* Identifiers */
TYPEID          [A-Z][A-Za-z0-9_]*
OBJECTID        [a-z][A-Za-z0-9_]*
%%

 /*
  * White space
  */
{WHITESPACE}    {}
{NEWLINE}       {}

 /*
  *  Nested comments
  */
 /* Single-line comments */
{LINECMTBEGIN}              { BEGIN LINE_COMMENT; }
<LINE_COMMENT>.             {}
<LINE_COMMENT>{NEWLINE}     { BEGIN 0; curr_lineno++; }

 /* Block comments */
{BLKCMTBEGIN}               { BEGIN BLOCK_COMMENT; }
<BLOCK_COMMENT>.		        {}
<BLOCK_COMMENT>{NEWLINE}    { curr_lineno++; }
<BLOCK_COMMENT><<EOF>>	    {
                              strcpy(cool_yylval.error_msg, "EOF in comment");
	                            BEGIN 0; 
                              return (ERROR); 
                            }
<BLOCK_COMMENT>{BLKCMTEND}  { BEGIN 0; }
{BLKCMTEND}			            {
                              strcpy(cool_yylval.error_msg, "Unmatched *)");
	                            return (ERROR); 
                            }

 /*
  * The single-character operators.
  */
{ADD}           { return ('+'); }
{SUB}           { return ('-'); }
{DIV}           { return ('/'); }
{MULT}          { return ('*'); }
{MOD}           { return ('%'); }
{BITAND}        { return ('&'); }
{BITOR}         { return ('|'); }
{BITNOT}        { return ('~'); }
{BITXOR}        { return ('^'); }
{LEFTBRACE}     { return ('{'); }
{RIGHTBRACE}    { return ('}'); }
{LEFTBRACKET}   { return ('['); }
{RIGHTBRACKET}  { return (']'); }
{LEFTPAREN}     { return ('('); }
{RIGHTPAREN}    { return (')'); }
{COMMA}         { return (','); }
{SEMICOLON}     { return (';'); }
{COLON}         { return (':'); }
{DOT}           { return ('.'); }
{AT}            { return ('@'); }
{LT}            { return ('<'); }
{EQ}            { return ('='); }

 /*
  *  The multiple-character operators.
  */
{DARROW}		    { return (DARROW); }
{ASSIGN}        { return (ASSIGN); }
{LE}            { return (LE); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
{CLASS}         { return (CLASS); }           
{ELSE}          { return (ELSE); }
{FI}            { return (FI); }
{IF}            { return (IF); }
{IN}            { return (IN); }
{INHERITS}      { return (INHERITS); }
{LET}           { return (LET); }
{LOOP}          { return (LOOP); }
{POOL}          { return (POOL); }
{THEN}          { return (THEN); }
{WHILE}         { return (WHILE); }
{CASE}          { return (CASE); }
{ESAC}          { return (ESAC); }
{OF}            { return (OF); }
{NEW}           { return (NEW); }
{NOT}           { return (NOT); }
{ISVOID}        { return (ISVOID); }
{TRUE}          { 
                  cool_yylval.boolean = 1;
                  return (BOOL_CONST); 
                }
{FALSE}         { 
                  cool_yylval.boolean = 0;
                  return (BOOL_CONST); 
                }

 /*
  * Integer
  */
{INT}         { 
                cool_yylval.symbol = inttable.add_string(yytext); 
	              return (INT_CONST); 
              }

 /*
  * Identifiers
  */
{TYPEID}      {
                cool_yylval.symbol = idtable.add_string(yytext); 
	              return (TYPEID); 
              }
{OBJECTID}    { 
                cool_yylval.symbol = idtable.add_string(yytext); 
	              return (OBJECTID); 
              }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
\"	              {
                    memset(string_const, 0, sizeof string_const);
                    string_const_len = 0; 
                    str_contains_null_char = false;
                    BEGIN STRING;
                  }
<STRING><<EOF>>	  {
                    strcpy(cool_yylval.error_msg, "EOF in string constant");
                    BEGIN 0; 
                    return (ERROR);
                  }
<STRING>\\.		    {
                    if (string_const_len >= MAX_STR_CONST) {
                      strcpy(cool_yylval.error_msg, "String constant too long");
                      BEGIN 0; 
                      return (ERROR);
                    } 
                    switch(yytext[1]) {
                      case '\"': string_const[string_const_len++] = '\"'; break;
                      case '\\': string_const[string_const_len++] = '\\'; break;
                      case 'b' : string_const[string_const_len++] = '\b'; break;
                      case 'f' : string_const[string_const_len++] = '\f'; break;
                      case 'n' : string_const[string_const_len++] = '\n'; break;
                      case 't' : string_const[string_const_len++] = '\t'; break;
                      case '0' : string_const[string_const_len++] = 0; 
                                           str_contains_null_char = true; break;
                      default  : string_const[string_const_len++] = yytext[1];
                    }
                  }
<STRING>\\\n	    { curr_lineno++; }
<STRING>\n		    {
                    curr_lineno++;
                    strcpy(cool_yylval.error_msg, "String constant unterminated");
                    BEGIN 0; 
                    return (ERROR);
                  }
<STRING>\"		    { 
                    if (string_const_len > 1 && str_contains_null_char) {
                      strcpy(cool_yylval.error_msg, "String contains null character");
                      BEGIN 0;
                      return (ERROR);
                    }
                    cool_yylval.symbol = stringtable.add_string(string_const);
                    BEGIN 0; 
                    return (STR_CONST);
                  }
<STRING>.		      { 
                    if (string_const_len >= MAX_STR_CONST) {
                      strcpy(cool_yylval.error_msg, "String constant too long");
                      BEGIN 0; 
                      return (ERROR);
                    } 
                    string_const[string_const_len++] = yytext[0]; 
                  }

 /*
  *  Other errors
  */
.	  {
      strcpy(cool_yylval.error_msg, yytext); 
      return (ERROR); 
    }
%%
