class Grid
  attr_reader :rows, :cols, :cells
  
  def initialize(rows, cols, cells = {})
    @rows = rows
    @cols = cols
    # @cells = blank_grid(rows, cols)
    @cells = cells
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
    @cells[[x,y]] = alive
  end
  
  def get(x, y)
    @cells[[x,y]] ? true : false
  end
  
  def to_s
    topbottom = "+" + "-" * @cols + "+"
    
    lines = [topbottom]

    grid = []
    for y in 0...@rows
      line = "|"
      for x in 0...@cols
        line << (get(x,y) ? "X" : " ")
      end
      line << "|"
      lines << line
    end

    # @cells.each do |row|
    #   lines << "|" + row.map{|cell| cell ? "X" : " "}.join("") + "|"
    # end
    
    lines << topbottom
    
    lines.join("\n")
  end
  
  def old_next_generation
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
  
  def bounded_neighbors(n,m)
    [0, n-1].max..[n+1,m].min
  end
  
  def next_generation
    new_living_cells = {}

    neighbor_count = {}

    # print "input cells: "
    # puts @cells.inspect
    @cells.keys.each do |living_cell|
      cx, cy = *living_cell
      for x in bounded_neighbors(cx, @cols-1)
        for y in bounded_neighbors(cy, @rows-1)
          next if x == cx && y == cy

          count_so_far = neighbor_count[[x,y]]
          if count_so_far.nil?
            count_so_far = 1
          else
            count_so_far += 1
          end
          neighbor_count[[x,y]] = count_so_far
        end
      end
    end

    # print "neighbor counts: "
    # puts neighbor_count.inspect

    neighbor_count.each do |coord, count|
      if get(*coord)
        if count == 2 || count == 3
          new_living_cells[coord] = true
        end
      else
        if count == 3
          new_living_cells[coord] = true
        end
      end
    end

    # print "new living cells: "
    # puts new_living_cells.inspect

    Grid.new(rows, cols, new_living_cells)
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
      # $stderr.puts living_cells.size
      cand_grid = Grid.from_cells(@rows, @cols, living_cells)
      # if cand_grid != Grid.from_cells(@rows, @cols, living_cells)
      #   raise "== not implemented the way you think"
      # end
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
      # do the "not includes" branch first, as it will tend to allow us to
      # evaluate the options with the fewest possible living cells first
      for_each_permutation(l, so_far, &block)
      for_each_permutation(l, so_far + nxt, &block)
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

if $0 == __FILE__
  puts "Starting next_generation performance test"
  g = Grid.new(10,10)
  # add a glider to upper left
  g.set(1, 0)
  g.set(2, 1)
  g.set(0, 2)
  g.set(1, 2)
  g.set(2, 2)
  10000.times do
    g.old_next_generation
  end
end
