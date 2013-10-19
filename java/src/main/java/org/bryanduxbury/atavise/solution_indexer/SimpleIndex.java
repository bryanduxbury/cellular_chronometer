package org.bryanduxbury.atavise.solution_indexer;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import org.bryanduxbury.atavise.util.TwoInts;

public class SimpleIndex implements SolutionIndexer {
  @Override public Map<TwoInts, Map<TwoInts, Collection<int[]>>> index(Collection<int[]> intermediateSolutions, int a, int b, int c, int d) {
    HashMap<TwoInts, Map<TwoInts, Collection<int[]>>> index = new HashMap<TwoInts, Map<TwoInts, Collection<int[]>>>();
    for (int[] soln : intermediateSolutions) {
      indexOne(index, soln, a, b, c, d);
    }
    return index;
  }

  private void indexOne(Map<TwoInts, Map<TwoInts, Collection<int[]>>> index, int[] soln, int a, int b, int c, int d) {
    TwoInts k1 = new TwoInts(soln[a], soln[b]);
    Map<TwoInts, Collection<int[]>> firstStage = index.get(k1);
    if (firstStage == null) {
      firstStage = new HashMap<TwoInts, Collection<int[]>>();
      index.put(k1, firstStage);
    }
    TwoInts k2 = new TwoInts(soln[c], soln[d]);
    Collection<int[]> secondStage = firstStage.get(k2);
    if (secondStage == null) {
      secondStage = new ArrayList<int[]>();
      firstStage.put(k2, secondStage);
    }
    secondStage.add(soln);
  }
}
