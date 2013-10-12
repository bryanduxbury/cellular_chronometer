package org.bryanduxbury.atavise.solution_filter;

import org.bryanduxbury.atavise.solution_filter.TubularRowFilter;
import org.junit.Test;

import static junit.framework.Assert.assertFalse;
import static junit.framework.Assert.assertTrue;

public class TubularRowFilterTest {
  @Test
  public void testIt() {
    TubularRowFilter f = new TubularRowFilter();
    assertTrue(f.keep(5, new int[]{0,0,0}));
    assertTrue(f.keep(5, new int[]{0,31,0}));
    assertFalse(f.keep(5, new int[] {0, 1, 0}));
  }
}
