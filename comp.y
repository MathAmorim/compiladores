/* Matheus Amorim */
/*  */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define TAM 18
#define SIM 8
#define ERROR_CODE -77777
int aqui = 8;


extern int linha;
extern int coluna;
extern int yyleng;
extern char *yytext;
FILE *f;

enum OPERADOR{ Menor, Menor_Igual, Maior, Maior_Igual, Diferente, Igual_Igual};
typedef struct no{
	char var[25];
	int dado;
	struct no *prox;
}No;

typedef struct hash_table{
	struct no *vet[TAM];
}Hash_table;

Hash_table T;
/* funções para manipulação da lista*/
/* void mostrar_lista(No **C){
	No *p;
	for (p=*C; p!=NULL; p=p->prox){
		printf("%s = %i ", p->var,p->dado);
	}
} */

int yyerror(char *msg){
	printf("\n");
	system("echo \"\\e[1;31mErro:\"");
	printf("%s (Linha: %i, Coluna: %i) \"%s\"\n", msg, linha, coluna-yyleng, yytext);
	system("echo \"\\e[0m\"");
	exit(0);
}

void inserir_lista(No **C, int valor, char var[]){
	No *novo;
	novo = (No *)malloc(sizeof(No));
	novo->dado = valor;
	strcpy(novo->var,var);
	novo->prox = NULL;	

	if (*C == NULL){
		*C = novo;
	}else{
		novo->prox = *C;
		*C = novo;
	}
}

int buscar_valor_lista(No **C, char var[]){
	No *p;
	for (p=*C; p!=NULL; p=p->prox){
		if(strcmp(p->var,var) == 0)
			return p->dado;
	}
	return ERROR_CODE;
}
/* funções para tabela hash*/
int hash(char * key){
  int final = 0xFF586;
  for(int i = 0; i < strlen(key); i++){
    final += key[i];
  }

  return (final *5)%TAM;
}

void inserir_tabela_hash(Hash_table *T, int valor, char var[]){
	
	inserir_lista(&T->vet[hash(var)], valor, var);
}

int buscar_valor_tabela_hash(Hash_table *T, char var[]){
	
	return buscar_valor_lista(&T->vet[hash(var)], var);
}

void inicializar_tabela(Hash_table *T){
	for (int i=0; i<TAM; i++)
		T->vet[i] = NULL;
}

void criar_variavel(char *var_name){
	if(buscar_valor_tabela_hash(&T, var_name) != ERROR_CODE){
		yyerror("Variavel já declarada! ");
	}
	fprintf(f, "	subq	$8, %%rsp\n\n");
	inserir_tabela_hash(&T, aqui, var_name);
	aqui += SIM;

}

void valor_variavel(char *var_name){
	int offset = buscar_valor_tabela_hash(&T, var_name);
	if (offset == ERROR_CODE){
		system("echo \"\\e[1;31mErro: \"");
		yyerror("Variavel não declarada! ");
		system("echo \"\\e[0m\"");
	}
	fprintf(f, "	popq	-%d(%%rbp)\n\n", offset);
}

void empilha_valor_variavel(char *var_name){
	int offset = buscar_valor_tabela_hash(&T, var_name);
	if (offset == ERROR_CODE){
		system("echo \"\\e[1;31mErro:\"");
		yyerror("Variavel não declarada! ");
		system("echo \"\\e[0m\"");
	}
	fprintf(f, "	pushq	-%d(%%rbp)\n\n", offset);
}
/* void mostrar_tabela(Hash_table *T){
	for (int i=0; i<TAM; i++){
		printf("[%i] ", i);
		mostrar_lista(&T->vet[i]);
		printf("\n");
	}
}
 */

/* Geração de código assembly*/


int yylex(void);

void montar_codigo_inicial(){
	f = fopen("out.s","w+");
	fprintf(f, ".text\n");
	fprintf(f, "    .global _start\n\n");
    	fprintf(f, "_start:\n\n");
		fprintf(f, "	pushq	%%rbp\n");
		fprintf(f, "	movq	%%rsp, %%rbp\n\n");
}

void montar_codigo_final(){
	fclose(f);
	system("as out.s -o out.o");
	system("ld out.o -o out");
	system("rm out.o ");
	printf("Arquivo \"out.s\" e \"out.o\"  gerado.\n\n");
}

