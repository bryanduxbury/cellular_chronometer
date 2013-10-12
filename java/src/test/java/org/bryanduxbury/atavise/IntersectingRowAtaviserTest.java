package org.bryanduxbury.atavise;

import java.util.Arrays;
import java.util.List;
import org.bryanduxbury.atavise.solution_filter.SolutionFilter;
import org.junit.Test;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertFalse;
import static junit.framework.Assert.assertTrue;

public class IntersectingRowAtaviserTest {
  @Test
  public void testSingleCell() {
    IntersectingRowAtaviser a = new IntersectingRowAtaviser();
    List<int[]> ret = a.atavise(3, 2);
    assertEquals("Number of priors for a single living cell", 140, ret.size());

    ret = a.atavise(3, 0);
    assertEquals("Number of priors for a single dead cell", 372, ret.size());
  }

  @Test
  public void testTwoCells() {
    IntersectingRowAtaviser a = new IntersectingRowAtaviser();
    List<int[]> ret = a.atavise(4, 0x2 | 0x4);
    assertEquals("Number of priors for two living cells", 417, ret.size());
  }

  @Test
  public void testBlinker() {
    IntersectingRowAtaviser a = new IntersectingRowAtaviser();
    List<int[]> ret = a.atavise(4, 0x2 | 0x4 | 0x8);

    boolean found = false;

    for (int[] prior : ret) {
      if (Arrays.equals(prior, new int[] {4, 4, 4})) {
        found = true;
      }
    }

    assertTrue("Expecting to have found common blinker prior", found);
  }

  @Test
  public void testVerticalBlinkerElements() {
    IntersectingRowAtaviser a = new IntersectingRowAtaviser();
    List<int[]> priors = a.atavise(5, 4);

    boolean found = false;

    for (int[] prior : priors) {
      if (Arrays.equals(prior, new int[] {0, 0, 14})) {
        found = true;
      }
    }

    assertTrue("Expecting to have found common blinker prior", found);
  }

  @Test
  public void testColsToRows() {
    int[] rows = IntersectingRowAtaviser.colsToRows(new int[] {4, 4, 4});
    assertTrue(Arrays.equals(new int[] {0, 0, 7}, rows));
  }

  @Test
  public void testWithFilter() {
    IntersectingRowAtaviser a = new IntersectingRowAtaviser(new SolutionFilter() {
      @Override public boolean keep(int rowWidth, int[] rows) {
        return ! Arrays.equals(rows, new int[]{0,0,14});
      }
    });
    List<int[]> priors = a.atavise(5, 4);

    boolean found = false;

    for (int[] prior : priors) {
      if (Arrays.equals(prior, new int[] {0, 0, 14})) {
        found = true;
      }
    }

    assertFalse("Should have filtered the specified case!", found);
  }
}
