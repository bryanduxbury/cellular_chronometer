package org.bryanduxbury.atavise;

import java.util.ArrayList;
import java.util.List;

public class HierarchicalDuparcGridAtaviser implements GridAtaviser {
  private final RowAtaviser rowAtaviser;

  public HierarchicalDuparcGridAtaviser(RowAtaviser rowAtaviser) {
    this.rowAtaviser = rowAtaviser;
  }

  @Override public List<int[]> atavise(int cols, int rows, int[] grid) {
    List<int[]> results = internalAtavise(cols, rows, grid, 0, grid.length);
    return results;
  }

  private List<int[]> internalAtavise(int cols, int rows, int[] grid, int startRow, int endRow) {
    System.out.println("[" + startRow + ", " + endRow + ")");
    if (endRow - startRow == 1) {
      // cool, down to one row
      // row-atavise it
      List<int[]> rowPriors = rowAtaviser.atavise(cols + 2, grid[startRow] << 1);
      return rowPriors;
    }

    int mid = (endRow - startRow) / 2 + startRow;

    List<int[]> topPriors = internalAtavise(cols, rows, grid, startRow, mid);
    List<int[]> bottomPriors = internalAtavise(cols, rows, grid, mid, endRow);

    List<int[]> newSolutions = new ArrayList<int[]>();

    for (int[] top : topPriors) {
      for (int[] bottom : bottomPriors) {
        if (top[top.length-2] == bottom[0] && top[top.length-1] == bottom[1]) {
          newSolutions.add(merge(top, bottom));
        }
      }
    }

    return newSolutions;
  }

  private static int[] merge(int[] top, int[] bottom) {
    int[] ret = new int[top.length + bottom.length - 2];
    System.arraycopy(top, 0, ret, 0, top.length);
    System.arraycopy(bottom, 2, ret, top.length, bottom.length - 2);
    return ret;
  }
}
