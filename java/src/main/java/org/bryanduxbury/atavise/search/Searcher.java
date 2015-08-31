package org.bryanduxbury.atavise.search;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import org.bryanduxbury.atavise.Grid;
import org.bryanduxbury.atavise.grid_ataviser.*;
import org.bryanduxbury.atavise.row_ataviser.CachingRowAtaviser;
import org.bryanduxbury.atavise.row_ataviser.IntersectingRowAtaviser;
import org.bryanduxbury.atavise.solution_filter.RandomSample;
import org.bryanduxbury.atavise.solution_filter.RetainAll;
import org.bryanduxbury.atavise.solution_filter.TubularRowFilter;
import org.bryanduxbury.atavise.solution_indexer.SimpleIndex;
import org.bryanduxbury.atavise.solution_indexer.UniqueBordersIndexer;
import org.bryanduxbury.atavise.solution_limiter.Aggressive;
import org.bryanduxbury.atavise.solution_limiter.AllSolutions;
import org.bryanduxbury.atavise.solution_limiter.HardLimit;

public class Searcher {

  private final GridAtaviser fastAtaviser;
//  private final Hierarchical thoroughAtaviser;

  public Searcher() {
    Aggressive.Factory aggressive = new Aggressive.Factory(1000000);
    HardLimit.Factory hard = new HardLimit.Factory(2500000);
//    CachingRowAtaviser rowAtaviser =
//        new CachingRowAtaviser(new IntersectingRowAtaviser(new TubularRowFilter()));

      CachingRowAtaviser rowAtaviser =
        new CachingRowAtaviser(new IntersectingRowAtaviser(new RandomSample(0.75)));

//    fastAtaviser = new Hierarchical(rowAtaviser, aggressive, new UniqueBordersIndexer());
//    fastAtaviser = new MinGrowthAtaviser(rowAtaviser, new AllSolutions.Factory());
//    thoroughAtaviser = new Hierarchical(rowAtaviser, hard, new SimpleIndex());
      fastAtaviser = new RowSplittingAtaviser(new AllSolutions.Factory(), rowAtaviser, 5);
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
    } else {
      writeResult(targetGrid, result, gridFilePath, numPriors);
      System.out.print("+");
    }
  }

  private void writeResult(Grid targetGrid, int[] result, String gridFilePath, int numPriors)
      throws FileNotFoundException {

    Grid g = new Grid(result, targetGrid.getWidth()).transpose();
    for (int i = 0; i < numPriors; i++) {
      System.out.println(" start ------------------- ");
      System.out.println(g);
      g = g.makeToroidal();
      System.out.println(" toroided ------------------- ");
      System.out.println(g);
      g = g.nextGeneration();
      System.out.println(" next ------------------- ");
      System.out.println(g);
      g = g.subgrid(1, 1, g.getWidth() - 2, g.getHeight() - 2);
    }

    System.out.println(" final --------------------");
    System.out.println(g);

    File f = new File(gridFilePath + "__farthest_back");
    f.delete();
    PrintWriter pw = new PrintWriter(new FileOutputStream(f));
    for (int i = 0; i < targetGrid.getHeight(); i++) {
      pw.print(targetGrid.getCells()[i]);
      pw.print(", ");
    }
    pw.print(" // " + new File(gridFilePath).getName());
    pw.println();

    for (int i = 0; i < result.length; i++) {
      pw.print(result[i]);
      pw.print(", ");
    }

    pw.print(" // " + new File(gridFilePath).getName() + ", " + numPriors + " priors back");

    pw.println();
    pw.close();
  }

  private int[] find(Grid targetGrid, int numPriors) {
    if (numPriors == 0) {
      return targetGrid.getCells();
    } else {
      Collection<int[]> priors = fastAtaviser.atavise(targetGrid);

      int[] result = examinePriors(targetGrid, numPriors, priors);
//      if (result == null && priors.size() > 0) {
//        Collection<int[]> thoroughPriors = thoroughAtaviser.atavise(targetGrid);
//        //thoroughPriors.removeAll(new HashSet<int[]>()priors);
//        result = examinePriors(targetGrid, numPriors, thoroughPriors);
//      }

      return result;
    }
  }

  private int[] examinePriors(Grid targetGrid, int numPriors, Collection<int[]> priors) {
    //System.out.println(numPriors + " -> " + priors.size());
    for (int[] prior : priors) {
      Grid g = new Grid(prior, targetGrid.getWidth()+2);
      if (!isToroidal(prior)) {
        //System.out.println("Not toroidal:");
        //System.out.println(g);
        continue;
      }

      //System.out.println("toroidal:");
      //System.out.println(g);
      Grid newTargetGrid = g.subgrid(1, 1, g.getWidth() - 2, g.getHeight() - 2);
      int[] result = find(newTargetGrid, numPriors - 1);
      if (result != null) {
        //System.out.println(newTargetGrid);
        return result;
      }
      //System.out.println("... but no prior at level " + numPriors);
    }

    return null;
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
