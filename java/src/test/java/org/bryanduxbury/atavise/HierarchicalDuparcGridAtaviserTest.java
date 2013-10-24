package org.bryanduxbury.atavise;

import java.util.Arrays;
import java.util.Collection;
import org.bryanduxbury.atavise.grid_ataviser.Hierarchical;
import org.bryanduxbury.atavise.grid_ataviser.Hierarchical;
import org.bryanduxbury.atavise.row_ataviser.IntersectingRowAtaviser;
import org.bryanduxbury.atavise.solution_indexer.SimpleIndex;
import org.bryanduxbury.atavise.solution_limiter.AllSolutions;
import org.junit.Test;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertTrue;

public class HierarchicalDuparcGridAtaviserTest {

  @Test
  public void testAtaviseHorizontalBlinker() {
    int[] grid = new int[]{0,7,0};
    Hierarchical a =
        new Hierarchical(new IntersectingRowAtaviser(), new AllSolutions.Factory(),
            new SimpleIndex());
    Collection<int[]> results = a.atavise(new Grid(grid, 3));

    boolean found = false;

    for (int[] solution : results) {
      assertEquals(5, solution.length);
      if (Arrays.equals(solution, new int[]{0,4,4,4,0})) {
        found = true;
      }
    }

    assertTrue("Expected to find common blinker prior", found);
  }

  @Test
  public void testAtaviseVerticalBlinker() {
    int[] grid = new int[]{2,2,2};
    Hierarchical a =
        new Hierarchical(new IntersectingRowAtaviser(), new AllSolutions.Factory(),
            new SimpleIndex());
    Collection<int[]> results = a.atavise(new Grid(grid, 3));

    boolean found = false;

    for (int[] solution : results) {
      assertEquals(5, solution.length);
      //if (solution[0] == 0 && solution[1] == 0) {
      //  System.out.println(Arrays.toString(solution));
      //}

      if (Arrays.equals(solution, new int[]{0,0,14,0,0})) {
        found = true;
      }
    }

    assertTrue("Expected to find common blinker prior", found);
  }
}
