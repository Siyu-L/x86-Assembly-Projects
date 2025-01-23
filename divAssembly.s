# Siyu Li

.global _start
.data

dividend:
    .long 0
divisor:
    .long 0

.text

_start:
    # ebx = divisor
    # eax = result
    movl divisor, %ebx
    movl $0, %eax

    # edx = working portion of dividend, which will become remainder later
    #    unsigned int curr_div = dividend >> 31;
    # unsigned -> logical right shift (bring in 0s)
    movl dividend, %edx
    shr $31, %edx



    # for(int i = 31; i >= 0; i--)
    # ecx = i (counter) = 31
    movl $31, %ecx
    for_start:
    # negation of i >= 0: i < 0
    # jump to end of for loop if condition not met
    cmpl $0, %ecx
    jb for_end
    # result = result << 1
    shl $1, %eax
    
    /*
    if(curr_div >= divisor) {
         result |= (0b1);
         curr_div -= divisor;
    }    
    */
    # (curr_div >= divisor) == (curr_div - divisor >= 0)
    # negation: curr_div - divisor < 0
    # jump to end of if statement if condition is not met
    cmpl %ebx, %edx
    jb if_end
    if_start:
        or $0b1, %eax
        sub %ebx, %edx
    if_end:

    /*
    if (i == 0) {
        break;
    }
    */
    # negation: i != 0
    # jump to end of if statement if condition is not met
    cmpl $0, %ecx
    jnz if_zero_end
    if_zero_start:
        jmp for_end;
    if_zero_end:

    # curr_div = (curr_div << 1) | ((dividend >> (i-1)) & (0b1)); 
    # separate operation into 3 parts:
    #   1. (dividend >> i-1) & (0b1)
    #   2. curr_div << 1
    #   3. curr_div = (part 1) | (part 2)
    # set temporary variables to dividend and curr_div, then perform operations
    # esi = part 1
    # edi = part 2

    # Part 1
    movl dividend, %esi # esi = dividend
    # temporarily subtract 1 from ecx
    sub $1, %ecx # ecx = i - 1
    shr %ecx, %esi # esi = esi >> (i - 1)
    and $0b1, %esi # esi = esi & (0b1)

    # Part 2
    movl %edx, %edi # edi = curr_div
    shl $1, %edi # edi = edi << 1

    # Part 3
    or %esi, %edi # edi = edi | esi
    movl %edi, %edx # edx = edi
    
    # restore ecx back to original value
    add $1, %ecx


    decl %ecx # i--
    jmp for_start
    for_end:


done:
    nop
