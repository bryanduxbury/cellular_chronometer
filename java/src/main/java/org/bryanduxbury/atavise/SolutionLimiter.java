package org.bryanduxbury.atavise;

import java.util.Collection;

public interface SolutionLimiter {
  public interface Factory {
    SolutionLimiter getSolutionLimiter();
  }

  public void add(int[] intermediateSolution);
  public boolean isFull();
  public Collection<int[]> getSolutions();
}
