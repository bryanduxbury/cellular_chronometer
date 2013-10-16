package org.bryanduxbury.atavise.solution_filter;

/**
 * matches what's currently on the ruby side. not general to all solutions!
 */
public class HackyTubeFilter implements SolutionFilter{
  @Override public boolean keep(int rowWidth, int[] rows) {
    for (int y = 0; y < rows.length; y++) {
      int row = rows[y];
      if ((row & 0x01) != ((row >> 5) & 0x01) || ((row >> 1) & 0x01) != ((row >> 6) & 0x01)) {
        return false;
      }
    }
    return true;
  }
}
