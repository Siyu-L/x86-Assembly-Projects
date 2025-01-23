// Siyu Li

#include "MyFloat.h"

MyFloat::MyFloat(){
  sign = 0;
  exponent = 0;
  mantissa = 0;
}

MyFloat::MyFloat(float f){
  unpackFloat(f);
}

MyFloat::MyFloat(const MyFloat & rhs){
	sign = rhs.sign;
	exponent = rhs.exponent;
	mantissa = rhs.mantissa;
}

ostream& operator<<(std::ostream &strm, const MyFloat &f){
	//this function is complete. No need to modify it.
	strm << f.packFloat();
	return strm;
}


MyFloat MyFloat::operator+(const MyFloat& rhs) const{
	MyFloat outFloat = MyFloat();
  // Get actual values of exponents
  int rhs_exp = rhs.exponent - 127;
  int lhs_exp = exponent - 127;
  int out_exp;

  //Add leading one to the mantissas
  unsigned int rhs_val = (rhs.mantissa | 1<<23); // rhs_val = 1.mantissa
  unsigned int lhs_val = (mantissa | 1<<23); // lhs_val = 1.mantissa


  // increase the smaller exponent until it matches larger one
  //    right shift mantissa corresponding with difference between exponents
  
  // last_bit stores the most significant bit shifted out   
  //    if the most significant bit SHIFTED OUT is 1, then subtract 1 to the mantissa
  //    store that most significant bit here as last_bit

  unsigned int last_bit = 0;
  if(rhs_exp < lhs_exp) {
      while(rhs_exp < lhs_exp) {
        last_bit = rhs_val & (0b1);
        rhs_val = rhs_val >> 1; // same as dividing number by 2
        rhs_exp++; // same as multiplying number by 2, so cancels out
      }
      if(last_bit == 0) {
        rhs_val--;
      }

  }
  else {
      while(lhs_exp < rhs_exp) {
        last_bit = lhs_val & (0b1);
        lhs_val = lhs_val >> 1; // same as dividing number by 2
        lhs_exp++; // same as multiplying number by 2, so cancels out
      }
      if(last_bit == 0) {
        lhs_val--;
      }      

  }
  out_exp = lhs_exp; //shouldn't matter left or right since they should be equal now
  
  // now that rhs_exp == lhs_exp, only need to compare sign and values
 
  unsigned int mant;

  if(rhs.sign == sign) { // if both negative or both positive
    outFloat.sign = rhs.sign; // then result will have same sign as operands
    mant = rhs_val + lhs_val;
  }
  else if(rhs_val > lhs_val){
    // if signs are different AND rhs value larger than lhs value
    // if rhs is negative/positive, result is also negative/positive
    outFloat.sign = rhs.sign;
    mant = rhs_val - lhs_val; // result will be a value that includes the 1 in the front
  }
  else if(lhs_val > rhs_val) {
    // if signs are different AND lhs value larger than rhs value
    outFloat.sign = sign;
    mant = lhs_val - rhs_val; // result will be a value that includes the 1 in the front
  }
  else { // signs are different but value is same means result is 0
    outFloat.sign = 0;
    outFloat.exponent = 0;
    outFloat.mantissa = 0;
    return outFloat;

  }
  
  // find length of mant, since we want to be length 24 (23 plus leading 1)
  unsigned int temp = mant;
  int len = 0;
  while(temp != 0) {
    temp = temp >> 1;
    len++;
  }

  
  //Find the difference between len and 24
  // if len is greater than 24, need to rightshift, increase exp accordingly
  // if len is smaller than 24, need to leftshift, decrease exp accordingly

  int diff = len - 24;
  if(diff > 0) { //len greater than 24
    for(int i = 0; i<diff; i++) {
      mant = mant >> 1;
      out_exp++;
    }
  }
  if(diff < 0) { // len less than 24
    diff *= -1; //make diff positive
    for(int i = 0; i<diff; i++) {
      mant = mant << 1;
      out_exp--;
    }
  }

  //restore leading 1 added earlier back to 0 as we no longer need it
  mant = mant & ~(1<<23);
  



  // Set return values
  outFloat.exponent = out_exp + 127;
  outFloat.mantissa = mant;


	return outFloat;
}

MyFloat MyFloat::operator-(const MyFloat& rhs) const{
	MyFloat temp = MyFloat(rhs);
  // negate float
  if(temp.sign == 0) {
    temp.sign = 1;
  }
  else {
    temp.sign = 0;
  }
  MyFloat outFloat = *this + temp;
	return outFloat;
}

bool MyFloat::operator==(const float rhs) const{
	MyFloat rhs_float(rhs);
  return ((sign == rhs_float.sign) && (exponent == rhs_float.exponent) && (mantissa == rhs_float.mantissa));
  
}



/*
The syntax for inlined assembly is
__asm__(
assembly code :
outputs :
inputs :
clobbered );

outputs, inputs, and clobbered are all optional

*/

void MyFloat::unpackFloat(float f) {
    //this function must be written in inline assembly
    //extracts the fields of f into sign, exponent, and mantissa
    __asm__(
      "movw $(1<<8) | 31, %%cx;" // read 1 bit starting from bit 31
      "bextr %%ecx, %[f], %[sign];"
      "movw $(8<<8) | 23, %%cx;" // read 8 bits starting from bit 23
      "bextr %%ecx, %[f], %[exponent];"
      "movw $(23<<8) | 0, %%cx;" // read 23 bits starting from 0
      "bextr %%ecx, %[f], %[mantissa];" :
      [sign] "=&r" (sign), [exponent] "=&r" (exponent), [mantissa] "=&r" (mantissa):
      [f] "r" (f) :
      "cc", "%ecx"
    );

}//unpackFloat

float MyFloat::packFloat() const{
    //this function must be written in inline assembly
    //returns the floating point number represented by this
    float f = 0;
    __asm__(
      "shl $31, %[sign];" // sign = (sign << 31)
      "shl $23, %[exponent];" // exponent = (exponent << 23)
      // mantissa already in correct bit position
      "movl $0, %[f];" //f = 0
      "or %[sign], %[f];" //f = 0 | (sign << 31) = (sign << 31)
      "or %[exponent], %[f];" // f = (sign << 31) | (exponent << 23)
      "or %[mantissa], %[f];" // f = (sign << 31) | (exponent << 23) | mantissa
        :
      [f] "=&r" (f):
      [sign] "r" (sign), [exponent] "r" (exponent), [mantissa] "r" (mantissa):
      "cc"
    );

    return f;
}//packFloat
//



