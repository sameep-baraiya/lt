# LT project
Matrix operations based programming language
Ajudiya Hepinkumar N. - IT003 - H1 - IT 
Baraiya Sameep P. - IT004 - H1 - IT
Sem 6 IT DDIT (2019-2020)
## Installation, Compilation, and Output
GSL installation steps (Only one time) :
```bash
$ sudo apt-get install libgsl-dev
```
Compilation Steps :
Yacc
```bash
$ yacc -d final-yacc.y 
```
Lex
```bash
$ lex final-lex.l
```
Gcc
```bash
$ gcc y.tab.c lex.yy.c `gsl-config --cflags --libs`
```
Running a.out
```bash
$ ./a.out
```
## MORE INFO
read presentation [PPT](https://docs.google.com/presentation/d/1sPJUoraB4vJ0WDuf2cEd055IwnELZJYDF7TmyjQvKCw/edit?usp=sharing)
