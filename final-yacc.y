%{
    #include <stdio.h>
    #include <gsl/gsl_matrix.h>
    
    int yylex(void);
    void yyerror(char *);
    extern char *strBuf;
    extern char *lastStrBuf;

    struct  matrixIndex {
        int index;
        gsl_matrix * matrix;
        struct matrixIndex *next;
    };
    struct  matrixIndex MIB = {-1,NULL,NULL};
    
    

    int tempArray[400];
    int tempIndex=0;

    int print_matrix(FILE *f, const gsl_matrix *m)
    {
        int status, n = 0;
        for (size_t i = 0; i < m->size1; i++) {
                //i==0?printf("┌"):i==m->size1-1?printf("└"):printf("│");
                printf("│");
                for (size_t j = 0; j < m->size2; j++) {
                        if ((status = fprintf(f, " %g", gsl_matrix_get(m, i, j))) < 0)
                                return -1;
                        n += status;
                }
                printf(" │");
                if ((status = fprintf(f, "\n")) < 0)
                        return -1;
                n += status;
        }

        return n;
    }

    void storeTempData(int data)
    {
        tempArray[tempIndex++] = data;
    }

    void storeMatrix(int index,int noOfRow,int noOfColumn)
    {
        int i,j;
        struct matrixIndex *tempMI = &MIB;
        gsl_matrix * newMat;

        if(noOfRow * noOfColumn != tempIndex)
        {
            //printf("tempIndex:%d",tempIndex);
            printf("DEFINE-MATRIX-ERROR: less/more number of elements in input\n");
            exit(0);
        }
        
        
        while(tempMI->next != NULL && tempMI->index != index)
        {
            tempMI = tempMI->next;
        }
        if(tempMI->index == index)
        {
            printf("MATRIX-REDEFINE-AT-INDEX:%d\n",index);
            gsl_matrix_free(tempMI->matrix);
        }
        else
        {
            tempMI->next =(struct matrixIndex *) malloc (sizeof (struct matrixIndex));
            (tempMI->next)->index = index;
            tempMI = tempMI->next;
            tempMI->next = NULL;
        }
        
        newMat = gsl_matrix_alloc (noOfRow, noOfColumn);
        
        for (i = 0; i < noOfRow; i++)
            for (j = 0; j < noOfColumn; j++)
                gsl_matrix_set (newMat, i, j, tempArray[--tempIndex]);

        
        tempMI->matrix = newMat;
    }


    struct matrixIndex * findMatAtIndex(int index)
    {
        if(index == -1)
            return &MIB;
        struct matrixIndex *tempMI = &MIB;
        while(tempMI != NULL && tempMI->index != index)
        {
            tempMI = tempMI->next;
        }
        if(tempMI == NULL)
        {
            printf("MATRIX-NOT-FOUND-ERROR: no matrix found at index : %d \n",index);
            exit(0);
        }
        return tempMI;
    }
    struct matrixIndex * findMatAtVar()
    {
       //printf("----->%c",*strBuf);
        
       return findMatAtIndex(*strBuf == '$'?-1:atoi(strBuf));
    }

    void printMatrix(int index)
    {
        struct matrixIndex *tempMI;
        tempMI = findMatAtIndex(index);
        //printf("matrix-found-index-%d\n",tempMI->index);
        print_matrix(stdout,tempMI->matrix);

    }
    void matAddConstant(double val)
    {
        struct matrixIndex *tempMI;
        size_t row,col;
        tempMI = findMatAtVar();
        if(tempMI == &MIB)
        {
            gsl_matrix_add_constant(MIB.matrix,val);
            printMatrix(-1);
        }
        else
        {
            if(MIB.matrix != NULL)
            {
                gsl_matrix_free(MIB.matrix);
            }
            row = tempMI->matrix->size1;
            col = tempMI->matrix->size2;
            MIB.matrix = gsl_matrix_alloc((int)row,(int)col);
            gsl_matrix_memcpy(MIB.matrix, tempMI->matrix);
            //printMatrix(-1);
            //printf("%f",val);
            gsl_matrix_add_constant(MIB.matrix,val);
            printMatrix(-1);
        }
    }
    void matScale(double val)
    {
        struct matrixIndex *tempMI;
        size_t row,col;
        tempMI = findMatAtVar();
        if(tempMI == &MIB)
        {
            gsl_matrix_add_constant(MIB.matrix,val);
            printMatrix(-1);
        }
        else
        {
            if(MIB.matrix != NULL)
                {
            gsl_matrix_free(MIB.matrix);
            }
            row = tempMI->matrix->size1;
            col = tempMI->matrix->size2;
            MIB.matrix = gsl_matrix_alloc((int)row,(int)col);
            gsl_matrix_memcpy(MIB.matrix, tempMI->matrix);
    
            gsl_matrix_scale(MIB.matrix,val);
            printMatrix(-1);
        }
    }
    struct matrixIndex * findLastMatAtVar()
    {
        return findMatAtIndex(*lastStrBuf == '$'?-1:atoi(lastStrBuf));
    }
    void matEqual()
    {
        struct matrixIndex *tempMI1;
        struct matrixIndex *tempMI2;
        tempMI2 = findMatAtVar();
        tempMI1 = findLastMatAtVar();
        
        gsl_matrix_memcpy(tempMI1->matrix, tempMI2->matrix);

        printMatrix(tempMI1->index);
    }
    void matAdd()
    {
        struct matrixIndex *tempMI1;
        struct matrixIndex *tempMI2;
        struct matrixIndex *tempA;
        tempMI2 = findMatAtVar();
        tempMI1 = findLastMatAtVar();

        tempA = (struct matrixIndex *) malloc (sizeof (struct matrixIndex));

        size_t row,col;
        if(!(tempMI1->matrix->size1 == tempMI2->matrix->size1 && tempMI1->matrix->size1 == tempMI2->matrix->size2))
        {
            printf("MATRIX-DIMENSIONS-NOT-SAME-ERROR");
            exit(0);
        }
        row = tempMI1->matrix->size1;
        col = tempMI1->matrix->size2;
        tempA->matrix = gsl_matrix_alloc((int)row,(int)col);
        gsl_matrix_memcpy(tempA->matrix, tempMI1->matrix);
        //printf("done");
        gsl_matrix_add(tempA->matrix, tempMI2->matrix);

        if(MIB.matrix != NULL)
        {
            gsl_matrix_free(MIB.matrix);
        }
        MIB.matrix = tempA->matrix;
        printMatrix(-1);
    }
    void matSub()
    {
        struct matrixIndex *tempMI1;
        struct matrixIndex *tempMI2;
        struct matrixIndex *tempA;
        tempMI2 = findMatAtVar();
        tempMI1 = findLastMatAtVar();

        tempA = (struct matrixIndex *) malloc (sizeof (struct matrixIndex));

        size_t row,col;
        if(!(tempMI1->matrix->size1 == tempMI2->matrix->size1 && tempMI1->matrix->size1 == tempMI2->matrix->size2))
        {
            printf("MATRIX-DIMENSIONS-NOT-SAME-ERROR");
            exit(0);
        }
        row = tempMI1->matrix->size1;
        col = tempMI1->matrix->size2;
        tempA->matrix = gsl_matrix_alloc((int)row,(int)col);
        gsl_matrix_memcpy(tempA->matrix, tempMI1->matrix);
        //printf("done");
        gsl_matrix_sub(tempA->matrix, tempMI2->matrix);

        if(MIB.matrix != NULL)
        {
            gsl_matrix_free(MIB.matrix);
        }

        MIB.matrix = tempA->matrix;
        printMatrix(-1);
    }
    void matMul()
    {
        struct matrixIndex *tempMI1;
        struct matrixIndex *tempMI2;
        struct matrixIndex *tempA;
        tempMI2 = findMatAtVar();
        tempMI1 = findLastMatAtVar();

        tempA = (struct matrixIndex *) malloc (sizeof (struct matrixIndex));

        size_t row,col;
        if(!(tempMI1->matrix->size1 == tempMI2->matrix->size1 && tempMI1->matrix->size1 == tempMI2->matrix->size2))
        {
            printf("MATRIX-DIMENSIONS-NOT-SAME-ERROR");
            exit(0);
        }
        row = tempMI1->matrix->size1;
        col = tempMI1->matrix->size2;
        tempA->matrix = gsl_matrix_alloc((int)row,(int)col);
        gsl_matrix_memcpy(tempA->matrix, tempMI1->matrix);
        //printf("done");
        gsl_matrix_mul_elements(tempA->matrix, tempMI2->matrix);

        if(MIB.matrix != NULL)
        {
            gsl_matrix_free(MIB.matrix);
        }
        MIB.matrix = tempA->matrix;
        printMatrix(-1);
    }
    void matDiv()
    {
        struct matrixIndex *tempMI1;
        struct matrixIndex *tempMI2;
        struct matrixIndex *tempA;
        tempMI2 = findMatAtVar();
        tempMI1 = findLastMatAtVar();

        tempA = (struct matrixIndex *) malloc (sizeof (struct matrixIndex));

        size_t row,col;
        if(!(tempMI1->matrix->size1 == tempMI2->matrix->size1 && tempMI1->matrix->size1 == tempMI2->matrix->size2))
        {
            printf("MATRIX-DIMENSIONS-NOT-SAME-ERROR");
            exit(0);
        }
        row = tempMI1->matrix->size1;
        col = tempMI1->matrix->size2;
        tempA->matrix = gsl_matrix_alloc((int)row,(int)col);
        gsl_matrix_memcpy(tempA->matrix, tempMI1->matrix);
        //printf("done");
        gsl_matrix_div_elements(tempA->matrix, tempMI2->matrix);

        if(MIB.matrix != NULL)
        {
            gsl_matrix_free(MIB.matrix);
        }
        MIB.matrix = tempA->matrix;
        printMatrix(-1);
    }
    void setAll(double val)
    {
        struct matrixIndex *tempMI;
        size_t row,col;
        tempMI = findMatAtVar();
        if(tempMI == &MIB)
        {
            gsl_matrix_add_constant(MIB.matrix,val);
            printMatrix(-1);
        }
        else
        {
            if(MIB.matrix != NULL)
                {
            gsl_matrix_free(MIB.matrix);
            }
            row = tempMI->matrix->size1;
            col = tempMI->matrix->size2;
            MIB.matrix = gsl_matrix_alloc((int)row,(int)col);
            gsl_matrix_memcpy(MIB.matrix, tempMI->matrix);
    
            //gsl_matrix_scale(MIB.matrix,val);
            gsl_matrix_set_all(MIB.matrix, val);
            gsl_matrix_set_all(tempMI->matrix, val);
            printMatrix(-1);
        }
    }

//    void check() {
//        int i, j;
//        gsl_matrix * m = gsl_matrix_alloc (10, 3);
//
//  for (i = 0; i < 10; i++)
//    for (j = 0; j < 3; j++)
//      gsl_matrix_set (m, i, j, 0.23 + 100*i + j);
//
//  for (i = 0; i < 100; i++)  /* OUT OF RANGE ERROR */
//    for (j = 0; j < 3; j++)
//      printf ("m(%d,%d) = %g\n", i, j,
//              gsl_matrix_get (m, i, j));
//
//  gsl_matrix_free (m);
//
//    }
%}

