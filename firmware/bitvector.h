
#ifndef __BITVECTOR_H__
#define __BITVECTOR_H__

boolean test(uint8_t* vect, uint8_t bitIdx) {
  return (vect[bitIdx / 8] & (1 << (bitIdx % 8))) != 0;
}

void set(uint8_t* vect, uint8_t bitIdx) {
  vect[bitIdx / 8] |= (1 << (bitIdx % 8));
}

#endif
