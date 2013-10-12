package org.bryanduxbury.atavise.solution_limiter;

import java.util.ArrayList;
import java.util.Collection;

public class HardLimit implements SolutionLimiter {
  public static class Factory implements SolutionLimiter.Factory {
    private final int hardLimit;

    public Factory(int hardLimit) {
      this.hardLimit = hardLimit;
    }

    @Override public SolutionLimiter getSolutionLimiter() {
      return new HardLimit(hardLimit);
    }
  }
  private final Collection<int[]> solns;
  private final int hardLimit;

  public HardLimit(int hardLimit) {
    this.hardLimit = hardLimit;
    solns = new ArrayList<int[]>(hardLimit);
  }

  @Override public void add(int[] intermediateSolution) {
    solns.add(intermediateSolution);
  }

  @Override public boolean isFull() {
    return solns.size() >= hardLimit;
  }

  @Override public Collection<int[]> getSolutions() {
    return solns;
  }
}
