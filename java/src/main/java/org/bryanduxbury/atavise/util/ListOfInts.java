package org.bryanduxbury.atavise.util;

import java.util.Arrays;

public class ListOfInts {
  private final int[] ints;
  private final int startIdx;
  private final int endIdx;

  public ListOfInts(int[] ints, int startIdx, int endIdx) {
    this.ints = ints;
    this.startIdx = startIdx;
    this.endIdx = endIdx;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof ListOfInts)) return false;

    ListOfInts that = (ListOfInts) o;

    int len = endIdx - startIdx;
    if (len != that.endIdx - that.startIdx) {
      return false;
    }

    for (int i = startIdx, j = that.startIdx; i < endIdx && j < that.endIdx; i++, j++) {
      if (ints[i] != that.ints[j]) {
        return false;
      }
    }

    return true;
  }

  @Override
  public int hashCode() {
    int hash = 0;
    if (ints != null) {
      for (int i = startIdx; i < endIdx; i++) {
        hash = 31 * hash + ints[i];
      }
    }
    return hash;
  }
}
