class Grid
  attr_reader :rows, :cols, :cells
  
  def initialize(rows, cols)
    @rows = rows
    @cols = cols
    @cells = blank_grid(rows, cols)
  end

  def blank_grid(rows, cols)
    cells = []
    rows.times do
      row = []
      cols.times do
        row << false
      end
      cells << row
    end
    cells
  end

  def set(x, y, alive=true)
    @cells[y][x] = alive
  end
  
  def get(x, y)
    @cells[y][x]
  end
  
  def to_s
    topbottom = "+" + "-" * @cols + "+"
    
    lines = [topbottom]
    
    @cells.each do |row|
      lines << "|" + row.map{|cell| cell ? "X" : " "}.join("") + "|"
    end
    
    lines << topbottom
    
    lines.join("\n")
  end
  
  def next_generation
    output_grid = Grid.new(@rows, @cols)

    for y in 0...@rows
      for x in 0...@cols
        n = Grid.live_neighbors(self, x, y).size
        if get(x, y)
          # dies if < 2 live neighbors or > 3
          if n == 2 || n == 3
            output_grid.set(x, y, true)
          end
        else
          if n == 3
            output_grid.set(x, y, true)
          end
        end
      end
    end
    output_grid
  end

  def prior_generations
    cells_with_living_neighbors = []
    cells_currently_living = []
    for x in 0...@cols
      for y in 0...@rows
        cells_currently_living << [x, y] if get(x, y)
        cells_with_living_neighbors << [x, y] if Grid.live_neighbors(self, x, y).size > 0
      end
    end
    # puts cells_with_living_neighbors.sort.map{|c| "(" + c.join(",") + ")"}.join(",")
    # puts cells_currently_living.size
    # puts cells_with_living_neighbors.size

    count = 0
    puts "Found #{(cells_with_living_neighbors + cells_currently_living).uniq.size} living cells and cells that could have been living last iteration."
    for_each_permutation((cells_with_living_neighbors + cells_currently_living).uniq) do |living_cells|
      cand_grid = Grid.from_cells(@rows, @cols, living_cells)
      if cand_grid != Grid.from_cells(@rows, @cols, living_cells)
        raise "== not implemented the way you think"
      end
      nxt_grid = cand_grid.next_generation
      if nxt_grid == self
        puts "Found a candidate prior generation!"
        puts cand_grid
      end
      count += 1
    end
    puts count
    exit
  end

  def for_each_permutation(l, so_far=[], &block)
    if l.empty?
      block.call(so_far)
    else
      l = l.dup
      nxt = l.shift
      for_each_permutation(l, so_far + nxt, &block)
      for_each_permutation(l, so_far, &block)
    end
  end

  def ==(other)
    @cells == other.cells
  end

  class << self
    def live_neighbors(grid, x, y)
      out = []
      ((x-1)..(x+1)).each do |x1|
        ((y-1)..(y+1)).each do |y1|
          next if x1 == x && y1 == y
          next if x1 < 0 || x1 >= grid.cols 
          next if y1 < 0 || y1 >= grid.rows 

          out << [x1, y1] if grid.get(x1,y1)
        end
      end
      out
    end
    
    def from_cells(rows, cols, list_of_cells)
      g = Grid.new(rows, cols)
      list_of_cells.each do |xy|
        g.set(xy[0], xy[1])
      end
      g
    end
  end

end