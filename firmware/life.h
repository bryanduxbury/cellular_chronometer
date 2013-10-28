
#ifndef __LIFE_H__
#define __LIFE_H__

#include "bitvector.h"

#define NUM_ROWS 25
#define NUM_COLS 5

// #define XY2ORD(x, y) ((x) + (y) * NUM_COLS)

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

#define SURROUNDING_ROW_MASK 7
#define SAME_ROW_MASK 5

bool test8(uint8_t *rows, uint8_t rowIdx, uint8_t colIdx) {
  return (rows[rowIdx] & (((uint8_t)1) << colIdx)) != 0;
}

// #define TEST32(rows, rowIdx, colIdx) (((rows)[(rowIdx)] & (((uint32_t)1) << (colIdx))) != 0)

void set8(uint8_t *rows, uint8_t rowIdx, uint8_t colIdx) {
  rows[rowIdx] |= (((uint8_t)1) << colIdx);
}

// #define SET32(rows, rowIdx, colIdx) ((rows)[(rowIdx)] |= (((uint32_t)1) << (colIdx)))

uint8_t do_lookup8(uint8_t row, uint8_t colIdx, uint8_t mask) {
  return lookup[(row >> (colIdx - 1)) & mask];
}

// #define DO_LOOKUP(row, colIdx, mask) (lookup[((row) >> ((colIdx) - 1)) & (mask)])


// To simulate playing the Game of Life on a toroidal grid, we're going to
// doctor the input grid such that we can play the regular finite grid GoL
// and get a toroidal result. We do this by expanding the original grid by one
// cell in each direction, then copying the top actual row to the new synthetic
// bottom row, then likewise with the bottom to top and left and right. This 
// effectively gives the original top, bottom, left, and right rows access to 
// the proper set of neighbors for the GoL calculation to go forward.
void make_toroidal(uint8_t* rows) {
  uint8_t rowmask = 0;
  // build up the mask we'll use to screen out previous generations' toroidal aliases
  for (int x = 1; x <= NUM_COLS; x++) {
    rowmask |= (1 << x);
  }

  // make each row a "tube" by making the outside (alias) cells match the 
  // opposite edge's actual cell
  for (int y = 1; y <= NUM_ROWS; y++) {
    rows[y] = 
      (rows[y] & rowmask) |
      ((rows[y] & 0x02) == 0 ? 0 : (1 << (NUM_COLS + 1))) |
      ((rows[y] & (1 << NUM_COLS)) == 0 ? 0 : 1);
  }

  // finally, join the "ends" of the tube by making alias rows
  rows[0] = rows[NUM_ROWS];
  rows[NUM_ROWS+1] = rows[1]; 
}

void next_generation8(uint8_t *inRows, uint8_t *outRows) {
  make_toroidal(inRows);
  memset(outRows, 0, NUM_ROWS+2);
  for (int y = 1; y <= NUM_ROWS; y++) {
    uint8_t rowAbove = inRows[y-1];
    uint8_t rowSame = inRows[y];
    uint8_t rowBelow = inRows[y+1];
    for (int x = 1; x <= NUM_COLS; x++) {
      uint8_t living_neighbors = 
          do_lookup8(rowAbove, x, SURROUNDING_ROW_MASK)
        + do_lookup8(rowSame, x, SAME_ROW_MASK)
        + do_lookup8(rowBelow, x, SURROUNDING_ROW_MASK);
      if (test8(inRows, y, x)) {
        if (living_neighbors == 2 || living_neighbors == 3) {
          set8(outRows, y, x);
        }
      } else {
        if (living_neighbors == 3) {
          set8(outRows, y, x);
        }
      }
    }
  }
}

#endif
