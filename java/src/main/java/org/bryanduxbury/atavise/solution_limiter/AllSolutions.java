package org.bryanduxbury.atavise.solution_limiter;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class AllSolutions implements SolutionLimiter {
  public static class Factory implements SolutionLimiter.Factory {
    @Override public SolutionLimiter getSolutionLimiter() {
      return new AllSolutions();
    }
  }

  private final List<int[]> solutions;
  public AllSolutions() {
    solutions = new ArrayList<int[]>();
  }

  @Override public void add(int[] intermediateSolution) {
    solutions.add(intermediateSolution);
  }

  @Override public boolean isFull() {
    return false;
  }

  @Override public List<int[]> getSolutions() {
    return solutions;
  }
}
