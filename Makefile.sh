bison -d LexSyn.y
flex LexSyn.l
gcc -O2 -o LexSyn -DYACC LexSyn.tab.c  -lfl
# gcc -O2 -o SynLex -DYACC SynLex.tab.c `pkg-config --cflags --libs glib-2.0` -lfl
./LexSyn < inputs/input.c