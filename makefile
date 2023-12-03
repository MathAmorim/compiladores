PROJ_NAME=Cmin

LEX=flex
YACC= bison -d
YFLAGS = -d
CC=gcc
CCFLAGS= -lm

out: Cmin in.c
	@ ./Cmin < in.c
	@ echo "Executando..."
	@ ./out
	@ echo $?


$(PROJ_NAME): lex.yy.c comp.tab.c 
	@ echo "\e[1;33mConstruindo Bin usando gcc\e[0m 	 linke:$^ e $< e $@"
	$(CC)  $^ -o $@  $(CCFLAGS)
	@ echo "\e[1;33mRemovendo arquivos\e[0m "
	@ rm  comp.tab.h lex.yy.c comp.tab.c


lex.yy.c: comp.flex 
	@ clear
	@ echo "\e[1;33mConstruindo flex \e[0m 	 linke:$^ e $< e $@"
	$(LEX) $^

comp.tab.c: comp.y
	@ echo "\e[1;33mConstruindo Bison \e[0m 	 linke:$^ to $@"
	$(YACC) $^  
