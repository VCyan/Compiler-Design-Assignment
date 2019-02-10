bison -d LexSyn.y -Wall -Wother
flex LexSyn.l
# gcc -O2 -o LexSyn -DYACC LexSyn.tab.c  -lfl
gcc -O2 -o LexSyn -DYACC LexSyn.tab.c `pkg-config --cflags --libs glib-2.0` -lfl
./LexSyn < inputs/input.c