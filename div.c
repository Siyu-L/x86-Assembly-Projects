/*
Siyu Li
*/
#include <stdio.h>
#include <stdlib.h>


int main(int argc, char* argv[]) {
    //Get the strings from command line and convert to int
    unsigned int dividend = strtoul(argv[1], NULL, 10);
    unsigned int divisor = strtoul(argv[2], NULL, 10);

    unsigned int result = 0;
    //curr_div stores the working portion of the dividend
    unsigned int curr_div = dividend >> 31;

    //iterate over each digit of the integer
    for(int i = 31; i >= 0; i--) {
        //leftshift the result to create room for the next digit
        result = result << 1;
        
        /*if divisor goes into curr_div, since it's binary, it only goes in once, so put 1 in the result
            then, subtract divisor from the curr_div (working portion of dividend)
        */
        if(curr_div >= divisor) {
            result |= (0b1);
            curr_div -= divisor;
        }
        /*If it is the last digit of the integer, 
            don't leftshift curr_div to make room for the next digit*/
        if (i == 0) {
            break;
        }
        /*form new working portion by copying down the next digit of dividend
            to do this, left shift curr_div by 1, and set that bit to the next digit in dividend
        */
        curr_div = (curr_div << 1) | ((dividend >> (i-1)) & (0b1)); //(dividend >> i -1) & (0b1) should give only the next right digit of dividend

    }
    printf("%u / %u = %u R %u", dividend, divisor, result, curr_div);

    return 0;
}