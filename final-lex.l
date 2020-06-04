%{
    #include <stdlib.h>
    void yyerror(char *);
    #include "y.tab.h"
    extern int yylval;
    char *strBuf = NULL;
    char *lastStrBuf = NULL;
    int _NoOfLine = 0;
    
%}

%%
define {return DEFINE;}
matrix {return MATRIX;}
row {return ROW;}
column {return COLUMN;}
endDefine {return ENDDEFINE;}
calculate {return CALCULATE;}
endCalculate {return ENDCALCULATE;}
"$$" {lastStrBuf = strBuf;strBuf = yytext+1; return VAR; }
"$"[0-9]+ {lastStrBuf = strBuf;strBuf = yytext+1; return VAR; }
"-"[0-9]+ {yylval = atoi(yytext);return INTEGER;}
[0-9]+ {yylval = atoi(yytext);return INTEGER;}
["+""*""/""="] {return *yytext;}
"-" {return *yytext;}
[\n] {_NoOfLine++;}
[ \t]+ {;}
.		{printf("<invalid-token:%s> ", yytext);}


%%

int yywrap(){} 