%token INTEGER
%token MATRIX
%token DEFINE
%token ENDDEFINE
%token ROW
%token COLUMN
%token CALCULATE
%token ENDCALCULATE
%token DOT
%token VAR

%%
S : E S
  | 
  ;
E : DEFINE MATRIX INTEGER ROW INTEGER COLUMN INTEGER data ENDDEFINE {storeMatrix($3,$5,$7);printMatrix($3);}
  | CALCULATE expr ENDCALCULATE {printf("cal");}
  ;
data : INTEGER data {storeTempData($1);}
     | INTEGER {storeTempData($1);}
     ;
expr : expr VAR '+' INTEGER {matAddConstant((double) $4);}
     | expr VAR '-' INTEGER {matAddConstant((double) $4 * (-1));}
     | expr VAR '*' INTEGER {matScale((double) $4);}
     | expr VAR '/' INTEGER {matScale((double) (1.0/($4)));}
     | expr VAR '=' VAR {matEqual();}
     | expr VAR '+' VAR {matAdd();}
     | expr VAR '-' VAR {matSub();}
     | expr VAR '*' VAR {matMul();}
     | expr VAR '/' VAR {matDiv();}
     | expr VAR '=' INTEGER {setAll((double)$4);}
     |
     ;
%%
void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}
int main(int argc, char *argv[])
{ 
    yyparse();
    return 0;
}
