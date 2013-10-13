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

  public Grid nextGeneration() {
    int[] newCells = new int[getHeight()];

    for (int x = 0; x < getWidth(); x++) {
      for (int y = 0; y < getHeight(); y++) {
        int livingNeighbors = 0;
        for (int x1 = -1; x1 <= 1; x1++) {
          if (x + x1 < 0 || x + x1 >= getWidth()) continue;
          for (int y1 = -1; y1 <= 1; y1++) {
            if (y + y1 < 0 || y + y1 >= getHeight()) continue;
            if (x1 == 0 && y1 == 0) continue;

            if (isset(getCells(), x + x1, y + y1)) {
              livingNeighbors++;
            }
          }
        }

        if (isset(getCells(), x, y)) {
          if (livingNeighbors == 2 || livingNeighbors == 3) {
            set(newCells, x, y);
          }
        } else {
          if (livingNeighbors == 3) {
            set(newCells, x, y);
          }
        }
      }
    }

    return new Grid(newCells, getWidth());
  }

  public Grid makeToroidal() {
    int[] newCells = new int[getHeight()+2];
    for (int row = 0; row < getHeight(); row++) {
      int origRow = getCells()[row];

      newCells[row+1] = (origRow << 1) // middle bits are just the same as original, shifted up
          | ((origRow & (1 << (getWidth() - 1))) == 0 ? 0 : 1) // new bottom is set iff old top was set
          | ((origRow & 1) == 0 ? 0 : (1 << getWidth()+1)); // new top is set iff old bottom was set
    }

    newCells[0] = newCells[newCells.length - 2];
    newCells[1] = newCells[newCells.length - 1];

    return new Grid(newCells, getWidth() + 2);
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
