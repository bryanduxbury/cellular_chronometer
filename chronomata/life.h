
#ifndef __LIFE_H__
#define __LIFE_H__

#include "bitvector.h"

#define NUM_ROWS 5
#define NUM_COLS 25

#define XY2ORD(x, y) ((x) + (y) * NUM_COLS)

void next_generation(uint64_t inLow, uint64_t inHigh, uint64_t* outLow, uint64_t* outHigh, uint8_t numRows, uint8_t numCols) {
  for (int y = 0; y < numRows; y++) {
    for (int x = 0; x < numCols; x++) {
      int living_count = 0;
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++){
          if (dx + x >= 0 && dx + x < numCols && dy + y >= 0 && dy + y < numRows && !(dx == 0 && dy == 0)) {
            if (test(inLow, inHigh, XY2ORD(x,y))) {
              living_count++;
            }
          }
        }
      }

      if (test(inLow, inHigh, y * numCols + x) && (living_count == 2 || living_count == 3)) {
        // cell lives in next iteration
        set(outLow, outHigh, y * numCols + x);
      } else if(!test(inLow, inHigh, XY2ORD(x,y)) && living_count == 3) {
        // cell is birthed in next iteration
        set(outLow, outHigh, y * numCols + x);
      }
    }
  }
}

#endif
