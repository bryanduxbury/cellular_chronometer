package org.bryanduxbury.atavise;

public class RetainAll implements SolutionFilter {
  @Override public boolean keep(int rowWidth, int[] rows) {
    return true;
  }
}
