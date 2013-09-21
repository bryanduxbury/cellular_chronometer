
#ifndef __LIFE_H__
#define __LIFE_H__

#include "bitvector.h"

#define NUM_ROWS 5
#define NUM_COLS 25

#define XY2ORD(x, y) ((x) + (y) * NUM_COLS)

// using B3/S23 rules
// inLow + inHigh is a 128-bit bitvector containing the initial state
// outLow + outHigh are pointers to 128-bit bitvectors to store the result
void next_generation(uint64_t inLow, uint64_t inHigh, uint64_t* outLow, uint64_t* outHigh) {
  for (int y = 0; y < NUM_ROWS; y++) {
    for (int x = 0; x < NUM_COLS; x++) {
      // count living neighbors
      int living_count = 0;
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++){
          // all the extra bounds checking deals with running off the edge of the border in either direction
          // plus ignoring self
          if (dx + x >= 0 && dx + x < NUM_COLS && dy + y >= 0 && dy + y < NUM_ROWS && !(dx == 0 && dy == 0)) {
            if (test(inLow, inHigh, XY2ORD(x,y))) {
              living_count++;
            }
          }
        }
      }

      if (test(inLow, inHigh, XY2ORD(x,y)) && (living_count == 2 || living_count == 3)) {
        // cell lives in next iteration
        set(outLow, outHigh, XY2ORD(x,y));
      } else if(!test(inLow, inHigh, XY2ORD(x,y)) && living_count == 3) {
        // cell is birthed in next iteration
        set(outLow, outHigh, XY2ORD(x,y));
      }
    }
  }
}

#endif
