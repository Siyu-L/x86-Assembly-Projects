# Siyu Li

.global knapsack
.global max
.equ ws, 4

.text

max: # unsigned int max(unsigned int a, unsigned int b)
    max_prologue_start:
        push %ebp
        movl %esp, %ebp
        
        /* the stack
        ebp + 3: b
        ebp + 2: a
        ebp + 1: ret address
        ebp: old ebp
        */

        .equ A, (2*ws) #(%ebp)
        .equ B, (3*ws) #(%ebp)

    max_prologue_end:

        # eax = A
        # ecx = B
        movl A(%ebp), %eax
        movl B(%ebp), %ecx

        #   return a > b ? a : b;
        /* if (a > b), return a
            else, return b 
         */
        # a > b == a - b > 0
        # negation: a - b <= 0
        cmpl %ecx, %eax # a - b
        jbe max_else_start
        max_if_start:
            # return a, which is already in eax
            jmp max_epilogue
        max_else_start:
            movl %ecx, %eax # eax = b


    max_epilogue:
        # return value in eax

        movl %ebp, %esp
        pop %ebp
        ret



knapsack: 
    /*unsigned int knapsack(int* weights, unsigned int* values, 
        unsigned int num_items, int capacity, unsigned int cur_value)
    */
    # return value will be in eax

    .equ num_locals, 3
    .equ used_ebx, 1
    .equ used_esi, 0
    .equ used_edi, 0
    .equ num_save_regs, (used_ebx + used_esi + used_edi)

    prologue_start:
        push %ebp
        movl %esp, %ebp
        subl $4 * ws, %esp

        /* the stack
        ebp + 6: cur_value
        ebp + 5: capacity
        ebp + 4: num_items
        ebp + 3: values
        ebp + 2: weights
        ebp + 1: ret address
        ebp: old ebp
        ebp - 1: i
        ebp - 2 best_value
        ebp - 3: old_ebx
        ebp - 4: knapsack_next_rec
        */

        .equ weights, (2*ws)        # (%ebp)
        .equ values, (3*ws)         # (%ebp)
        .equ num_items, (4*ws)      # (%ebp)
        .equ capacity, (5*ws)        # (%ebp)
        .equ cur_value, (6*ws)      # (%ebp)

        .equ i, (-1*ws)             # (%ebp)         
        .equ best_value, (-2*ws)    # (%ebp)
        .equ old_ebx, (-3*ws)       # (%ebp)
        .equ knapsack_next_rec, (-4*ws) # (%ebp)
        # save callee saved registers
        movl %ebx, old_ebx(%ebp)

    prologue_end:
    
    # unsigned int best_value = cur_value;
    movl cur_value(%ebp), %eax # eax = cur_value
    movl %eax, best_value(%ebp) # best_value = cur_value

    # for (i = 0; i < num_items; i++)
    # ecx will be i
    movl $0, %ecx # ecx = 0

    for_start:
        # i < num_items == i - num_items < 0
        # negation: i - num_items >= 0
        cmpl num_items(%ebp), %ecx
        jae for_end
        
        // if(capacity - weights[i] >= 0 )
        # weights[i] will be ebx
        # weights[i] = *(weights + i)
        movl weights(%ebp), %ebx # ebx = weights
        movl (%ebx, %ecx, ws), %ebx # ebx = *(weights + i)

        # capacity - weights[i] >= 0
        # negation: capacity - weights[i] < 0
        # note: capacity and weights are both signed
        cmpl %ebx, capacity(%ebp) # capacity - weights[i]
        jl if_end
        if_start:
            /*
            best_value = max(best_value, knapsack(weights + i + 1, values + i + 1, num_items - i - 1, 
                     capacity - weights[i], cur_value + values[i]));
            */
            # eax and edx will be used to push arguments

            # cur_value + values[i]
            movl cur_value(%ebp), %eax # eax = cur_values
            movl values(%ebp), %edx # edx = values
            movl (%edx, %ecx, ws), %edx # edx = *(values + i) = values[i]
            addl %edx, %eax # eax = cur_values + values[i]
            push %eax
            
            # capacity - weights[i]
            movl capacity(%ebp), %eax # eax = capacity
            # note: ebx = weights[i]
            subl %ebx, %eax # eax = capacity - weights[i]
            push %eax

            # num_items - i - 1
            movl num_items(%ebp), %eax # eax = num_items
            subl %ecx, %eax # eax = num_items - i
            decl %eax # eax = num_items - i - 1
            push %eax

            # values + i + 1
            movl values(%ebp), %eax # eax = values
            leal ws(%eax, %ecx, ws), %eax # eax = values + i + 1
            push %eax

            # weights + i + 1
            movl weights(%ebp), %eax # eax = weights
            leal ws(%eax, %ecx, ws), %eax # eax = weights + i + 1
            push %eax

            # save i's current value
            movl %ecx, i(%ebp)
            call knapsack
            addl $5*ws, %esp # clear arguments
            movl %eax, knapsack_next_rec(%ebp)

            # max(best_value, knapsack_next_rec)
            # eax is already knapsack_next_rec
            push %eax
            movl best_value(%ebp), %eax # eax = best_value
            push %eax
            call max
            addl $2*ws, %esp # clear arguments
            movl %eax, best_value(%ebp) # best_value = max(best_value, knapsack_next_rec)
            # restore ecx back to i
            movl i(%ebp), %ecx

        if_end:

        incl %ecx # i++
        jmp for_start # next iteration
    for_end:


    epilogue:
        # set return value
        movl best_value(%ebp), %eax

        # restore callee saved regs
        movl old_ebx(%ebp), %ebx

        movl %ebp, %esp # clear locals and saved reg space
        pop %ebp
        ret

knapsack_end:
