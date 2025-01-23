# Siyu Li

.global _start
.global editDist
.global min
.global swap
.global my_strlen_mem

.data

string1:
    .rept 101
    .byte 0
    .endr
string2:
    .rept 101
    .byte 0
    .endr

oldDist:
    .rept 101
    .long 0
    .endr
curDist:
    .rept 101
    .long 0
    .endr
oldDist_ptr:
    .long 0
curDist_ptr:
    .long 0


strlen_arg:
    .long 0
strlen_temp:
    .long 0


word1_len:
    .long 0
word2_len:
    .long 0


.text

# strlen function taken from class drive
# Source: Professor Butner
my_strlen_mem:
  # argument s should be placed in strlen_arg 
  # return value will be placed in strlen 
  # registers should be callee saved 

  #ecx will be i
  #eax will be s
  push %ecx # save the old ecx value
  push %eax # save the old eax value 

  movl strlen_arg, %eax # eax = s
  

  #for( i = 0; s[i] !='\0'; ++i)
  movl $0, %ecx # i = 0
  strlen_reg_for_start1:
    #s[i] !='\0'
    #s[i] - '\0' != 0
    #neg s[i] - '\0' == 0
    cmpb $0, (%eax, %ecx, 1) # s[i] - '\0'
    je strlen_reg_for_end1

    incl %ecx 
    jmp strlen_reg_for_start1

  strlen_reg_for_end1:
  movl %ecx, strlen_temp # set the return value 
  pop %eax  # restore old eax 
  pop %ecx # restore old ecx 
  ret
my_strlen_mem_end:




min: # int min(int a, int b)
    # num_locals = 0
    # return value will be in eax
    # ecx will store a
    # edx will store b

    # + 3:  b
	# + 2: a
	# + 1: return address
    # ebp: old ebp



    prologue_min:
        push %ebp # save old ebp
        movl %esp, %ebp # initialize stack frame
        .equ a, (2 * 4) #(%ebp)
        .equ b, (3 * 4) #(%ebp)

    prologue__min_end:



    movl a(%ebp), %ecx # ecx = a
    movl b(%ebp), %edx # edx = b

    # create if statement
    # return by moving value to eax and jumping to epilogue
    # a < b == a - b < 0
    # negation: a - b >= 0

    cmpl %edx, %ecx
    jge if_end
    if_start:
    #return a
    movl a(%ebp), %eax
    jmp epilogue_min

    if_end:
    #return b
    movl b(%ebp), %eax



    epilogue_min:
        movl %ebp, %esp # clear space made on stack for anything
        pop %ebp # restore ebp to original value
        ret

    epilogue_min_end:
min_end:

swap: # void swap(int** a, int** b)
    # num_locals = 1
    # no return value
    # eax, ecx, and edx will be used to swap a and b

    # + 3:  b
	# + 2: a
	# + 1: return address
	# ebp: old ebp
    # -1: temp

    prologue_swap:
        push %ebp # save old ebp
        movl %esp, %ebp # initialize stack frame
        .equ a, (2 * 4) #(%ebp)
        .equ b, (3 * 4) #(%ebp)
        .equ temp, (-1 * 4) #(%ebp)

    prologue_swap_end:

    # int* temp = *a
    # store a in eax
    # copy a into ecx for use later
    # get *a and put in eax
    # set temp = *a = eax

    movl a(%ebp), %eax # eax = a
    leal (%eax), %ecx # ecx = eax = a

    movl (%eax), %eax # eax = *eax = *a = oldDist_ptr
    movl %eax, temp(%ebp) # temp = eax = *a



    #*a = *b;
    # store b in edx
    # reuse eax since it is no longer needed
    # copy b in eax for use later
    # since ecx has a copy of a, we can use it to find the actual address of *a

    movl b(%ebp), %edx # edx = b
    leal (%edx), %eax # eax = edx = b

    movl (%edx), %edx # edx = *edx = *b = curDist_ptr
    movl %edx, (%ecx) # *a = *b

    # *b = temp
    # reuse edx since it is no longer needed
    # edx = temp
    # since eax has a copy of b, we can use it to find the actual address of *b
    movl temp(%ebp), %edx # edx = temp
    movl %edx, (%eax) # *b = temp





    epilogue_swap:
        movl %ebp, %esp
        pop %ebp
        ret

    epilogue_swap_end:
