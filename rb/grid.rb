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

    lines << topbottom

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
      # cx, cy = *living_cell
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

    # print "neighbor counts: "
    # puts neighbor_count.inspect

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

    # print "new living cells: "
    # puts new_living_cells.inspect

    Grid.new(rows, cols, new_living_cells)
  end

  def prior_generations_3
    solns_by_living_cell = {}
    solns = []

    # index_soln = lambda do |combo|
    #   # find all compatible existing soln
    #   for coord in combo
    #     for existing_soln in solns_by_living_cell[coord]
    #       existing_soln.append(combo)
    #     end
    #   end
    # end

    for cell in @cells.keys
      b = []
      for x in bounded_neighbors(cell[0], @cols)
        for y in bounded_neighbors(cell[1], @rows)
          b << [x,y] unless [x,y] == cell
        end
      end

      these_solns = []

      accumulate_solns = lambda do |combo|
        these_solns << combo
      end

      # assume it was dead
      Grid.for_each_combination(b, [], 3, &accumulate_solns)

      # assume it was living 2
      Grid.for_each_combination(b, [cell], 2, &accumulate_solns)

      # assume it was living 3
      Grid.for_each_combination(b, [cell], 3, &accumulate_solns)

      if solns.empty?
        solns = these_solns
      else
        # eliminate incompatible solns
        # puts solns.inspect
        # puts these_solns.inspect
        # puts solns.product(these_solns).size
        solns = solns.product(these_solns).select {|two_solns| compatible?(*two_solns)}.map { |two_solns| two_solns[0] + two_solns[1]}
      end
      puts solns.size
    end

    exit

    # (0...@rows).each do |y|
    #   (0...@cols).each do |x|
    #     print ((cell_magnitudes[[x,y]] || "0").to_s ) + "\t"
    #   end
    #   puts
    # end
    # puts cell_magnitudes.inspect
  end

  def compatible?(l, r)
    for x in r
      return true if l.include?(x)
    end
    false
  end

  

  def prior_generations_2
    cell_magnitudes = {}

    increment_mags = lambda do |combo|
      for coord in combo
        c = cell_magnitudes[coord]
        c ||= 0
        c += 1
        cell_magnitudes[coord] = c
      end
    end

    for cell in @cells.keys
      b = []
      # puts cell.inspect
      for x in bounded_neighbors(cell[0], @cols)
        for y in bounded_neighbors(cell[1], @rows)
          b << [x,y] unless [x,y] == cell
        end
      end

      # assume it was dead
      Grid.for_each_combination(b, [], 3, &increment_mags)

      # assume it was living 2
      Grid.for_each_combination(b, [cell], 2, &increment_mags)

      # assume it was living 3
      Grid.for_each_combination(b, [cell], 3, &increment_mags)
    end

    # (0...@rows).each do |y|
    #   (0...@cols).each do |x|
    #     print ((cell_magnitudes[[x,y]] || "0").to_s ) + "\t"
    #   end
    #   puts
    # end
    # puts cell_magnitudes.inspect
    
    sorted_candidate_cells = cell_magnitudes.map { |coord, mag| [mag, coord] }.sort_by{|p| p[0]}.map { |pair| pair[1] }


    puts sorted_candidate_cells.size
    count = 0
    Grid.for_each_combination(sorted_candidate_cells, [], sorted_candidate_cells.size / 2) do |living_cells|
      count += 1
      if count % 10000 == 0
        puts count.to_f / 2**sorted_candidate_cells.size
      end
      cand_grid = Grid.from_cells(@rows, @cols, living_cells)

      nxt_grid = cand_grid.next_generation
      if nxt_grid == self
        puts "found a candidate!"
        puts cand_grid.to_s
        exit
        # candidate_prior_generations << living_cells
      end
    end
    
    exit
  end

  def prior_generations
    # puts "Found #{(cells_with_living_neighbors + cells_currently_living).uniq.size} living cells and cells that could have been living last iteration."

    candidate_prior_generations = []
    for_each_permutation(candidate_ancestor_cells()) do |living_cells|
      cand_grid = Grid.from_cells(@rows, @cols, living_cells)

      nxt_grid = cand_grid.next_generation
      if nxt_grid == self
        candidate_prior_generations << living_cells
      end
    end
    candidate_prior_generations
  end

  def find_first_ancestor(depth)
    # hey look at that, we're done
    if depth == 0
      return self
    end
    
    for_each_permutation(candidate_ancestor_cells()) do |living_cells|
      cand_grid = Grid.from_cells(@rows, @cols, living_cells)

      nxt_grid = cand_grid.next_generation
      if nxt_grid == self
        # if this returns nil, continue searching. otherwise, return this because we're done.
        a = cand_grid.find_first_ancestor(depth-1)
        return a if a
      end
    end
  
    # didn't find an ancestor at depth requested
    nil
  end

  def candidate_ancestor_cells
    cells_with_living_neighbors = []
    cells_currently_living = []
    for x in 0...@cols
      for y in 0...@rows
        cells_currently_living << [x, y] if get(x, y)
        cells_with_living_neighbors << [x, y] if Grid.live_neighbors(self, x, y).size > 0
      end
    end
    (cells_with_living_neighbors + cells_currently_living).uniq
  end

  def for_each_permutation(l, so_far=[], &block)
    if l.empty?
      block.call(so_far)
    else
      l = l.dup
      nxt = l.shift
      # do the "not includes" branch first, as it will tend to allow us to
      # evaluate the options with the fewest possible living cells first
      for_each_permutation(l, so_far.dup, &block)
      for_each_permutation(l, so_far.dup << nxt, &block)
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
      Grid.new(rows, cols, list_of_cells.inject({}){|hsh, xy| hsh[xy] = true; hsh})
    end

    def for_each_combination(inputs, so_far = [], desired_length=nil, &block)
      if desired_length == 0
        block.call(so_far)
      elsif desired_length > inputs.size
        # prune this branch
      else
        inputs = inputs.dup
        nxt = inputs.shift

        for_each_combination(inputs, so_far.dup, desired_length, &block)
        for_each_combination(inputs, so_far.dup << nxt, desired_length - 1, &block)
      end
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
