
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

#endif