void montar_codigo_retorno(){
	fprintf(f, "    popq    %%rbx\n");
	fprintf(f, "    movq    $1, %%rax\n");
	fprintf(f, "    int     $0x80\n\n");
}
void montar_codigo_exp(char op){
	switch(op){
		case '+':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    addq    %%rbx, %%rax\n");
			fprintf(f, "    pushq   %%rax\n\n");
			break;
		case '-':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    subq    %%rbx, %%rax\n");
			fprintf(f, "    pushq   %%rax\n\n");
			break;
		case '*':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    imulq   %%rbx, %%rax\n");
			fprintf(f, "    pushq   %%rax\n\n");
			break;
	}
	
}

void montar_add(int a, int b){
	fprintf(f, "    movq    $%d, %%rax\n", a);
	fprintf(f, "    movq    $%d, %%rbx\n", b);
	fprintf(f, "    addq    %%rax, %%rbx\n");
	fprintf(f, "    movq    $1, %%rax\n");
	fprintf(f, "    int     $0x80\n\n");
}

void montar_sub(int a, int b){
	fprintf(f, "    movq    $%d, %%rbx\n", a);
	fprintf(f, "    subq    $%d, %%rbx\n", b);
	fprintf(f, "    movq    $1, %%rax\n");
	fprintf(f, "    int     $0x80\n\n");
}

void montar_mult(int a, int b){
	fprintf(f, "    movq    $%d, %%rbx\n", a);
	fprintf(f, "    mult    $%d, %%rbx\n", b);
	fprintf(f, "    movq    $1, %%rax\n");
	fprintf(f, "    int     $0x80\n\n");
}
void montar_codigo_empilhar(int a){
	fprintf(f, "    pushq    $%i\n",a);
}

void monta_cond(int cond){
	fprintf(f, "# Comparacao\n");
	fprintf(f, "	popq	%%rbx\n");
	fprintf(f, "	popq	%%rax\n");
	fprintf(f, "	cmpq	%%rbx, %%rax\n");
	switch(cond){
		case Menor:{
			fprintf(f, "	setl	%%al\n");
		}break;
		case Menor_Igual:{
			fprintf(f, "	setle	%%al\n");
		}break;
		case Maior:{
			fprintf(f, "	setg	%%al\n");
		}break;
		case Maior_Igual:{
			fprintf(f, "	setge	%%al\n");
		}break;
		case Diferente:{
			fprintf(f, "	setne	%%al\n");	
		}break;
		case Igual_Igual:{
			fprintf(f, "	sete	%%al\n");
		}break;
	}
	fprintf(f, "    movzbq	%%al, %%rax\n");
	fprintf(f, "	pushq	%%rax\n\n");
}
%}
%union {
char *string;
int inteiro;
}

%token ABRE_PARENTESES MAIOR MENOR DIFERENTE FECHA_PARENTESES INT IGUAL RETURN FECHA_CHAVES PONTO_E_VIRGULA ABRE_CHAVES MAIN
%token MAIS MENOS MULT
%token<string> ID
%token<inteiro> NUM
%left MAIS MENOS
%left MULT
%%

programa	: INT MAIN ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES {montar_codigo_inicial();inicializar_tabela(&T);} corpo FECHA_CHAVES {montar_codigo_final();} ;

corpo			: RETURN exp PONTO_E_VIRGULA {montar_codigo_retorno();} corpo
			| var PONTO_E_VIRGULA corpo
			|
			;

exp         		: exp MAIS exp {montar_codigo_exp('+');}
			| exp MENOS exp {montar_codigo_exp('-');}
			| exp MULT exp {montar_codigo_exp('*');}
			| ABRE_PARENTESES exp FECHA_PARENTESES
			| exp MAIOR exp {monta_cond(Maior);}
			| exp MAIOR IGUAL exp {monta_cond(Maior_Igual);}
			| exp MENOR exp {monta_cond(Menor);}
			| exp MENOR IGUAL exp {monta_cond(Menor_Igual);}
			| exp DIFERENTE IGUAL exp {monta_cond(Diferente);}
			| exp IGUAL IGUAL exp {monta_cond(Igual_Igual);}
			| NUM {montar_codigo_empilhar($1);}
			| ID {empilha_valor_variavel($1);}
			;

var			: INT ID {criar_variavel($2);} IGUAL exp {valor_variavel($2);}
			| INT ID {criar_variavel($2);}
			| ID IGUAL exp {valor_variavel($1);}
			;


%%
int main(){

	yyparse();
	system("echo \"\\e[1;32mCompilação bem-sucedida!\\e[0m\"");
	printf("\n");
}


