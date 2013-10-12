package org.bryanduxbury.atavise;

import java.util.ArrayList;
import java.util.List;
import org.bryanduxbury.atavise.solution_filter.RetainAll;
import org.bryanduxbury.atavise.solution_filter.SolutionFilter;

public class IntersectingRowAtaviser implements RowAtaviser {

  private final List<int[]> endsUpDead = new ArrayList<int[]>();
  private final List<int[]> endsUpLiving = new ArrayList<int[]>();

  private static final int[] TABLE = {0, 1, 1, 2, 1, 2, 2, 3};
  private final SolutionFilter solutionFilter;

  private static int numLiving(int bitvector) {
    return TABLE[bitvector & 0x07];
  }

  private static int[] byRow(int bitvector) {
    return new int[]{bitvector & 0x7, (bitvector >> 3) & 0x7, (bitvector >> 6) & 0x7};
  }

  public IntersectingRowAtaviser() {
    this(new RetainAll());
  }

  public IntersectingRowAtaviser(SolutionFilter solutionFilter) {
    this.solutionFilter = solutionFilter;
    for (int i = 0; i < 512; i++) {
      int count = numLiving(i) + numLiving((i >> 3) & 0x5) + numLiving(i >> 6);

      // if the center cell is alive, then...
      if ((i & (1 << 4)) != 0) {
        if (count == 2 || count == 3) {
          endsUpLiving.add(byRow(i));
        } else {
          endsUpDead.add(byRow(i));
        }
      } else {
        if (count == 3) {
          endsUpLiving.add(byRow(i));
        } else {
          endsUpDead.add(byRow(i));
        }
      }
    }
  }

  @Override
  public List<int[]> atavise(int rowWidth, int row) {
    List<int[]> solutions = new ArrayList<int[]>();

    if ((row & 2) != 0) {
      for (int[] seed : endsUpLiving) {
        solutions.add(copy(seed));
      }
    } else {
      for (int[] seed : endsUpDead) {
        solutions.add(copy(seed));
      }
    }

    for (int i = 2; i < rowWidth - 1; i++) {
      List<int[]> newSolutions = new ArrayList<int[]>();
      List<int[]> rhs = null;
      if ((row & (1 << i)) != 0) {
        rhs = endsUpLiving;
      } else {
        rhs = endsUpDead;
      }

      for (int[] partialSolution : solutions) {
        for (int[] cellSolution : rhs) {
          if (matchingOverlap(partialSolution, cellSolution)) {
            newSolutions.add(merge(partialSolution, cellSolution));
          }
        }
      }

      solutions = newSolutions;
    }

    List<int[]> finalSolutions = new ArrayList<int[]>(solutions.size());
    for (int[] solution : solutions) {
      int[] byRow = colsToRows(solution);
      if (solutionFilter.keep(rowWidth, byRow)) {
        finalSolutions.add(byRow);
      }
    }
    return finalSolutions;
  }

  static int[] colsToRows(int[] byCol) {
    int[] byRow = new int[] {0,0,0};
    for (int i = 0; i < byCol.length; i++) {
      byRow[0] = (byRow[0] | (((byCol[i] & 1) >> 0) << i));
      byRow[1] = (byRow[1] | (((byCol[i] & 2) >> 1) << i));
      byRow[2] = (byRow[2] | (((byCol[i] & 4) >> 2) << i));
    }
    return byRow;
  }

  static int[] merge(int[] lhs, int[] rhs) {
    int[] result = new int[lhs.length+1];
    System.arraycopy(lhs, 0, result, 0, lhs.length);
    result[result.length-1] = rhs[2];
    return result;
  }

  private static boolean matchingOverlap(int[] lhs, int[] rhs) {
    int l1 = lhs[lhs.length - 2];
    int l2 = lhs[lhs.length - 1];
    int r1 = rhs[0];
    int r2 = rhs[1];
    return l1 == r1 && l2 == r2;
  }

  private static int[] copy(int[] ints) {
    int[] temp = new int[ints.length];
    System.arraycopy(ints, 0, temp, 0, ints.length);
    return temp;
  }

  // benchmarking purposes only!
  public static void main(String[] args) {
    IntersectingRowAtaviser a = new IntersectingRowAtaviser();
    long startTime = System.currentTimeMillis();
    for (int trial = 0; trial < 10; trial++) {
      for (int i = 0; i < 32; i++) {
        a.atavise(7, i << 1);
      }
    }

    long endTime = System.currentTimeMillis();
    System.out.println(endTime-startTime);
  }
}
