require "./grid.rb"

class DuparcAtaviser
  def initialize(row_ataviser)
    @row_ataviser = row_ataviser
  end

  def prior_generations(grid)
    prior_generations_bfs(grid)
    # prior_generations_dfs(grid, extra)
  end

  def prior_generations_bfs(grid)
    rows = grid.by_row

    # pull off the first row to make the initial seeds
    seeds = @row_ataviser.atavise(grid.cols, rows.shift.map { |pt| pt.translate(1,0).x })
    # puts "seeds size: #{seeds.size}"
    # puts "uniq seeds size: #{seeds.uniq.size}"
    # if extra == 0
    #       # filter out seeds that have nonzero top row
    #       seeds = seeds.select {|seed| seed.first == 0}
    #     end
    # puts "initial seeds from top row: #{seeds.size}"

    until rows.empty? || seeds.empty?
      cur = rows.shift.map{|pt|pt.translate(1,0).x}
      #   # puts cur.inspect
      priors = @row_ataviser.atavise(grid.cols, cur)
      # puts "partial priors for next row: #{priors.size}"

      new_seeds = []
      grouped_seeds = seeds.group_by{|seed| seed[-2..-1]}
      seeds = nil
      #   # puts grouped_seeds.inspect
      # count = 0
      priors.each do |prior|
        # count +=1
        # print "\r#{(count.to_f/priors.size * 100).to_i}%"

        matches = grouped_seeds[prior[0..1]]
        if matches
          p2 = prior[2]
          matches.each do |match|
            merged = (match.dup << p2)
            new_seeds << merged
          end
        end
      end
      # puts

      seeds = new_seeds[0...5000000]
      # puts "new seeds from intersection with this row: #{seeds.size}"
    end

    # if extra == 0
    #   # filter out seeds that have nonzero bottom row
    #   seeds = seeds.select {|seed| seed.last == 0}.map { |seed| seed[1..-2] }
    # end

    # puts "reached #{seeds.size} final seeds!"
    seeds.map { |seed| Pt.bv_rows_to_pts(seed) }
  end

  def prior_generations_dfs(grid, extra=0)
    solutions = []
    prior_generations_dfs_first_row(grid, extra) do |solution|
      if extra > 0 || solution.select{|pt| pt.y == grid.rows}.size == 0
        solutions << solution
        print "\r#{solutions.size} found so far"
      end
    end
    puts
    # if extra == 0
      # trim solutions to size
      # solutions = solutions.map{|solution| solution[1..-2]}
    # end

    puts "reached #{solutions.size} final results!"

    solutions
  end
  
  def prior_generations_dfs_first_row(grid, extra=0, &on_detect)
    rows = grid.by_row

    # pull off the first row to make the initial seeds
    seeds = @row_ataviser.atavise(grid.cols, extra, rows.shift.map { |pt| pt.translate(extra,0).x })
    if extra == 0
      # filter out seeds that have nonzero top row
      seeds = seeds.select {|seed| seed.first == 0}
    end
    # puts "initial seeds from top row: #{seeds.size}"
    # puts seeds.inspect

    seeds.each do |seed|
      prior_generations_dfs_driver(grid, rows, extra, seed, &on_detect)
    end
    # puts

  end

  def prior_generations_dfs_driver(grid, rows, extra, so_far, &on_completion)
    if rows.empty?
      if extra == 0 
        # only accept solutions with an empty final row
        if so_far[-1] == 0
          # trim solutions to size
          on_completion.call(Pt.bv_rows_to_pts(so_far[1..-2]))
        end
      else
        on_completion.call(Pt.bv_rows_to_pts(so_far))
      end
    else
      cur = rows.first.map{|pt|pt.translate(extra,0).x}

      priors = @row_ataviser.atavise(grid.cols, extra, cur)
      # puts "partial priors for next row: #{priors.size}"

      priors.each do |prior|
        if so_far[-2..-1] == prior[0..1]
          merged = (so_far.dup << prior[2])
          prior_generations_dfs_driver(grid, rows[1..-1], extra, merged, &on_completion)
        end
      end
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