package org.bryanduxbury.atavise;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.util.Arrays;
import org.junit.Test;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertTrue;

public class GridTest {

  public static final int[] S0101 =
      new int[] {0, 0, 31, 17, 31, 0, 0, 18, 31, 16, 0, 0, 10, 0, 0, 31, 17, 31, 0, 0, 18, 31, 16,
          0, 0};

  @Test
  public void testFromFile() throws Exception {
    File f = new File("GridTest.txt");
    f.delete();
    PrintWriter pw = new PrintWriter(new FileOutputStream(f));
    pw.print(
          "  ###   #      ###   #   \n"
        + "  # #  ##   #  # #  ##   \n"
        + "  # #   #      # #   #   \n"
        + "  # #   #   #  # #   #   \n"
        + "  ###  ###     ###  ###  ");
    pw.close();

    Grid grid = Grid.fromFile(f.getPath());
    assertEquals(5, grid.getHeight());
    assertEquals(25, grid.getWidth());

    // note: too lazy to recompute the actual long row bitvectors so this makes sense without the
    // transpose call
    assertTrue("loaded correct data", Arrays.equals(S0101, grid.transpose().getCells()));
  }
}
