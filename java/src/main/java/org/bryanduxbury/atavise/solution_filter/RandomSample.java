package org.bryanduxbury.atavise.solution_filter;

import java.util.Random;

public class RandomSample implements SolutionFilter {
  private final double rate;
  private final Random rand;

  public RandomSample(double rate) {
    this.rate = rate;

    rand = new Random();
  }

  @Override
  public boolean keep(int rowWidth, int[] rows) {
    return rand.nextDouble() <= rate;
  }
}
