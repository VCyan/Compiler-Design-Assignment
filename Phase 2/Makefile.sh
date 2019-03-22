# 
bison -d LexSyn.y -Wall -Wother
# bison -d LexSyn.y
flex LexSyn.l
# gcc -O2 -o LexSyn -DYACC LexSyn.tab.c  -lfl
gcc -O2 -o LexSyn -DYACC LexSyn.tab.c `pkg-config --cflags --libs glib-2.0` -lfl -O2
# ./LexSyn < testFile
./LexSyn < ../inputs/input1.c