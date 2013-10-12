package org.bryanduxbury.atavise.solution_limiter;

import java.util.ArrayList;
import java.util.Collection;

public class AllSolutions implements SolutionLimiter {
  public static class Factory implements SolutionLimiter.Factory {
    @Override public SolutionLimiter getSolutionLimiter() {
      return new AllSolutions();
    }
  }

  private final Collection<int[]> solutions;
  public AllSolutions() {
    solutions = new ArrayList<int[]>();
  }

  @Override public void add(int[] intermediateSolution) {
    solutions.add(intermediateSolution);
  }

  @Override public boolean isFull() {
    return false;
  }

  @Override public Collection<int[]> getSolutions() {
    return solutions;
  }
}
