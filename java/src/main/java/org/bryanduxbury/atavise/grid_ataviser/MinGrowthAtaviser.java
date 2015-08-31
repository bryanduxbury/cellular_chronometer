package org.bryanduxbury.atavise.grid_ataviser;

import org.bryanduxbury.atavise.Grid;
import org.bryanduxbury.atavise.row_ataviser.RowAtaviser;
import org.bryanduxbury.atavise.solution_limiter.Aggressive;
import org.bryanduxbury.atavise.solution_limiter.SolutionLimiter;
import org.bryanduxbury.atavise.util.TwoInts;

import java.util.*;

/**
 * Atavise in a breadth-first fashion by:
 * 1) atavise each row and place it into a "row group"
 * 2) add all row groups to an ordered list
 * 3) select the two rowgroups with the lowest number of combined prior states
 * 4) merge the two selected rowgroups and replace them with the new merged one
 * 5) go to (3) and repeat until there is 1 row group.
 */
public class MinGrowthAtaviser implements GridAtaviser {
  private final RowAtaviser rowAtaviser;
  private SolutionLimiter.Factory solnLimiterFactory;

  public MinGrowthAtaviser(RowAtaviser rowAtaviser, SolutionLimiter.Factory solnLimiterFactory) {
    this.rowAtaviser = rowAtaviser;
    this.solnLimiterFactory = solnLimiterFactory;
  }

  @Override
  public Collection<int[]> atavise(Grid grid) {
    List<List<int[]>> rowGroups = ataviseRows(grid);

    while (rowGroups.size() > 1) {
      int minGroupIdx = getMinPairIdx(rowGroups);

      // remove original rowGroups
      List<int[]> lhs = rowGroups.remove(minGroupIdx);
      List<int[]> rhs = rowGroups.remove(minGroupIdx);

      // merge into a sinle rowgroup composed of mutual solutions
      List<int[]> mutual = findMutualSolutions(lhs, rhs);

      if (mutual.isEmpty()) {
        // there were no mutual solutions that allowed for merging the two row groups. oh no!
        // return early with a failure.
        return Collections.emptyList();
      }

      // put the merged, mutual solutions back into the rowGroups array in place of the old pair
      rowGroups.add(minGroupIdx, mutual);
      System.err.println();
    }

    return rowGroups.get(0);
  }

  private List<int[]> findMutualSolutions(List<int[]> lhs, List<int[]> rhs) {
    // index the top by the bottom-most rows
    int lhsHeight = getHeight(lhs);
    Map<TwoInts, Map<TwoInts, Collection<int[]>>> topsByBottom =
      indexBy(lhs, lhsHeight - 2, lhsHeight - 1, 0, 1);

    // index the bottom by the top-most rows
    int rhsHeight = getHeight(rhs);
    Map<TwoInts, Map<TwoInts, Collection<int[]>>> bottomsByTops =
      indexBy(rhs, 0, 1, rhsHeight - 2, rhsHeight - 1);

    // compute the intersection of all tops and bottoms
    SolutionLimiter sl = solnLimiterFactory.getSolutionLimiter();

    // for each unique bottom in the top set...
    int count = 0;
    OUTER:
    for (Map.Entry<TwoInts, Map<TwoInts, Collection<int[]>>> top : topsByBottom.entrySet()) {
      // ... get the set of matching solutions in the bottom set ...
      Map<TwoInts, Collection<int[]>> matchingBottoms = bottomsByTops.get(top.getKey());
      // ... if there are any matches ...
      if (matchingBottoms != null) {
        // ... then for each unique top in the tops with matching bottoms ...
        for (Collection<int[]> left : top.getValue().values()) {
          for (int[] leftleft : left) {
            // ... and for each unique bottom in bottoms with matching tops ...
            for (Collection<int[]> right : matchingBottoms.values()) {
              for (int[] rightright : right) {
                // ... add a new solution to the result set
                int[] merged = merge(leftleft, rightright);
                sl.add(merged);
                if (count % 1000000 == 0) {
                  System.err.print(".");
                }

                if (sl.isFull()) {
                  //System.out.println("hit the hardlimit");
                  break OUTER;
                }
              }
            }
          }
        }
      }
    }
    System.err.println();

    return sl.getSolutions();
  }

  private int getHeight(List<int[]> rowGroup) {
    return rowGroup.size() > 0 ? rowGroup.get(0).length : 0;
  }

  private static int[] merge(int[] top, int[] bottom) {
    int[] ret = new int[top.length + bottom.length - 2];
    System.arraycopy(top, 0, ret, 0, top.length);
    System.arraycopy(bottom, 2, ret, top.length, bottom.length - 2);
    return ret;
  }

  static Map<TwoInts, Map<TwoInts, Collection<int[]>>> indexBy(List<int[]> solns, int matchIdx1, int matchIdx2, int uniqIdx1, int uniqIdx2) {
    // space for results
    Map<TwoInts, Map<TwoInts, Collection<int[]>>> indexed =
      new HashMap<TwoInts, Map<TwoInts, Collection<int[]>>>();

    // index all the sorted solutions first by a + b, then keep at most one solution with each unique c + d.
    for (int[] soln : solns) {
      TwoInts matchKey = new TwoInts(soln[matchIdx1], soln[matchIdx2]);
      TwoInts uniqueKey = new TwoInts(soln[uniqIdx1], soln[uniqIdx2]);

      // get / create the first second level map
      Map<TwoInts, Collection<int[]>> byUniqueKey = indexed.get(matchKey);
      if (byUniqueKey == null) {
        byUniqueKey = new HashMap<TwoInts, Collection<int[]>>();
        indexed.put(matchKey, byUniqueKey);
      }

      // put this solution into the second level map if it's the first one. otherwise, it's skipped.
      if (!byUniqueKey.containsKey(uniqueKey)) {
        byUniqueKey.put(uniqueKey, Collections.singleton(soln));
      }
    }

    return indexed;
  }

  private List<List<int[]>> ataviseRows(Grid grid) {
    List<List<int[]>> atavisedRows = new ArrayList<List<int[]>>();

    for (int i = 0; i < grid.getHeight(); i++) {
      atavisedRows.add(rowAtaviser.atavise(grid.getWidth() + 2, grid.getCells()[i] << 1));
    }

    return atavisedRows;
  }

  private int getMinPairIdx(List<List<int[]>> rowGroups) {
    int minIdx = 0;
    int minSum = rowGroups.get(0).size() + rowGroups.get(1).size();
    System.err.println("[0,1]: " + minSum);
    for (int i = 1; i < rowGroups.size() - 2; i++) {
      int sum = rowGroups.get(i).size() + rowGroups.get(i + 1).size();
      System.err.println("[" + i + "," + (i+1) + "]: " + sum);
      if (sum < minSum) {
        minIdx = i;
        minSum = sum;
      }
    }
    System.err.println("Selected [" + minIdx + "," + (minIdx+1) + "]: " + minSum);
    return minIdx;
  }
}
