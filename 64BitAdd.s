#Siyu Li

.global _start
.data

num1:
    .long 0
    .long 0
num2:
    .long 0
    .long 0

.text

_start:

# edx stores upper 32 bits
# eax stores lower 32 bits
# upper 32 bits of x is x[0] = *(x)
# lower 32 bits of x is x[1] = *(x + 1)
# 4 bytes in a long

movl num1, %edx
movl num1 + 1*4, %eax

# add num2 to num1, stored in edx and eax

addl num2, %edx # num1 (upper 32) += num2 (upper 32)
addl num2 + 1*4, %eax # num1 (lower 32) += num2 (lower 32)

# check if lower 32 bits exceeds max (signed -1): eax < 0
# negation: eax >= 0
jge end_if # if lower bits does not exceed, skip code within if

if_carry:
incl %edx # increment upper 32 bits to account for carry
end_if:

done:
    nop
