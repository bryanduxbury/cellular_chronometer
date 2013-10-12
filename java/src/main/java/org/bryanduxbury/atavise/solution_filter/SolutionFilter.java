package org.bryanduxbury.atavise.solution_filter;

public interface SolutionFilter {
  public boolean keep(int rowWidth, int[] rows);
}
