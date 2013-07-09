# class Seed
#   def initialize(str)
#     rows = str.split("\n").map{|row| row.split("")}
#     cols = 
#   end
#   
#   
# end

class Grid
  attr_reader :rows, :cols
  
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
        n = Grid.live_neighbors(self, x, y)
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
    for x in 0..@cols
      for y in 0..@rows
        cells_with_living_neighbors << [x, y] if Grid.live_neighbors(self, x, y).size > 0
      end
    end
    # puts cells_with_living_neighbors.sort.map{|c| "(" + c.join(",") + ")"}.join(",")
    puts cells_with_living_neighbors.size
    exit
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
  end

end

# def print_grid(grid)
#   puts "+" + grid.first.map{|row| "-"}.join("") + "+"
#   puts grid.map{|row| "|" + row.join("") + "|"}.join("\n")
#   puts "+" + grid.first.map{|row| "-"}.join("") + "+"
# end
# 
# def live_neighbors(grid, x, y)
#   for a = Math.max(x - 1, 0)..Math.min
# end

# def generation(input_grid)
#   
# end

# grid = []
# 10.times do
#   grid << [" "] * 10
# end
# 
# grid[4][5] = "X"
# grid[5][5] = "X"
# grid[6][5] = "X"
# 
# print_grid(grid);

g = Grid.new(10, 10)


# the "toad"
# g.set(4, 4, true)
# g.set(5, 4, true)
# g.set(6, 4, true)
# g.set(5, 5, true)
# g.set(6, 5, true)
# g.set(7, 5, true)

# the "glider"
g.set(1, 0)
g.set(2, 1)
g.set(0, 2)
g.set(1, 2)
g.set(2, 2)

lwss =<<-EOF
 xxxx
x   x
    x
x  x
EOF
puts lwss

puts g.to_s
puts g.prior_generations

# # puts Grid.live_neighbors(g, 5, 5)
# 
# while gets
#   g = g.next_generation
#   puts g.to_s
# end