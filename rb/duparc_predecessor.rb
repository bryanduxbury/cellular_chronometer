require "./grid.rb"
require "jcode"

class DuparcPredecessor
  def initialize()
    # establish the 3x3 helpers
    # border = ((-1..1).to_a).product((-1..1).to_a) - [[0,0]]
    # 
    # @ma = []
    # @mb = []
    # @mc = []
    # for_each_combination(border, [], 2) do |sln|
    #   @mc << sln
    #   @ma << (sln.dup << [0,0])
    # end
    # 
    # for_each_combination(border, [], 3) do |sln|
    #   @mb << (sln << [0,0])
    # end

    @pg_by_edge_archetype = {}
    @pg_by_row_archetype = {}
    
    # puts @ma.size
    # puts @mb.size
    # puts @mc.size
  end

  def prior_generations(grid)
    rows = grid.by_row

    # start with the top 2 rows
    top = [rows.shift.map(&:x)] + [rows.shift.map(&:x)]
    seeds = edge_priors(grid, top).map{|seed| to_bv_rows(seed, 3, grid.cols)}
    puts "initial seeds from top row: #{seeds.size}"
    puts seeds.inspect

    until rows.size == 1
      cur = rows.shift.map(&:x)
      priors = row_priors(grid,cur).dup.map{|prior| to_bv_rows(prior, 3, grid.cols)}
      puts "partial priors for next row: #{priors.size}"

      new_seeds = []
      grouped_seeds = seeds.group_by{|seed| seed[-2..-1]}
      # puts grouped_seeds.inspect
      priors.each do |prior|
        matches = grouped_seeds[prior[0..1]]
        if matches
          matches.each do |match|
            new_seeds << (match.dup << prior[2])
          end
        end
      end
      # seeds.sort_by{|seed| seed[-2..-1]}.each do |seed|
      #   priors.sort_by{|prior| prior[0..1]}.each do |prior|
      #     # break if (seed[-2] < prior[0])
      #     puts "attempting to join #{seed.inspect} with #{prior.inspect}"
      #     if seed[-2..-1] == prior[0..1]
      #       puts "matched"
      #       new_seeds << (seed.dup << prior[2])
      #     end
      #   end
      # end
      seeds = new_seeds
      puts "new seeds from intersection with this row: #{seeds.size}"
    end

    # the bottom row is irrelevant, because one of our seeds MUST be correct. we'll just round-trip them to filter the ones that don't work.
    final_solutions = []
    seeds.each do |seed|
      cand_grid = Grid.from_cells(grid.rows, grid.cols, to_pt_list(seed))
      if cand_grid.next_generation == grid
        final_solutions << seed
      end
    end

    # tackle the bottom
    # bottom_row = rows.shift.map(&:x)
    # if_it_were_top = edge_priors(grid, bottom_row)
    # puts if_it_were_top.map{|prior| to_bv_rows(prior, 2, grid.cols)}.inspect
    # bottom_priors = if_it_were_top.map{|prior| to_bv_rows(prior, 2, grid.cols).reverse}
    # puts bottom_priors.inspect
    # puts "priors for bottom row: #{bottom_priors.size}"
    # 
    # final_solutions = []
    # 
    # grouped_seeds = seeds.group_by{|seed| seed[-2..-1]}
    # # puts grouped_seeds.inspect
    # # puts bottom_priors.inspect
    # bottom_priors.each do |prior|
    #   matches = grouped_seeds[prior[0..1]]
    #   if matches
    #     matches.each do |match|
    #       final_solutions << match
    #     end
    #   end
    # end
    # 
    puts "reached #{final_solutions.size} fully compliant solutions!"
    # # puts final_solutions.inspect
    # # trns = to_pt_list(final_solutions)
    # # puts trns.inspect
    # # trns
    final_solutions.map{|sln| to_pt_list(sln)}
  end

  private

  def edge_priors(grid, row1and2)
    ret = @pg_by_edge_archetype[row1and2]

    unless ret
      row_neighbors = (0...grid.cols).to_a.product((0..2).to_a).map{|xy| Pt.new(xy.first, xy.last)}

      puts "need to calculate priors for edge archetype #{row1and2.inspect}"
      ret = []

      for_each_combination(row_neighbors, []) do |live_neighbors|
        # puts live_neighbors.inspect
        tg = Grid.new(3, grid.cols)
        live_neighbors.each do |pt|
          tg.set(pt.x, pt.y)
        end
        ng = tg.next_generation

        result_rows = ng.by_row

        if result_rows[0].map(&:x).sort == row1and2[0] && result_rows[1].map(&:x).sort == row1and2[1]
          ret << live_neighbors.dup
        # else
        #   puts tg
        #   puts "doesn't lead to pattern #{row1and2.inspect}"
        #   puts ng
        end

      end
      @pg_by_edge_archetype[row1and2] = ret
      # ret.each do |pts|
      #   puts Grid.from_cells(3, grid.cols, pts)
      # end
      # 
      # exit
    end

    ret
  end

  def row_priors(grid, cols)
    ret = @pg_by_row_archetype[cols]

    unless ret
      row_neighbors = (0...grid.cols).to_a.product((0..2).to_a).map{|xy| Pt.new(xy.first, xy.last)}

      puts "need to calculate priors for row archetype #{cols.inspect}"
      ret = []

      for_each_combination(row_neighbors, []) do |live_neighbors|
        tg = Grid.new(3, grid.cols)
        live_neighbors.each do |xy|
          tg.set(xy.x, xy.y)
        end
        ng = tg.next_generation
        if ng.by_row[1].map(&:x).sort == cols
          ret << live_neighbors
        # else
        #   puts tg
        #   puts "doesn't lead to pattern #{cols.inspect}"
        #   puts ng
        end
        
      end

      @pg_by_row_archetype[cols] = ret
    end

    ret
  end

  def to_pt_list(bv_rows)
    pts = []
    for y in 0...bv_rows.size
      row = bv_rows[y]
      next if row.nil?
      for x in 0...(row.size)
        if row[x...x+1] == "1"
          pts << Pt.new(x,y)
        end
      end
    end
    pts
  end

  def to_bv_rows(points, numrows, numcols)
    by_row = points.group_by{|xy| xy.y}
    (0...numrows).map{|rownum| to_bv((by_row[rownum] || []).map{|pt| pt.x}, numcols)}
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

  slns = DuparcPredecessor.new.prior_generations(g)
  puts slns.group_by{|sln| sln.size}.map{|size, slns| [size, slns.size]}.inspect
  # min_sln = slns.sort_by{|sln| sln.size}.first
  
  # puts min_sln.inspect
end