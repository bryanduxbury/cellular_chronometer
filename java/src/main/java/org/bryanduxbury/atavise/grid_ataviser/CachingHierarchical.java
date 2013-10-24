package org.bryanduxbury.atavise.grid_ataviser;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Set;
import org.bryanduxbury.atavise.Grid;
import org.bryanduxbury.atavise.row_ataviser.RowAtaviser;
import org.bryanduxbury.atavise.solution_indexer.SolutionIndexer;
import org.bryanduxbury.atavise.solution_limiter.SolutionLimiter;
import org.bryanduxbury.atavise.util.ListOfInts;
import org.bryanduxbury.atavise.util.TwoInts;

public class CachingHierarchical extends Hierarchical {

  private final HashMap<ListOfInts,Collection<int[]>> cache;

  public CachingHierarchical(RowAtaviser rowAtaviser, SolutionLimiter.Factory solnLimiterFactory,
      SolutionIndexer solutionIndexer) {
    super(rowAtaviser, solnLimiterFactory, solutionIndexer);
    cache = new HashMap<ListOfInts, Collection<int[]>>();
  }

  @Override
  protected Collection<int[]> internalAtavise(Grid grid, int startRow, int endRow, Set<TwoInts> spoilers) {
    ListOfInts cacheKey = new ListOfInts(grid.getCells(), startRow, endRow);
    Collection<int[]> cachedValue = cache.get(cacheKey);
    if (cachedValue == null) {
      cachedValue = super.internalAtavise(grid, startRow, endRow, null);
      cache.put(cacheKey, cachedValue);
    }

    return cachedValue;
  }
}
