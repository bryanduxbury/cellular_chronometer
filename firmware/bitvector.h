
#ifndef __BITVECTOR_H__
#define __BITVECTOR_H__

boolean test(uint8_t* vect, uint8_t bitNum) {
  return vect[bitNum / 8] & (1 << (bitNum % 8));
}

void set(uint8_t* vect, uint8_t bitNum) {
  vect[bitNum / 8] |= (1 << (bitNum % 8));
}

#endif
