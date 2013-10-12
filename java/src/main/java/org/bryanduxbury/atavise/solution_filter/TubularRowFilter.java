package org.bryanduxbury.atavise.solution_filter;

import org.bryanduxbury.atavise.solution_filter.SolutionFilter;

public class TubularRowFilter implements SolutionFilter {
  @Override public boolean keep(int rowWidth, int[] rows) {
    for (int i = 0; i < 3; i++) {
      int a = rows[i] & 0x1;
      int b = (rows[i] >> 1) & 0x1;
      int c = (rows[i] >> (rowWidth - 2)) & 0x1;
      int d = (rows[i] >> (rowWidth - 1)) & 0x1;
      if (!(a == c && b == d)) {
        return false;
      }
    }
    return true;
  }
}
