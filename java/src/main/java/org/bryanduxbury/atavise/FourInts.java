package org.bryanduxbury.atavise;

public final class FourInts {
  private final int a;
  private final int b;
  private final int c;
  private final int d;

  public FourInts(int a, int b, int c, int d) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof FourInts)) return false;

    FourInts fourInts = (FourInts) o;

    if (a != fourInts.a) return false;
    if (b != fourInts.b) return false;
    if (c != fourInts.c) return false;
    if (d != fourInts.d) return false;

    return true;
  }

  @Override
  public int hashCode() {
    int result = a;
    result = 31 * result + b;
    result = 31 * result + c;
    result = 31 * result + d;
    return result;
  }
}
