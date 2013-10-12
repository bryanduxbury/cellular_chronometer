package org.bryanduxbury.atavise.solution_filter;

public class RetainAll implements SolutionFilter {
  @Override public boolean keep(int rowWidth, int[] rows) {
    return true;
  }
}