swap_end:

editDist: # int editDist(char* word1, char* word2)
    # return value dist will be in eax
    # note: eax, ecx, and edx used in other two functions
    # Assumption: word1_len = word2_len = 100

    #+ 3:  word2
	#+ 2: word1
	# + 1: return address
	#ebp: old ebp
    # - 1: i
    # -2: j

    .equ num_locals, 2

    prologue_edit:
        push %ebp # save old ebp
        movl %esp, %ebp # initialize stack frame
        #make space for locals
        subl $(num_locals) * 4, %esp
        
        .equ word1, (2 * 4) #(%ebp)
        .equ word2, (3 * 4) #(%ebp)
        .equ i, (-1*4) #(%ebp)
        .equ j, (-2*4) #(%ebp)

    prologue_edit_end:
    
    # int word1_len = strlen(word1);
    # int word2_len = strlen(word2);
    # word1_len + 1 and word2_len + 1 used more, so store those instead

    movl $string1, strlen_arg # set the argument
    call my_strlen_mem # result will be in strlen_temp
    movl strlen_temp, %eax # eax = strlen
    incl %eax # strlen + 1
    movl %eax, word1_len # word1_len = word1_len + 1

    movl $string2, strlen_arg # set the argument
    call my_strlen_mem # result will be in strlen_temp
    movl strlen_temp, %eax # eax = strlen
    incl %eax # strlen + 1
    movl %eax, word2_len # word2_len = word2_len + 1

    # create int pointers
    leal oldDist, %eax #eax = address of oldDist
    movl %eax, oldDist_ptr # oldDist_ptr = &(oldDist)
    leal curDist, %edx #eax = address of curDist
    movl %edx, curDist_ptr # curDist_ptr = &(curDist)

    # for(i = 0; i < word2_len + 1; i++)
    # no need to use pointers yet cause same operations apply to both
    
    movl $0, %ecx # ecx = i = 0
    first_for_start:
        # i < word2_len + 1 == i - word2_len+1 < 0
        # negation: i - word2_len + 1 >=0
        cmpl word2_len, %ecx
        jge first_for_end

        #oldDist[i] = i;
        #curDist[i] = i;
        movl %ecx, oldDist(, %ecx, 4)
        movl %ecx, curDist(, %ecx, 4)

        incl %ecx
        jmp first_for_start
    first_for_end:

    # for(i = 1; i < word1_len + 1; i++)
    # need to use pointers since swap function uses them

    movl $1, %ecx # ecx = i = 1
    outer_for_start:
        # i < word1_len + 1 == i - word1_len+1 < 0
        # negation: i - word1_len + 1 >=0    
        cmpl word1_len, %ecx
        jge outer_for_end
        # curDist[0] = i;
        movl curDist_ptr, %eax # eax = *curDist_ptr = curDist
        movl %ecx, (%eax)
        
        # for(j = 1; j < word2_len + 1; j++)
        movl $1, %edx # edx = j = 1
        
        # save ecx and edx (i and j), as min and swap changes them
        # i in outer for loop, j in inner for loop
        # this also frees up these two registers temporarily
        movl %ecx, i(%ebp)

                    
        inner_for_start:
            # j < word2_len + 1 == j - word2_len + 1 < 0
            # negation: j - word2_len + 1 >=0
            cmpl word2_len, %edx
            jge inner_for_end

            /* 
            if(word1[i-1] == word2[j-1]){
                curDist[j] = oldDist[j - 1];
            } 
            */
            # (word1[i-1] == word2[j-1]) == (word1[i-1] - word2[j-1] == 0)
            # negation: word1[i-1] - word2[j-1] != 0
            # use eax to store word1[i-1]
            # save j value
            movl %edx, j(%ebp)
            
            movl word1(%ebp), %edx # edx = word1
            movb -1*1(%edx, %ecx, 1), %al # al = word1[i-1]

            # restore j value
            movl j(%ebp), %edx
            movl word2(%ebp), %ecx #ecx = word2

            cmpb -1*1(%ecx, %edx, 1), %al # word1[i-1] - word2[j-1]
            jnz else_start # go to else portion

 

            if_same_start:
                # i value not necessary within if/else statement, so ecx is open
                # restore edx value
                movl j(%ebp), %edx

                #temporarily use ecx                
                # curDist[j] = oldDist[j - 1]
                movl oldDist_ptr, %ecx # ecx = *(oldDist_ptr) = oldDist
                movl -1*4(%ecx, %edx, 4), %ecx # ecx = oldDist[j-1]

                # reuse eax since no longer needed

                movl curDist_ptr, %eax #eax = *(curDist_ptr) = curDist
                movl %ecx, (%eax, %edx, 4) # curDist[j] = ecx = oldDist[j-1]
                jmp else_end

                #restore i value
                movl i(%ebp), %ecx

            else_start:
                # restore j value
                movl j(%ebp), %edx                
                    
                /*curDist[j] = min(min(oldDist[j], //deletion
                  curDist[j-1]), //insertion
                  oldDist[j-1]) + 1; //subs titution */
                # first get min(oldDist[j], curDist[j-1])
                # place min arguments on stack
                movl oldDist_ptr, %ecx # ecx = *(oldDist_ptr) = oldDist
                movl curDist_ptr, %eax #eax = *(curDist_ptr) = curDist

                push -1*4(%eax, %edx, 4) # curDist[j-1]
                push (%ecx, %edx, 4) # oldDist[j]
                call min # result stored in eax, ecx and edx changed
                addl $2 * 4, %esp # clear two arguments off stack

                # restore values to before function call
                movl j(%ebp), %edx
                movl oldDist_ptr, %ecx # ecx = *(oldDist_ptr) = oldDist
                
                # now get min(min(oldDist[j], curDist[j-1]), oldDist[j-1])
                # which is the same as min(eax, oldDist[j-1])
                push %eax
                push -1*4(%ecx, %edx, 4) #oldDist[j-1]
                call min # result stored in eax, ecx and edx changed
                addl $2 * 4, %esp # clear two arguments off stack
                incl %eax # eax = eax + 1
                
                # restore j value
                movl j(%ebp), %edx                
                #since eax used to store result of min, use ecx for curDist
                movl curDist_ptr, %ecx
                movl %eax, (%ecx, %edx, 4) #curDist[j] = eax
                
                
                # restore i and j values
                movl i(%ebp), %ecx
                movl j(%ebp), %edx
                
            else_end:

            # guarantee: restore ecx and edx values
            movl i(%ebp), %ecx
            movl j(%ebp), %edx
            incl %edx # j++
            jmp inner_for_start #next iteration

        inner_for_end:

        # swap (&oldDist, &curDist);
        # place swap arguments on stack
        # edx free outside inner for loop
        leal oldDist_ptr, %eax #eax = &oldDist_ptr
        push %eax
        leal curDist_ptr, %edx #edx = &curDist_ptr
        push %edx

        call swap
        addl $2 * 4, %esp # clear two arguments off stack
        
        # restore i value
        movl i(%ebp), %ecx
        incl %ecx # i++
        jmp outer_for_start #next iteration
    outer_for_end:

    #dist = oldDist[word2_len]
    # ecx, edx free after outer for loop
    movl word2_len, %ecx # ecx = word2_len + 1
    decl %ecx # ecx = word2_len
    
    movl oldDist_ptr, %edx
    movl (%edx, %ecx, 4), %eax # eax = dist = oldDist[word2_len]


    epilogue:
        movl %ebp, %esp # clear space made on stack for anything
        pop %ebp # restore ebp to original value
        ret
    epilogue_end:
editDist_end:

_start:
    
    # place editDist arguments on stack
    push $string2
    push $string1
    call editDist
    addl $2 * 4, %esp #clear argument from stack

done:
    nop
