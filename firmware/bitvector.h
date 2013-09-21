
#ifndef __BITVECTOR_H__
#define __BITVECTOR_H__

boolean test(uint64_t bvLow, uint64_t bvHigh, uint8_t bitNum) {
  if (bitNum >= 64) {
    return bvHigh & (1 << (bitNum - 64));
  } else {
    return bvLow & (1 << bitNum);
  }
}

void set(uint64_t* bvLow, uint64_t* bvHigh, uint8_t bitNum) {
  if (bitNum >= 64) {
    *bvHigh &= (1 << (bitNum - 64));
  } else {
    *bvLow &= (1 << bitNum);
  }
}

#endif
