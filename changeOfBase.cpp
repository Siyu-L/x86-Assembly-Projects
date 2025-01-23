/*
Siyu Li
*/

#include <string>
#include <math.h>
#include <iostream>
using namespace std;



/*converts a number (n) in base (orig_b) to decimal
For each letter in the string, convert to integer value, then convert to base ten
*/
unsigned int to_base_ten(string n, int orig_b) {
    unsigned int base_ten = 0;
    int exp = n.length()-1;
    for(unsigned int i = 0; i < n.length(); i++) {
        int temp;
        if(isdigit(n[i])) {
            temp = n[i] - '0';
        }
        else {
            temp = (n[i] - 'A' ) + 10;
        }
        base_ten += temp * pow(orig_b, exp);
        exp--;
    }
    
    return base_ten;
}

/*converts decimal number (num_ten) to number in base (new_b)
Converts each int base ten value to new base, converting some numbers into letters if necessary
Since each remainder is added to the string to the right but should be the next left digit, the string must be reversed
*/
string ten_to_new_base(unsigned int num_ten, int new_b) {
    string new_num = "";

    while(num_ten > 0) {
        int temp = (num_ten % new_b);
        char temp_char = temp;

        if (temp > 9) {
            temp_char = (temp - 10) + 'A';
            new_num += temp_char;
        }
        else {
            new_num += to_string(temp);
        }
        num_ten /= new_b;
    }
    
    string reverse_num(new_num.rbegin(), new_num.rend());
    return reverse_num;
}

/*converts number (n) in (orig_b) to (new_b)
Changes base of number by converting to base ten, then converting the base ten value to new base
*/
string change_base(string n, int orig_b, int new_b) {
    unsigned int temp_ten = to_base_ten(n, orig_b);
    return ten_to_new_base(temp_ten, new_b);

}


int main() {
    int base;
    string num;
    int new_base;
    string new_num;
    cout<<"Please enter the number's base: ";
    cin>>base;
    cout<<"Please enter the number: ";
    cin>>num;
    cout<<"Please enter the new base: ";
    cin>>new_base;
    
    //Convert all letters in given number to uppercase
    for(unsigned int i = 0; i < num.length(); i++) {
        num[i] = toupper(num[i]);
    }
        for(unsigned int i = 0; i < new_num.length(); i++) {
        new_num[i] = toupper(num[i]);
    }

    //Changes the base
    new_num = change_base(num, base, new_base);
    cout<<num<<" base " <<base<<" is " << new_num << " base " <<new_base;
    


}