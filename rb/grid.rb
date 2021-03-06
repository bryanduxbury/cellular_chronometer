require "./pt.rb"

class Grid
  attr_reader :rows, :cols, :cells

  def initialize(rows, cols, cells = {})
    @rows = rows
    @cols = cols
    @cells = cells
  end

  def set(x, y, alive=true)
    @cells[Pt.new(x,y)] = alive
  end

  def place(x, y, pattern)
    r = pattern.split("\n").map { |row| row.split("") }
    c = r.first.size
    for y1 in 0...r.size
      for x1 in 0...c
        if r[y1][x1] != " "
          set(x + x1, y + y1)
        end
      end
    end
    nil
  end

  def get(x, y)
    @cells[Pt.new(x,y)] ? true : false
  end

  def by_row
    ret = {}
    @rows.times do |idx|
      ret[idx] = []
    end
    @cells.keys.each{|pt| ret[pt.y] << pt}
    ret.keys.sort.map {|rownum| ret[rownum]}
  end

  def to_row_vectors
    out = []
    for y in 0...rows
      cur = 0
      for x in 0...cols
        if get(x, y)
          cur = cur | (1 << x)
        end
      end
      out << cur
    end
    out
  end

  def to_bitvector
    out = []
    cur = 0
    count = 0
    for y in 0...rows
      for x in 0...cols
        if get(x,y)
          cur |= (1 << count)
        end
        count+=1
        if count == 8
          out << cur
          cur = 0
          count = 0
        end
      end
    end
    if count > 0
      out << cur
    end
    out
  end

  def make_toroidal
    new_cells = @cells.keys.map{|pt| pt.translate(1,1)}
    new_cells += @cells.keys.select{|pt| pt.y == 0}.map{|pt| Pt.new(pt.translate(1,1).x, @rows+1)}
    new_cells += @cells.keys.select{|pt| pt.y == (@rows - 1)}.map{|pt| Pt.new(pt.translate(1,1).x, 0)}
    new_cells += new_cells.select{|pt| pt.x == 1}.map{|pt| Pt.new(@cols+1, pt.y)}
    new_cells += new_cells.select{|pt| pt.x == (@cols + 1)}.map{|pt| Pt.new(0, pt.y)}
    Grid.from_cells(@rows + 2, @cols + 2, new_cells)
  end

  def to_s(show_border=true)
    topbottom = "+" + "-" * @cols + "+"

    lines = []
    lines << topbottom if show_border

    grid = []
    for y in 0...@rows
      line = ""
      line << "|" if show_border
      for x in 0...@cols
        line << (get(x,y) ? "#" : " ")
      end
      line << "|" if show_border
      lines << line
    end

    lines << topbottom if show_border

    lines.join("\n")
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
      for x in bounded_neighbors(living_cell.x, @cols-1)
        for y in bounded_neighbors(living_cell.y, @rows-1)
          next if x == living_cell.x && y == living_cell.y
          pt = Pt.new(x,y)
          count_so_far = neighbor_count[pt]
          if count_so_far.nil?
            count_so_far = 1
          else
            count_so_far += 1
          end
          neighbor_count[pt] = count_so_far
        end
      end
    end

    neighbor_count.each do |coord, count|
      if get(coord.x, coord.y)
        if count == 2 || count == 3
          new_living_cells[coord] = true
        end
      else
        if count == 3
          new_living_cells[coord] = true
        end
      end
    end

    Grid.new(rows, cols, new_living_cells)
  end

  def ==(other)
    @cells == other.cells
  end

  def subgrid(x1, y1, x2, y2)
    Grid.from_cells(y2-y1+1, x2-x1+1, @cells.keys.select{|cell| cell.x >= x1 && cell.x <= x2 && cell.y >= y1 && cell.y <= y2}.map{|pt| pt.translate(-x1, -y1)})
  end

  class << self
    def from_cells(rows, cols, list_of_cells)
      for cell in list_of_cells
        raise "#{cell} is out of bounds!" if cell.x < 0 || cell.x >= cols
        raise "#{cell} is out of bounds!" if cell.y < 0 || cell.y >= rows
      end
      Grid.new(rows, cols, list_of_cells.inject({}){|hsh, xy| hsh[xy] = true; hsh})
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
    g.next_generation
  end
end
