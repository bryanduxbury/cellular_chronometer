package org.bryanduxbury.atavise;

import java.util.Arrays;
import java.util.List;
import org.junit.Test;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertTrue;

public class HierarchicalDuparcGridAtaviserTest {

  @Test
  public void testAtaviseHorizontalBlinker() {
    int[] grid = new int[]{0,7,0};
    HierarchicalDuparcGridAtaviser a =
        new HierarchicalDuparcGridAtaviser(new IntersectingRowAtaviser());
    List<int[]> results = a.atavise(3, 3, grid);

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
    HierarchicalDuparcGridAtaviser a =
        new HierarchicalDuparcGridAtaviser(new IntersectingRowAtaviser());
    List<int[]> results = a.atavise(3, 3, grid);

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
