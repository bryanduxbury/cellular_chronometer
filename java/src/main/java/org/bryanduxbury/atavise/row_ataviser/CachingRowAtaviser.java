package org.bryanduxbury.atavise.row_ataviser;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.bryanduxbury.atavise.util.TwoInts;

public class CachingRowAtaviser implements RowAtaviser {
  private final Map<TwoInts, List<int[]>> cache = new HashMap<TwoInts, List<int[]>>();
  private final RowAtaviser actual;

  public CachingRowAtaviser(RowAtaviser actual) {
    this.actual = actual;
  }

  @Override public List<int[]> atavise(int rowWidth, int row) {
    TwoInts k = new TwoInts(rowWidth, row);
    if (cache.containsKey(k)) {
      return cache.get(k);
    } else {
      List<int[]> results = actual.atavise(rowWidth, row);
      cache.put(k, results);
      return results;
    }
  }
}
