
#ifndef __LIFE_H__
#define __LIFE_H__

#include "bitvector.h"

#define NUM_ROWS 5
#define NUM_COLS 25

#define XY2ORD(x, y) ((x) + (y) * NUM_COLS)


uint8_t living_neighbors(uint8_t* vect, uint8_t x, uint8_t y);

// using B3/S23 rules
// inLow + inHigh is a 128-bit bitvector containing the initial state
// outLow + outHigh are pointers to 128-bit bitvectors to store the result
void next_generation(uint8_t* inState, uint8_t* outState) {
  for (int y = 0; y < NUM_ROWS; y++) {
    for (int x = 0; x < NUM_COLS; x++) {
      // count living neighbors
      uint8_t living_count = living_neighbors(inState, x, y);

      if (test(inState, XY2ORD(x,y))) {
        if (living_count == 2 || living_count == 3) {
          // cell lives in next iteration
          set(outState, XY2ORD(x,y));
        }
      } else {
        if (living_count == 3) {
          // cell is birthed in next iteration
          set(outState, XY2ORD(x,y));
        }
      }
    }
  }
}

uint8_t living_neighbors(uint8_t* vect, uint8_t x, uint8_t y) {
  uint8_t living_count = 0;
  for (int dy = -1; dy <= 1; dy++) {
    for (int dx = -1; dx <= 1; dx++) {
      if (dx == 0 && dy == 0) {
        continue;
      }
      if (dx + x < 0 || dx + x >= NUM_COLS) {
        continue;
      }
      if (dy + y < 0 || dy + y >= NUM_ROWS) {
        continue;
      }

      if (test(vect, XY2ORD(dx + x, dy + y))) {
        living_count++;
      }
    }
  }
  return living_count;
}

// map from set bits to number of bits set for 0-7
const uint8_t lookup[] = {
  0, // 000
  1, // 001
  1, // 010
  2, // 011
  1, // 100
  2, // 101
  2, // 110
  3  // 111
};

// const uint8_t lookup[] = {
//   1, // 000
//   1, // 001
//   1, // 010
//   1, // 011
//   1, // 100
//   1, // 101
//   1, // 110
//   1  // 111
// };


const uint32_t mask1 = 7;
const uint32_t mask2 = 5;

// uint32_t scratch[NUM_ROWS+2] = {0}

bool test32(uint32_t *rows, uint8_t rowIdx, uint8_t colIdx) {
  return (rows[rowIdx] & (((uint32_t)1) << colIdx)) != 0;
}

void set32(uint32_t *rows, uint8_t rowIdx, uint8_t colIdx) {
  rows[rowIdx] |= (((uint32_t)1) << colIdx);
}

uint8_t do_lookup(uint32_t row, uint8_t colIdx, uint32_t mask) {
  return lookup[(row >> (colIdx - 1)) & mask];
}

void next_generation32(uint32_t *inRows, uint32_t *outRows) {
  // calculate living neighbors
  for (int y = 1; y <= NUM_ROWS; y++) {
    for (int x = 1; x <= NUM_COLS; x++) {
      uint8_t living_neighbors = do_lookup(inRows[y-1], x, mask1) // row above
        + do_lookup(inRows[y], x, mask2) // same row
        + do_lookup(inRows[y+1], x, mask1); // row below
      if (test32(inRows, y, x)) {
        if (living_neighbors == 2 || living_neighbors == 3) {
          set32(outRows, y, x);
        }
      } else {
        if (living_neighbors == 3) {
          set32(outRows, y, x);
        }
      }
    }
  }
}

#endif
