require "./grid.rb"
require "jcode"

class DuparcPredecessor
  def initialize()
    # establish the 3x3 helpers
    border = ((-1..1).to_a).product((-1..1).to_a) - [[0,0]]

    @ma = []
    @mb = []
    @mc = []
    for_each_combination(border, [], 2) do |sln|
      @mc << sln
      @ma << (sln.dup << [0,0])
    end

    for_each_combination(border, [], 3) do |sln|
      @mb << (sln << [0,0])
    end

    @pg_by_edge_archetype = {}
    @pg_by_row_archetype = {}
    
    # puts @ma.size
    # puts @mb.size
    # puts @mc.size
  end
  
  def prior_generations(grid)
    

    # now, on to the actual processing.
    rows = grid.by_row

    # start with the top row
    top = rows.shift.map(&:x)
    seeds = edge_priors(grid, top).map{|seed| to_bv_rows(seed, grid.cols)}
    puts "initial seeds from top row: #{seeds.size}"

    until rows.size == 1
      cur = rows.shift.map(&:x)
      priors = row_priors(grid,cur).map{|prior| to_bv_rows(prior, grid.cols)}
      puts "partial priors for next row: #{priors.size}"

      new_seeds = []
      seeds.each do |seed|
        priors.each do |prior|
          if seed[-2] == prior[0] && seed[-1] == prior[1]
            new_seeds << (seed.dup << prior[2])
          end
        end
      end
      seeds = new_seeds
      puts "new seeds from intersection with this row: #{seeds.size}"
    end

    # tackle the bottom
    bottom_row = rows.shift
    bottom_priors = edge_priors(grid, top).reverse.map{|prior| to_bv_rows(prior, grid.cols)}
    puts "priors for bottom row: #{bottom_priors.size}"

    final_solutions = []
    seeds.each do |seed|
      priors.each do |prior|
        if seed[-2] == prior[0] && seed[-1] == prior[1]
          final_solutions << seed
        end
      end
    end

    puts "reached #{final_solutions.size} fully compliant solutions!"
    # puts final_solutions.inspect
    final_solutions
  end

  private

  def edge_priors(grid, cols)
    edge_neighbors = (0...grid.cols).to_a.product((0..1).to_a).map{|xy| Pt.new(xy.first, xy.last)}

    ret = @pg_by_edge_archetype[cols]

    unless ret
      puts "need to calculate priors for archetype #{cols.inspect}"
      ret = []

      for_each_combination(edge_neighbors, []) do |live_neighbors|
        # puts live_neighbors.inspect
        tg = Grid.new(2, grid.cols)
        live_neighbors.each do |pt|
          tg.set(pt.x, pt.y)
        end
        ng = tg.next_generation
        if ng.by_row.first.map(&:x).sort == cols
          ret << live_neighbors
        end
      end

      @pg_by_edge_archetype[cols] = ret
    end

    ret
  end

  def row_priors(grid, cols)
    row_neighbors = (0...grid.cols).to_a.product((0..2).to_a).map{|xy| Pt.new(xy.first, xy.last)}

    ret = @pg_by_row_archetype[cols]

    unless ret
      puts "need to calculate priors for archetype #{cols.inspect}"
      ret = []

      for_each_combination(row_neighbors, []) do |live_neighbors|
        tg = Grid.new(3, grid.cols)
        live_neighbors.each do |xy|
          tg.set(xy.x, xy.y)
        end
        ng = tg.next_generation
        if ng.by_row[1].map(&:x).sort == cols
          ret << live_neighbors
        end
      end

      @pg_by_row_archetype[cols] = ret
    end

    ret
  end

  def to_bv_rows(points, numcols)
    by_row = points.group_by{|xy| xy.y}
    by_row.keys.sort.map{|rownum| to_bv(by_row[rownum].map{|pt| pt.x}, numcols)}
  end

  def to_bv(lst, numcols)
    ret = ""
    for x in 0...numcols
      ret << (lst.include?(x) ? "1" : "0")
    end
    ret
  end

  def for_each_combination(inputs, so_far = [], desired_length=nil, &block)
    if desired_length == 0 || (desired_length.nil? && inputs.empty?)
      block.call(so_far)
    elsif !desired_length.nil? && desired_length > inputs.size
      # prune this branch
    else
      inputs = inputs.dup
      nxt = inputs.shift

      for_each_combination(inputs, so_far.dup, desired_length, &block)
      for_each_combination(inputs, so_far.dup << nxt, desired_length.nil? ? nil : desired_length - 1, &block)
    end
  end
end

if $0 == __FILE__
  g = Grid.new(10,4)
  
  g.set(0,5)
  g.set(0,6)
  g.set(3,5)
  g.set(3,6)
  g.set(1,4)
  g.set(2,4)
  g.set(1,7)
  g.set(2,7)
  
  puts "target pattern:"
  puts g
  # add a glider to upper left
  # g.set(1, 0)
  #   g.set(2, 1)
  #   g.set(0, 2)
  #   g.set(1, 2)
  #   g.set(2, 2)
    
  # 5.times do
  #   g = g.next_generation
  # end

  DuparcPredecessor.new.prior_generations(g).each do |sln|
    puts "----"
    puts sln.join("\n")
  end
end