/*
Siyu Li
*/


#include <string>
#include <iostream>
using namespace std;

char get_char_value(unsigned int num) {
    
    /*  Store the right-most bit to see if letter is caps or not
        By using & with the mask 0 followed by 26 1s,
        regardless of whether or not the right-most bit is 0 or 1, right-most bit will become 0 while everything else unaffected
        Note: 1<<26 is 1 followed by 26 0s so every bit is flipped using ~
    */
    int caps = num >> 26;
    num = num & ~(1<<26);
    

    /*  count stores the index of the (1) bit in num
        Since the index will be in the range 0-25, each number corresponding to a letter,
        we will add count to 'a' or 'A' so that the result will be the letter that we want
    */
    int count = 0;
    while(num > 1) {
        num = num >> 1;
        count++;
    }

    //  Using the stored value of caps, decide whether to add the number to A or a and return the result
    if(caps > 0) {
        return ('A' + count);
    }
    else{
        return ('a' + count);
    }
}


int main(int argc, char* argv[]) {
    
    /*  For each argument in argv: 
        convert to int, call the function on it, output the result
    */
    cout << "You entered the word: ";
    for (int i = 1; i < argc; i++) {
        unsigned int n = atoi(argv[i]);
        char temp = get_char_value(n);
        cout << temp;
    }

    cout<<endl;
    return 0;
}