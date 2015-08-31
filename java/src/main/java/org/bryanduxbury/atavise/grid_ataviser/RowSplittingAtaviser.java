package org.bryanduxbury.atavise.grid_ataviser;

import org.bryanduxbury.atavise.Grid;
import org.bryanduxbury.atavise.row_ataviser.RowAtaviser;
import org.bryanduxbury.atavise.solution_limiter.SolutionLimiter;
import org.bryanduxbury.atavise.util.TwoInts;

import java.util.*;

/**
 * Split the input grid vertically into segments of no more than N columns. Atavise those subsets. Merge intermediate
 * results to produce final solutions.
 */
public class RowSplittingAtaviser implements GridAtaviser {
  public static class Helpers {
    public static int[] merge(int[] l, int[] r, int rhsWidth) {
      int[] merged = new int[l.length];
      for (int i = 0; i < l.length; i++) {
        merged[i] = l[i] | (r[i] << rhsWidth);
      }
      return merged;
    }

    public static TwoInts extractLeftmost(int[] arr) {
      return extractColumns(arr, 0, 1);
    }

    public static TwoInts extractColumns(int[] arr, int idx1, int idx2) {
      int a = 0;
      int b = 0;
      for (int rowIdx = 0; rowIdx < arr.length; rowIdx++) {
        if ((arr[rowIdx] & (1 << idx1)) != 0) {
          a = a | (1 << rowIdx);
        }
        if ((arr[rowIdx] & (1 << idx2)) != 0) {
          b = b | (1 << rowIdx);
        }
//        a = a | ((arr[rowIdx] & (1 << idx1)) == 0 ? 0 : 1 << rowIdx);
//        b = b | ((arr[rowIdx] & (1 << idx2)) == 0 ? 0 : 1 << rowIdx);
      }
      return new TwoInts(a, b);
    }

    public static TwoInts extractRightmost(int[] arr, int width) {
      return extractColumns(arr, width - 2, width - 1);
    }
  }


  private final GridAtaviser internalAtaviser;
  private final int maxCols;

  public RowSplittingAtaviser(SolutionLimiter.Factory solutionLimiter, RowAtaviser rowAtaviser, int maxCols) {
    internalAtaviser = new MinGrowthAtaviser(rowAtaviser, solutionLimiter);
    this.maxCols = maxCols;
  }

  @Override
  public Collection<int[]> atavise(Grid grid) {
    List<Grid> subgrids = partitionGrid(grid);
    List<Integer> subgridWidths = new ArrayList<Integer>();
    for (Grid subgrid : subgrids) {
      subgridWidths.add(subgrid.getWidth());
    }
    System.err.println("Partitioned input grid into sizes: " + subgridWidths.toString());
    List<Collection<int[]>> atavisedSubgrids = ataviseSubgrids(subgrids);
    return findMutualSolutions(atavisedSubgrids, subgridWidths);
  }

  // Follow the MinGrowthAtaviser strategy to merge adjacent subsolutions with smallest sum of solutions
  private Collection<int[]> findMutualSolutions(List<Collection<int[]>> atavisedSubgrids, List<Integer> subgridWidths) {
    while (atavisedSubgrids.size() > 1) {
      int minPairIdx = getMinPairIdx(atavisedSubgrids);
      System.err.println("Going to merge solutions for subgrids " + minPairIdx + " and " + (minPairIdx+1));

      Collection<int[]> lhs = atavisedSubgrids.remove(minPairIdx);
      int lhsWidth = subgridWidths.remove(minPairIdx);
      Collection<int[]> rhs = atavisedSubgrids.remove(minPairIdx);
      int rhsWidth = subgridWidths.remove(minPairIdx);

      atavisedSubgrids.add(minPairIdx, mergeSolutions(lhs, rhs, lhsWidth, rhsWidth));
      subgridWidths.add(minPairIdx, lhsWidth + rhsWidth - 2);
    }

    return atavisedSubgrids.get(0);
  }

  private Collection<int[]> mergeSolutions(Collection<int[]> lhs, Collection<int[]> rhs, int lhsWidth, int rhsWidth) {
    // index lhs by right two columns
    Map<TwoInts, List<int[]>> lhsByRightmost = new HashMap<TwoInts, List<int[]>>();
    for (int[] lhsSoln : lhs) {
      TwoInts rightmostCols = Helpers.extractRightmost(lhsSoln, lhsWidth);
      List<int[]> thisSolns = lhsByRightmost.get(rightmostCols);
      if (thisSolns == null) {
        thisSolns = new ArrayList<int[]>();
        lhsByRightmost.put(rightmostCols, thisSolns);
      }
      thisSolns.add(lhsSoln);
    }

    Collection<int[]> result = new ArrayList<int[]>();

    // iterate through rhs, merging with matching lhs using the index
    for (int[] rhsSoln : rhs) {
      TwoInts leftmost = Helpers.extractLeftmost(rhsSoln);
      List<int[]> matches = lhsByRightmost.get(leftmost);
      if (matches == null) continue;
      for (int[] matchingLhs : matches) {
        result.add(Helpers.merge(matchingLhs, rhsSoln, rhsWidth));
      }
    }

    System.err.println(result.size() + " overlapping solutions after merging");

    return result;
  }


  private int getMinPairIdx(List<Collection<int[]>> atavisedSubgrids) {
    int minIdx = 0;
    int minSum = atavisedSubgrids.get(0).size() + atavisedSubgrids.get(1).size();
    for (int i = 1; i < atavisedSubgrids.size() - 2; i++) {
      int sum = atavisedSubgrids.get(i).size() + atavisedSubgrids.get(i + 1).size();
      System.err.println("[" + i + "," + (i+1) + "]: " + sum);
      if (sum < minSum) {
        minIdx = i;
        minSum = sum;
      }
    }
    System.err.println("Selected [" + minIdx + "," + (minIdx+1) + "]: " + minSum);
    return minIdx;
  }

  private List<Collection<int[]>> ataviseSubgrids(List<Grid> subgrids) {
    List<Collection<int[]>> atavisedSubgrids = new ArrayList<Collection<int[]>>();

    for (Grid subgrid : subgrids) {
      Collection<int[]> priors = internalAtaviser.atavise(subgrid);
      atavisedSubgrids.add(priors);
      System.err.println("Finished atavising subgrid, got " + priors.size() + " prior states");
    }

    return atavisedSubgrids;
  }

  private List<Grid> partitionGrid(Grid originalGrid) {
    List<Grid> subgrids = new ArrayList<Grid>();

    System.err.println("original grid width " + originalGrid.getWidth());
    for (int x = 0; x < originalGrid.getWidth(); x += maxCols) {
      subgrids.add(originalGrid.subgrid(x, 0, Math.min(x + maxCols - 1, originalGrid.getWidth() - 1), originalGrid.getHeight() - 1));
    }

    return subgrids;
  }
}
