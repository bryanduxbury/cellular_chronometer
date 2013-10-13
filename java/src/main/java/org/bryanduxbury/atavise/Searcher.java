package org.bryanduxbury.atavise;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.Collection;
import org.bryanduxbury.atavise.solution_filter.TubularRowFilter;
import org.bryanduxbury.atavise.solution_limiter.Aggressive;

public class Searcher {

  private final HierarchicalDuparcGridAtaviser ataviser;

  public Searcher() {
    ataviser =
        new HierarchicalDuparcGridAtaviser(new CachingRowAtaviser(new IntersectingRowAtaviser(new TubularRowFilter())),
            new Aggressive.Factory(1000000));
  }

  private void search(int numPriors, String gridFilePath) throws IOException {
    // load target from gridFilePath
    Grid targetGrid = Grid.fromFile(gridFilePath);

    if (targetGrid.getWidth() > targetGrid.getHeight()) {
      targetGrid = targetGrid.transpose();
    }

    // run find() recursively
    int[] result = find(targetGrid, numPriors);

    if (result == null) {
      System.out.print("-");
      return;
    } else {
      writeResult(targetGrid, result, gridFilePath, numPriors);
      System.out.print("+");
    }
  }

  private void writeResult(Grid targetGrid, int[] result, String gridFilePath, int numPriors)
      throws FileNotFoundException {
    File f = new File(gridFilePath + "__back_" + numPriors);
    f.delete();
    PrintWriter pw = new PrintWriter(new FileOutputStream(f));
    pw.println(Arrays.toString(targetGrid.getCells()));
    pw.println(Arrays.toString(result));
    pw.close();
  }

  private int[] find(Grid targetGrid, int numPriors) {
    if (numPriors == 0) {
      return targetGrid.getCells();
    } else {
      Collection<int[]> priors = ataviser.atavise(targetGrid);
      System.out.println(numPriors + " -> " + priors.size());
      for (int[] prior : priors) {
        if (!isToroidal(prior)) {
          continue;
        }
        //System.out.println("toroidal!");
        Grid newTargetGrid = new Grid(stripBorder(prior, targetGrid.getWidth()), targetGrid.getWidth());
        int[] result = find(newTargetGrid, numPriors - 1);
        if (result != null) {
          return result;
        }
        //System.out.println("... but no prior at level " + numPriors);
      }

      return null;
    }
  }

  private int[] stripBorder(int[] prior, int width) {
    int[] stripped = new int[prior.length - 2];
    int mask = 0;
    for (int i = 1; i <= width; i++) {
      mask |= (1 << i);
    }
    for (int i = 0; i < prior.length - 2; i++) {
      stripped[i] = (prior[i+1] & mask) >> 1;
    }
    return stripped;
  }

  private boolean isToroidal(int[] cells) {
    return cells[0] == cells[cells.length - 2] && cells[1] == cells[cells.length - 1];
  }

  public static void main(String[] args) throws IOException {
    Searcher s = new Searcher();

    long startTime = System.currentTimeMillis();
    int numPriors = Integer.parseInt(args[0]);
    for (int i = 1; i < args.length; i++) {
      s.search(numPriors, args[i]);
    }
    System.out.println();
    long endTime = System.currentTimeMillis();
    System.out.println("Elapsed ms: " + (endTime - startTime));
  }
}
