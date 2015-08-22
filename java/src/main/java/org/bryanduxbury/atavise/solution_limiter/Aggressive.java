package org.bryanduxbury.atavise.solution_limiter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.bryanduxbury.atavise.util.FourInts;

public class Aggressive implements SolutionLimiter {
  public static class Factory implements SolutionLimiter.Factory {

    private final int hardLimit;

    public Factory(int hardLimit) {
      this.hardLimit = hardLimit;
    }

    @Override public SolutionLimiter getSolutionLimiter() {
      return new Aggressive(hardLimit);
    }
  }
  private final Map<FourInts, int[]> map;
  private final int hardLimit;

  public Aggressive(int hardLimit) {
    this.hardLimit = hardLimit;
    map = new HashMap<FourInts, int[]>();
  }

  @Override public void add(int[] intermediateSolution) {
    FourInts k =
        new FourInts(
            intermediateSolution[0],
            intermediateSolution[1],
            intermediateSolution[intermediateSolution.length - 2],
            intermediateSolution[intermediateSolution.length - 1]);
    map.put(k, intermediateSolution);
  }

  @Override public boolean isFull() {
    return map.size() >= hardLimit;
  }

  @Override public List<int[]> getSolutions() {
    return new ArrayList<int[]>(map.values());
  }
}
