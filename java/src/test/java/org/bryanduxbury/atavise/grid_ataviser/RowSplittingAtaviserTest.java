package org.bryanduxbury.atavise.grid_ataviser;

import org.bryanduxbury.atavise.util.TwoInts;
import org.junit.Test;

import static org.junit.Assert.*;

public class RowSplittingAtaviserTest {
  @Test
  public void testExtractColumns() {
    // 0 1 2 3 4 5 6 7
    // 0 0 0 0 0 0 0 0 = 0
    // 0 0 0 1 0 0 0 0 = 4
    // 1 0 1 0 1 0 1 0 = 0x55
    // 0 1 0 1 0 1 0 1 = 0xAA


    int[] example = new int[]{0, 4, 0x55, 0xAA};

    assertEquals(new TwoInts(4,8), RowSplittingAtaviser.Helpers.extractColumns(example, 6, 7));
  }
}