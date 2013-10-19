//package org.bryanduxbury.atavise.search;
//
//import java.io.File;
//import java.io.FileNotFoundException;
//import java.io.FileOutputStream;
//import java.io.IOException;
//import java.io.PrintWriter;
//import java.util.Arrays;
//import java.util.Collection;
//import org.bryanduxbury.atavise.row_ataviser.CachingRowAtaviser;
//import org.bryanduxbury.atavise.Grid;
//import org.bryanduxbury.atavise.grid_ataviser.HierarchicalDuparcGridAtaviser;
//import org.bryanduxbury.atavise.row_ataviser.IntersectingRowAtaviser;
//import org.bryanduxbury.atavise.solution_filter.TubularRowFilter;
//import org.bryanduxbury.atavise.solution_indexer.SimpleIndex;
//import org.bryanduxbury.atavise.solution_indexer.UniqueBordersIndexer;
//import org.bryanduxbury.atavise.solution_limiter.Aggressive;
//import org.bryanduxbury.atavise.solution_limiter.HardLimit;
//
//public class Maximum {
//  private static class SearchResult {
//    int[] grid;
//    int maxDepth;
//  }
//
//
//  private final HierarchicalDuparcGridAtaviser fastAtaviser;
//  private final HierarchicalDuparcGridAtaviser thoroughAtaviser;
//
//  public Maximum() {
//    Aggressive.Factory aggressive = new Aggressive.Factory(10000000);
//    HardLimit.Factory hard = new HardLimit.Factory(24000000);
//    CachingRowAtaviser rowAtaviser =
//        new CachingRowAtaviser(new IntersectingRowAtaviser(new TubularRowFilter()));
//
//
//    fastAtaviser = new HierarchicalDuparcGridAtaviser(rowAtaviser, aggressive, new UniqueBordersIndexer());
//    thoroughAtaviser = new HierarchicalDuparcGridAtaviser(rowAtaviser, hard, new SimpleIndex());
//
//  }
//
//  private void search(int maxPriors, String gridFilePath) throws IOException {
//    // load target from gridFilePath
//    Grid targetGrid = Grid.fromFile(gridFilePath);
//
//    if (targetGrid.getWidth() > targetGrid.getHeight()) {
//      targetGrid = targetGrid.transpose();
//    }
//
//    // run find() recursively
//    int[] result = find(targetGrid, maxPriors, 0);
//
//    if (result == null) {
//      System.out.print("-");
//    } else {
//      writeResult(targetGrid, result, gridFilePath, maxPriors);
//      System.out.print("+");
//    }
//  }
//
//  private SearchResult find(Grid targetGrid, int maxPriors, int depthSoFar) {
//    if (maxPriors == depthSoFar) {
//      return targetGrid.getCells();
//    } else {
//      Collection<int[]> priors = fastAtaviser.atavise(targetGrid);
//      //if (priors.size() > 0) {
//      //  priors = thoroughAtaviser.atavise(targetGrid);
//      //}
//
//      int[] result = examinePriors(targetGrid, maxPriors, priors);
//      //if (result == null) {
//      //  Collection<int[]> thoroughPriors = thoroughAtaviser.atavise(targetGrid);
//      //  thoroughPriors.removeAll(priors);
//      //  result = examinePriors(targetGrid, numPriors, thoroughPriors);
//      //}
//
//      return result;
//    }
//  }
//
//  private void writeResult(Grid targetGrid, int[] result, String gridFilePath, int numPriors)
//      throws FileNotFoundException {
//
//    File f = new File(gridFilePath + "__back_" + numPriors);
//    f.delete();
//    PrintWriter pw = new PrintWriter(new FileOutputStream(f));
//    pw.println(Arrays.toString(targetGrid.getCells()));
//    pw.println(Arrays.toString(result));
//    pw.close();
//  }
//
//  private int[] examinePriors(Grid targetGrid, int numPriors, Collection<int[]> priors) {
//    //System.out.println(numPriors + " -> " + priors.size());
//    for (int[] prior : priors) {
//      Grid g = new Grid(prior, targetGrid.getWidth()+2);
//      if (!isToroidal(prior)) {
//        //System.out.println("Not toroidal:");
//        //System.out.println(g);
//        continue;
//      }
//
//      //System.out.println("toroidal:");
//      //System.out.println(g);
//      Grid newTargetGrid = g.subgrid(1, 1, g.getWidth() - 2, g.getHeight() - 2);
//      int[] result = find(newTargetGrid, numPriors - 1);
//      if (result != null) {
//        //System.out.println(newTargetGrid);
//        return result;
//      }
//      //System.out.println("... but no prior at level " + numPriors);
//    }
//
//    return null;
//  }
//
//  private boolean isToroidal(int[] cells) {
//    return cells[0] == cells[cells.length - 2] && cells[1] == cells[cells.length - 1];
//  }
//
//  public static void main(String[] args) throws IOException {
//    Maximum s = new Maximum();
//
//    long startTime = System.currentTimeMillis();
//    int numPriors = Integer.parseInt(args[0]);
//    for (int i = 1; i < args.length; i++) {
//      s.search(numPriors, args[i]);
//    }
//    System.out.println();
//    long endTime = System.currentTimeMillis();
//    System.out.println("Elapsed ms: " + (endTime - startTime));
//  }
//}
