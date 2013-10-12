package org.bryanduxbury.atavise;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
    if (endRow - startRow == 1) {
      // cool, down to one row
      // row-atavise it
      List<int[]> rowPriors = rowAtaviser.atavise(cols + 2, grid[startRow] << 1);
      return rowPriors;
      //return index(rowPriors);
    }

    // compute the midpoint for recursing
    int mid = (endRow - startRow) / 2 + startRow;

    // compute the top half
    List<int[]> topPriors = internalAtavise(cols, rows, grid, startRow, mid);
    // index the results by the bottom-most rows (while uniqueing by the topmost rows)
    Map<TwoInts, Map<TwoInts, int[]>> topsByBottom =
        indexBy(topPriors, mid - startRow, mid - startRow + 1, 0, 1);
    topPriors = null;

    // compute the results for the bottom half
    List<int[]> bottomPriors = internalAtavise(cols, rows, grid, mid, endRow);
    // index the results by the bottom-most rows (while uniqueing by the topmost rows)
    Map<TwoInts, Map<TwoInts, int[]>> bottomsByTops =
        indexBy(bottomPriors, 0, 1, endRow - mid, endRow - mid + 1);
    bottomPriors = null;

    // compute the intersection of all tops and bottoms
    List<int[]> newSolutions = new ArrayList<int[]>();

    // for each unique bottom in the top set...
    OUTER:
    for (Map.Entry<TwoInts, Map<TwoInts, int[]>> top : topsByBottom.entrySet()) {
      // ... get the set of matching solutions in the bottom set ...
      Map<TwoInts, int[]> matchingBottoms = bottomsByTops.get(top.getKey());
      // ... if there are any matches ...
      if (matchingBottoms != null) {
        // ... then for each unique top in the tops with matching bottoms ...
        for (int[] left : top.getValue().values()) {
          // ... and for each unique bottom in bottoms with matching tops ...
          for (int [] right : matchingBottoms.values()) {
            // ... add a new solution to the result set
            newSolutions.add(merge(left, right));
            if (newSolutions.size() == 100000) {
              break OUTER;
            }
          }
        }
      }
    }

    // if the number of solutions has gotten bigger than 100K, trim it.
    if (newSolutions.size() > 100000) {
      newSolutions = newSolutions.subList(0, 100000);
    }

    return newSolutions;
  }

  static Map<TwoInts, Map<TwoInts, int[]>> indexBy(List<int[]> solns, int a, int b, int c, int d) {
    Map<TwoInts, Map<TwoInts, int[]>> indexed = new HashMap<TwoInts, Map<TwoInts, int[]>>();

    for (int[] soln : solns) {
      TwoInts x = new TwoInts(soln[a], soln[b]);
      TwoInts y = new TwoInts(soln[c], soln[d]);
      Map<TwoInts, int[]> ys = indexed.get(x);
      if (ys == null) {
        ys = new HashMap<TwoInts, int[]>();
        indexed.put(x, ys);
      }
      ys.put(y, soln);
    }

    return indexed;
  }

  private static int[] merge(int[] top, int[] bottom) {
    int[] ret = new int[top.length + bottom.length - 2];
    System.arraycopy(top, 0, ret, 0, top.length);
    System.arraycopy(bottom, 2, ret, top.length, bottom.length - 2);
    return ret;
  }

  // benchmarking only!
  public static void main(String[] args) {
    HierarchicalDuparcGridAtaviser a =
        new HierarchicalDuparcGridAtaviser(new IntersectingRowAtaviser(new TubularRowFilter()));
    long startTime = System.currentTimeMillis();
    //for (int trial = 0; trial < 10; trial++) {
      for (int i = 0; i < 1; i++) {
        a.atavise(5, 25, new int[]{0, 0, 31, 17, 31, 0, 0, 18, 31, 16, 0, 0, 10, 0, 0, 31, 17, 31, 0, 0, 18, 31, 16, 0, 0});
      }
    //}

    long endTime = System.currentTimeMillis();
    System.out.println(endTime-startTime);
  }
}
