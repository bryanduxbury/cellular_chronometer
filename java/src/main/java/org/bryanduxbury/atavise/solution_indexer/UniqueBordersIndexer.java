package org.bryanduxbury.atavise.solution_indexer;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.bryanduxbury.atavise.util.TwoInts;

public class UniqueBordersIndexer implements SolutionIndexer {
  @Override public Map<TwoInts, Map<TwoInts, Collection<int[]>>> index(Collection<int[]> intermediateSolutions, int a, int b, int c, int d) {
    HashMap<TwoInts, Map<TwoInts, Collection<int[]>>> index = new HashMap<TwoInts, Map<TwoInts, Collection<int[]>>>();
    List<int[]> sortedSolns = new ArrayList<int[]>(intermediateSolutions);
    Collections.sort(sortedSolns, new Comparator<int[]>() {
      @Override public int compare(int[] left, int[] right) {
        for (int i = 0; i < left.length; i++) {
          if (left[i] != right[i]) {
            return Integer.valueOf(left[i]).compareTo(right[i]);
          }
        }
        return 0;
      }
    });
    for (int[] soln : sortedSolns) {
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
    if (!firstStage.containsKey(k2)) {
      firstStage.put(k2, Collections.singleton(soln));
    }
  }
}
