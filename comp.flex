
%{
#include "comp.tab.h"

int linha=1, coluna=1;
%}

DIGITO 	[0-9]
LETRA	[A-Za-z_]

%%
" "		    { coluna+=yyleng;}
\n		    { linha++; coluna=1; }
"="	    	{ coluna+=yyleng; return IGUAL; }
"+"	    	{ coluna+=yyleng; return MAIS; }
"*"		    { coluna+=yyleng; return MULT; }
"-"		    { coluna+=yyleng; return MENOS; }
"("		    { coluna+=yyleng; return ABRE_PARENTESES; }
")"		    { coluna+=yyleng; return FECHA_PARENTESES; }
"{"		    { coluna+=yyleng; return ABRE_CHAVES; }
"}"		    { coluna+=yyleng; return FECHA_CHAVES; }
";"		    { coluna+=yyleng; return PONTO_E_VIRGULA; }
"int"	    { coluna+=yyleng; return INT; }
"main"	    { coluna+=yyleng; return MAIN; }
"return"	{ coluna+=yyleng; return RETURN; }
{DIGITO}+	{ coluna+=yyleng; yylval.inteiro=atoi(yytext); return NUM; }
{LETRA}({LETRA}|{DIGITO})* { coluna+=yyleng; yylval.string=strdup(yytext); return ID; }
.			{ coluna+=yyleng; }
%%

int yywrap(void){
    return -1;
}