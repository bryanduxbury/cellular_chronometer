package org.bryanduxbury.atavise;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Grid {
  private final int[] cells;

  private final int width;
  public Grid(int[] cells, int width) {
    this.cells = cells;
    this.width = width;
  }

  public int getWidth() {
    return width;
  }

  public int getHeight() {
    return cells.length;
  }

  public int[] getCells() {
    return cells;
  }

  public Grid transpose() {
    int[] newCells = new int[getWidth()];
    for (int y = 0; y < getHeight(); y++) {
      for (int x = 0; x < getWidth(); x++) {
        if (isset(cells, x, y)) {
          set(newCells, y, x);
        }
      }
    }
    return new Grid(newCells, getHeight());
  }

  private static void set(int[] vector, int x, int y) {
    vector[y] = vector[y] | (1 << x);
  }

  public static boolean isset(int[] vector, int x, int y) {
    return (vector[y] & (1 << x)) != 0;
  }

  public static Grid fromFile(String path) throws IOException {
    List<String> lines = new ArrayList<String>();
    BufferedReader br = new BufferedReader(new FileReader(path));
    String line = br.readLine();
    while (line != null) {
      lines.add(line);
      line = br.readLine();
    }
    br.close();

    int[] result = new int[lines.size()];
    int maxWidth = 0;
    for (int i = 0; i < lines.size(); i++) {
      int thisRow = 0;

      String thisLine = lines.get(i);
      if (thisLine.length() > maxWidth) {
        maxWidth = thisLine.length();
      }

      for (int j = 0; j < thisLine.length();j++) {
        if (thisLine.charAt(j) != ' ') {
          thisRow |= (1 << j);
        }
      }
      result[i] = thisRow;
    }

    return new Grid(result, maxWidth);
  }
}
