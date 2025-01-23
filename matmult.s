# Siyu Li

/* C implementation of matrix multiplication
int** matrix_multiply(int** matrix_a, int num_rows_a, int num_cols_a,
											int** matrix_b, int num_rows_b, int num_cols_b,
											int* out_num_rows_c, int* out_num_cols_c) {
    *out_num_rows_c = num_rows_a;
    *out_num_cols_c = num_cols_b;
    int** outMatrix = (int**)malloc((*out_num_rows_c) * sizeof(int*));
    for(int row = 0; row < *out_num_rows_c; row++) {
        outMatrix[row] = (int*)malloc((*out_num_cols_c) * sizeof(int));
        for(int col = 0; col < *out_num_cols_c; col++) {
            int temp = 0;
            for(int i = 0; i < num_cols_a; i++) {
                temp += (matrix_a[row][i] * matrix_b[i][col]);
            }
            outMatrix[row][col] = temp;

        }
 
    }

    return outMatrix;

}
*/

// int** matMult(int **a, int num_rows_a, int num_cols_a, int** b, int num_rows_b, int num_cols_b)

.global matMult
.equ ws, 4

.text

matMult:
    # locals: outMatrix, row, col, i, temp
    .equ num_locals, 5
    .equ used_ebx, 1
    .equ used_esi, 1
    .equ used_edi, 0
    .equ num_save_regs, (used_ebx + used_esi + used_edi)

    prologue_start:
        push %ebp
        movl %esp, %ebp
        # make room for locals and saved regs
        subl $7*ws, %esp

        /* the stack
        ebp + 7: num_cols_b
        ebp + 6: num_rows_b
        ebp + 5: B
        ebp + 4: num_cols_a
        ebp + 3: num_rows_a
        ebp + 2: A
        ebp + 1: ret address
        ebp: old ebp
        ebp - 1: outMatrix
        ebp - 2: row
        ebp - 3: col
        ebp - 4: i
        ebp - 5: temp
        ebp - 6: old ebx
        ebp - 7: old esi
        */

        .equ A, (2*ws)          # (%ebp)
        .equ num_rows_a, (3*ws) # (%ebp)
        .equ num_cols_a, (4*ws) # (%ebp)
        .equ B, (5*ws)          # (%ebp)
        .equ num_rows_b, (6*ws) # (%ebp)
        .equ num_cols_b, (7*ws) # (%ebp)

        .equ outMatrix, (-1*ws) # (%ebp)
        .equ row, (-2*ws)       # (%ebp)
        .equ col, (-3*ws)       # (%ebp)
        .equ i, (-4*ws)         # (%ebp)
        .equ temp, (-5*ws)      # (%ebp)
        .equ old_ebx, (-6*ws)   # (%ebp)
        .equ old_esi, (-7*ws)   # (%ebp)


        //save callee saved registers
        movl %ebx, old_ebx(%ebp)
        movl %esi, old_esi(%ebp)

    prologue_end:


    # num_rows_out = num_rows_a(%ebp)
    # num_cols_out = num_cols_b(%ebp)

    # int** outMatrix = (int**)malloc((*out_num_rows_c) * sizeof(int*));

    movl num_rows_a(%ebp), %eax # eax = num_rows_out
    shll $2, %eax # eax = num_rows_out * sizeof(int)
    push %eax # place arg to malloc on stack
    call malloc # return value in eax
    addl $1*ws, %esp # clear malloc args from stack

    movl %eax, outMatrix(%ebp) # outMatrix = (int**)malloc((*out_num_rows_c) * sizeof(int*));

    # ecx = row
    # edx = col
    # for(int row = 0; row < *out_num_rows_c; row++)

    movl $0, %ecx # row = 0

    first_for_start:
        # row < num_rows_out == row - num_rows_out < 0
        # negation: row - num_rows_out >=0
        cmpl num_rows_a(%ebp), %ecx # row - num_rows_out
        jge first_for_end

        # outMatrix[row] = (int*)malloc((*out_num_cols_c) * sizeof(int));
        movl num_cols_b(%ebp), %ebx # ebx = num_cols_out
        shll $2, %ebx # ebx = num_cols * sizeof(int)
        push %ebx # place malloc args on stack
        movl %ecx, row(%ebp) # save row's current value
        call malloc
        addl $1*ws, %esp # clear malloc args from stack
        movl row(%ebp), %ecx # restore ecx back to row

        movl outMatrix(%ebp), %ebx # ebx = outMatrix
        movl %eax, (%ebx, %ecx, ws) # outMatrix[row] = (int*)malloc((*out_num_cols_c) * sizeof(int));


        # for(int col = 0; col < *out_num_cols_c; col++)
        # edx = col

        movl $0, %edx # col = 0
        second_for_start:
            # col < num_cols_out == col - num_cols_out < 0
            # negation: col - num_cols_out >= 0
            cmpl num_cols_b(%ebp), %edx # cols - num_cols_out
            jge second_for_end
            
            #int temp = 0;
            movl $0, temp(%ebp)
            
            # for(int i = 0; i < num_cols_a; i++)
            # esi = i

            movl $0, %esi # i = 0
            third_for_start:
                # i < num_cols_a == i - num_cols_a < 0
                # negate: i - num_cols_a >= 0
                cmpl num_cols_a(%ebp), %esi
                jge third_for_end

                # temp += (matrix_a[row][i] * matrix_b[i][col]);
                # matrix_a[row][i] = *(*(matrix_a + row) + i)
                # matrix_b[i][col] = *(*(matrix_b + i) + col)
                
                # ecx = row, edx = col, esi = i
                # eax = matrix_a, ebx = matrix_b

                # *(*(A + row) + i)
                movl A(%ebp), %eax # eax = A
                movl (%eax, %ecx, ws), %eax # eax = *(A + row)
                movl (%eax, %esi, ws), %eax # eax = *(*(A + row) + i) = A[row][i] 

                # *(*(B + i) + col)
                movl B(%ebp), %ebx # ebx = B
                movl (%ebx, %esi, ws), %ebx # ebx = *(B + i)
                movl (%ebx, %edx, ws), %ebx # ebx = *(*(B + i) + col) = B[i][col]

                # save edx current value
                movl %edx, col(%ebp)
                imull %ebx # eax = eax * ebx
                addl %eax, temp(%ebp) # temp += (A[row][i] * B[i][col]);

                # restore edx current value
                movl col(%ebp), %edx
                
                incl %esi # i++
                jmp third_for_start
            third_for_end:

            # outMatrix[row][col] = temp;
            # *(*(outMatrix + row) + col)
            # ecx = row, edx = col
            movl outMatrix(%ebp), %ebx # ebx = outMatrix
            movl (%ebx, %ecx, ws), %ebx # ebx = *(outMatrix + row)
            # esi now free, so use it to store temp
            movl temp(%ebp), %esi
            movl %esi, (%ebx, %edx, ws) # *(*(outMatrix + row) + col) = temp
            

            incl %edx # col++
            jmp second_for_start # next iteration
        second_for_end:


        incl %ecx # row++
        jmp first_for_start # next iteration
    first_for_end:

    epilogue:
        movl outMatrix(%ebp), %eax # set return value

        # restore saved regs
        movl old_ebx(%ebp), %ebx
        movl old_esi(%ebp), %esi

        movl %ebp, %esp
        pop %ebp
        ret
