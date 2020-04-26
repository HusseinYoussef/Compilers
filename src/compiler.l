%{
    #include <stdlib.h>
    #include <string.h>
    #include "compiler.h"
    #include "compiler.tab.h"
    void yyerror(char *);

    int var=0, valid_int=0, valid_float=0, zero;
%}

%option yylineno

%%

int                         {
                                printf("INT ");
                                return type_int;
                            }

float                       {
                                printf("FLOAT ");
                                return type_float;
                            }

char                        {
                                printf("CHAR ");
                                return type_char;
                            }

char[ ]*\*|string           {   
                                printf("STRING ");
                                return type_string;
                            }

[a-zA-Z][0-9a-zA-Z]*        {
                                printf("stringVar %s ", yytext);
                                yylval.var_name = strdup(yytext);
                                return VARIABLE;
                            }

[0]+                         {
                                yylval.iValue = 0;
                                return INTEGER;
                            }
[0]+.[0]+$             {
                                yylval.iValue = 0;
                                return INTEGER;
                            }

[1-9][0-9]*                {
                                printf("integer ");
                                yylval.iValue = atoi(yytext);
                                return INTEGER;
                            }

[0-9]+[.][0-9]*             {
                                printf("floating ");
                                yylval.fValue = atof(yytext);
                                return FLOAT;
                            }

\"[^"\n]*\"                 {
                                if(yyleng == 3)
                                {
                                    yylval.cValue = yytext[1];
                                    printf("found %d '%c' ", yyleng, yylval.cValue);
                                    return CHAR;
                                }
                                else
                                {
                                    yylval.sValue = strdup(yytext+1);
                                    yylval.sValue[yyleng-2] = 0;
                                    printf("found %d '%s' ", yyleng, yylval.sValue);
                                    return STRING;
                                }
                            }

[-+=;]                      { 
                                printf("%c ", *yytext);
                                return *yytext; 
                            }

[ \t\r\n]+                    ; /* ignore whitespace */

.                           {
                                printf("lex_error ");
                            }
%%

// int main(void) {
//   yylex();
//   printf("Hi");
//   return 0;
// }

void yyerror(char *s) {
    fprintf(stdout, "Line %d: %s\n", yylineno, s);
}

int yywrap(void) {
    return 1;
}