package org.bryanduxbury.atavise.util;

import java.util.Arrays;

public class ListOfInts {
  private final int[] ints;

  public ListOfInts(int[] ints) {
    this.ints = ints;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof ListOfInts)) return false;

    ListOfInts that = (ListOfInts) o;

    if (!Arrays.equals(ints, that.ints)) return false;

    return true;
  }

  @Override
  public int hashCode() {
    return ints != null ? Arrays.hashCode(ints) : 0;
  }
}
