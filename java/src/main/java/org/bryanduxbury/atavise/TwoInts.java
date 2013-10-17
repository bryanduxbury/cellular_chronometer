package org.bryanduxbury.atavise;

public final class TwoInts {
  private final int a;
  private final int b;

  public TwoInts(int a, int b) {
    this.a = a;
    this.b = b;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof TwoInts)) return false;

    TwoInts twoInts = (TwoInts) o;

    if (a != twoInts.a) return false;
    if (b != twoInts.b) return false;

    return true;
  }

  @Override
  public int hashCode() {
    int result = a;
    result = 31 * result + b;
    return result;
  }
}
