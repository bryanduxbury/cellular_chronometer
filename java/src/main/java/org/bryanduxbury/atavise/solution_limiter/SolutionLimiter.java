package org.bryanduxbury.atavise.solution_limiter;

import java.util.List;

public interface SolutionLimiter {
  public interface Factory {
    SolutionLimiter getSolutionLimiter();
  }

  public void add(int[] intermediateSolution);
  public boolean isFull();
  public List<int[]> getSolutions();
}
