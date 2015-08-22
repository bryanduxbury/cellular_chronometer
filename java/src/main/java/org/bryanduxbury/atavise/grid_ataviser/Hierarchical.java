package org.bryanduxbury.atavise.grid_ataviser;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.bryanduxbury.atavise.row_ataviser.CachingRowAtaviser;
import org.bryanduxbury.atavise.Grid;
import org.bryanduxbury.atavise.row_ataviser.IntersectingRowAtaviser;
import org.bryanduxbury.atavise.row_ataviser.RowAtaviser;
import org.bryanduxbury.atavise.util.TwoInts;
import org.bryanduxbury.atavise.solution_filter.TubularRowFilter;
import org.bryanduxbury.atavise.solution_indexer.SolutionIndexer;
import org.bryanduxbury.atavise.solution_indexer.UniqueBordersIndexer;
import org.bryanduxbury.atavise.solution_limiter.Aggressive;
import org.bryanduxbury.atavise.solution_limiter.SolutionLimiter;

public class Hierarchical implements GridAtaviser {

  private final RowAtaviser rowAtaviser;
  private final SolutionLimiter.Factory solnLimiterFactory;
  private final SolutionIndexer solutionIndexer;

  public Hierarchical(RowAtaviser rowAtaviser, SolutionLimiter.Factory solnLimiterFactory,
      SolutionIndexer solutionIndexer) {
    this.rowAtaviser = rowAtaviser;
    this.solnLimiterFactory = solnLimiterFactory;
    this.solutionIndexer = solutionIndexer;
  }

  @Override public Collection<int[]> atavise(Grid grid) {
    Collection<int[]> results = internalAtavise(grid, 0, grid.getHeight(), null);
    return results;
  }

  protected Collection<int[]> internalAtavise(Grid grid, int startRow, int endRow,
      Set<TwoInts> spoilers) {
    if (endRow - startRow == 1) {
      return ataviseRow(grid, grid.getCells()[startRow], spoilers);
    }
    return divideAndAtavise(grid, startRow, endRow, spoilers);
  }

  private Collection<int[]> divideAndAtavise(Grid grid, int startRow, int endRow, Set<TwoInts> spoilers) {
    // compute the midpoint for recursing
    int mid = (endRow - startRow) / 2 + startRow;

    // compute the top half
    Collection<int[]> topPriors = internalAtavise(grid, startRow, mid, spoilers);
    // index the results by the bottom-most rows (while uniqueing by the topmost rows)
    Map<TwoInts, Map<TwoInts, Collection<int[]>>> topsByBottom =
        indexBy(topPriors, mid - startRow, mid - startRow + 1, 0, 1);

    // null out to help with GC
    topPriors = null;

    // compute the results for the bottom half
    Collection<int[]> bottomPriors = internalAtavise(grid, mid, endRow, topsByBottom.keySet());
    // index the results by the bottom-most rows (while uniqueing by the topmost rows)
    Map<TwoInts, Map<TwoInts, Collection<int[]>>> bottomsByTops =
        indexBy(bottomPriors, 0, 1, endRow - mid, endRow - mid + 1);

    // null out to help with GC
    bottomPriors = null;

    // compute all the LH and RH solutions that are cross-compatible
    return getCompatibleSolutions(topsByBottom, bottomsByTops);
  }

  private Collection<int[]> getCompatibleSolutions(Map<TwoInts, Map<TwoInts, Collection<int[]>>> topsByBottom, Map<TwoInts, Map<TwoInts, Collection<int[]>>> bottomsByTops) {
    // compute the intersection of all tops and bottoms
    SolutionLimiter sl = solnLimiterFactory.getSolutionLimiter();

    // for each unique bottom in the top set...
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

    return sl.getSolutions();
  }

  private Collection<int[]> ataviseRow(Grid grid, int row, Set<TwoInts> spoilers) {
    // cool, down to one row
    // row-atavise it
    List<int[]> rowPriors = rowAtaviser.atavise(grid.getWidth() + 2, row << 1);

    // filter row prior states against previously provided "spoilers" -- we know the row priors have to match the
    // spoilers to be possible solutions.
    if (spoilers != null) {
      List<int[]> filtered = new ArrayList<int[]>();
      for (int[] prior : rowPriors) {
        if (spoilers.contains(new TwoInts(prior[0], prior[1]))) {
          filtered.add(prior);
        }
      }
      rowPriors = filtered;
    }
    return rowPriors;
  }

  static Map<TwoInts, Map<TwoInts, Collection<int[]>>> indexBy(Collection<int[]> solns, int a, int b, int c, int d) {
    Map<TwoInts, Map<TwoInts, Collection<int[]>>> indexed =
        new HashMap<TwoInts, Map<TwoInts, Collection<int[]>>>();
    List<int[]> sortedSolns = new ArrayList<int[]>(solns);
    Collections.sort(sortedSolns, new Comparator<int[]>() {
      @Override public int compare(int[] left, int[] right) {
        for (int i = 0; i < left.length; i++) {
          if (left[i] != right[i]) {
            return Integer.valueOf(left[i]).compareTo(right[i]);
          }
        }
        return 0;
      }
    });
    for (int[] soln : sortedSolns) {
      TwoInts x = new TwoInts(soln[a], soln[b]);
      TwoInts y = new TwoInts(soln[c], soln[d]);
      Map<TwoInts, Collection<int[]>> ys = indexed.get(x);
      if (ys == null) {
        ys = new HashMap<TwoInts, Collection<int[]>>();
        indexed.put(x, ys);
      }
      if (!ys.containsKey(x)) {
        ys.put(y, Collections.singleton(soln));
      }

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
    Hierarchical a = new Hierarchical(
        new CachingRowAtaviser(new IntersectingRowAtaviser(new TubularRowFilter())),
        new Aggressive.Factory(100000), new UniqueBordersIndexer());
    long startTime = System.currentTimeMillis();
    //for (int trial = 0; trial < 10; trial++) {
      for (int i = 0; i < 1; i++) {
        int[] s0101 =
            {0, 0, 31, 17, 31, 0, 0, 18, 31, 16, 0, 0, 10, 0, 0, 31, 17, 31, 0, 0, 18, 31, 16, 0, 0};
        System.out.print(a.atavise(new Grid(s0101, 5)).size());
        System.out.println(" priors!");
      }
    //}

    long endTime = System.currentTimeMillis();
    System.out.println(endTime-startTime);
  }
}
