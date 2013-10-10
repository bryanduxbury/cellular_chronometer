package org.bryanduxbury.atavise;

import java.util.List;
import org.junit.Test;

import static junit.framework.Assert.assertEquals;

public class IntersectingRowAtaviserTest {
  @Test
  public void testSingleCell() {
    IntersectingRowAtaviser a = new IntersectingRowAtaviser();
    List<int[]> ret = a.atavise(3, 1);
    assertEquals("Number of priors for a single living cell", 140, ret.size());

    ret = a.atavise(3, 0);
    assertEquals("Number of priors for a single dead cell", 140, ret.size());
  }
}
