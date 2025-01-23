#include <string>
#include <iostream>
using namespace std;

//Converts float (cast to int) to scientific base 2 format
string float_to_scientific(unsigned int flt_int) {
    unsigned int sign = (flt_int>>31) & (0b1); //left-most bit represent the sign
    unsigned int exponent = (flt_int>>23) & (0b11111111); //next 8 bits represent exponent
    unsigned int mantissa = flt_int & ~(0<<22); //remaining 23 bits represent mantissa
    int mant_index = 22;

    string output = "";

    if(sign == 1) {
        output += "-";
    }
    output += "1.";

    //Read bits of mantissa to the string output using mant_index
    while(mant_index >= 0) {
        if(mantissa & (1<<mant_index)) {
            output += "1";
        }
        else {
            output += "0";
        }
        mant_index --;
    }

    //Count and get rid of all trailing zeros
    int count = 0;
    while(output[output.length() - 1 - count] == '0') {
        count++;
    }
    output.resize(output.length() - count);


    output += "E" + to_string(exponent-127);
    return output;

}

int main() {
    float f;
    cout<<"Please enter a float: ";
    cin>>f;
    unsigned int float_int = *((unsigned int*)&f);
    cout<< float_to_scientific(float_int);

}