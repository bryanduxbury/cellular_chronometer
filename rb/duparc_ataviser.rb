require "./grid.rb"

class DuparcAtaviser
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
    @pg_by_bottom_edge_archetype = {}
    @pg_by_row_archetype = {}
    
    # puts @ma.size
    # puts @mb.size
    # puts @mc.size
  end

  def prior_generations(grid, extra=0)
    rows = grid.by_row

    # pull off the first row to make the initial seeds
    seeds = row_priors(grid.cols,extra, rows.shift.map { |pt| pt.translate(extra,0).x }).map { |seed| to_bv_rows(seed, 3, grid.cols, extra) }
    if extra == 0
      # filter out seeds that have nonzero top row
      seeds = seeds.select {|seed| seed.first == "0" * grid.cols}
    end
    puts "initial seeds from top row: #{seeds.size}"

    until rows.empty?
      cur = rows.shift.map{|pt|pt.translate(extra,0).x}
      #   # puts cur.inspect
      priors = row_priors(grid.cols, extra, cur).map{|prior| to_bv_rows(prior, 3, grid.cols, extra)}
      puts "partial priors for next row: #{priors.size}"

      new_seeds = []
      grouped_seeds = seeds.group_by{|seed| seed[-2..-1]}
      #   # puts grouped_seeds.inspect
      priors.each do |prior|
        # puts prior.inspect
        matches = grouped_seeds[prior[0..1]]
        if matches
          matches.each do |match|
            merged = (match.dup << prior[2])
            # puts Grid.from_cells(grid.rows, grid.cols, to_pt_list(merged))
            new_seeds << merged
          end
        end
      end
      seeds = new_seeds
      puts "new seeds from intersection with this row: #{seeds.size}"
    end

    if extra == 0
      # filter out seeds that have nonzero bottom row
      seeds = seeds.select {|seed| seed.last == "0" * grid.cols}.map { |seed| seed[1..-2] }
    end

    puts "reached #{seeds.size} final seeds!"
    seeds.map { |seed| to_pt_list(seed) }
  end

  private

  # cols should be colnums 1 <= x < numcols-1
  def row_priors(numcols, extra, cols)
    ret = @pg_by_row_archetype[cols]

    unless ret
      row_neighbors = (0...(numcols+extra*2)).to_a.product((0..2).to_a).map{|xy| Pt.new(xy.first, xy.last)}

      puts "need to calculate priors for row archetype #{cols.inspect}"
      total = 2**row_neighbors.size
      count = 0

      ret = []

      for_each_combination(row_neighbors, []) do |live_neighbors|
        count += 1
        print "\r#{(count.to_f / total * 100).to_i}% complete"
        tg = Grid.new(3, numcols + extra*2)
        live_neighbors.each do |xy|
          tg.set(xy.x, xy.y)
        end
        # puts tg
        # puts "yields"
        ng = tg.next_generation
        # puts ng
        # puts ng
        extra_cells = (0...extra).to_a + (0...extra).map { |x| -1 - x }
        # puts extra
        # puts extra_cells.inspect
        if ng.by_row[1].map(&:x) - extra_cells == cols
          ret << live_neighbors
        # else
        #   puts tg
        #   puts "doesn't lead to pattern #{cols.inspect}"
        #   puts ng
        end
        
      end
      puts
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

  def to_bv_rows(points, numrows, numcols, extra)
    by_row = points.group_by{|xy| xy.y}
    (0...numrows).map{|rownum| to_bv((by_row[rownum] || []).map{|pt| pt.x}, numcols, extra)}
  end

  def to_bv(lst, numcols, extra)
    ret = ""
    for x in 0...(numcols+extra*2)
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