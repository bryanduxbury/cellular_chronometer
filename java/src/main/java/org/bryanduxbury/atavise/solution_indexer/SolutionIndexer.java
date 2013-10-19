package org.bryanduxbury.atavise.solution_indexer;

import java.util.Collection;
import java.util.Map;
import org.bryanduxbury.atavise.util.TwoInts;

public interface SolutionIndexer {
  public Map<TwoInts, Map<TwoInts, Collection<int[]>>> index(Collection<int[]> intermediateSolutions, int a, int b, int c, int d);
}
