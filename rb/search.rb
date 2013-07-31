require "./grid.rb"
require "./duparc_ataviser.rb"

class Search
  def initialize
    @ataviser = DuparcAtaviser.new
  end
  
  def find_predecessor_sequence(num_priors, target_pattern_file)
    target_grid = load_target_pattern(target_pattern_file)
    
    results = find(target_grid, num_priors)
  end
  
  
  private
  
  def find(target_grid, num_priors)
    if num_priors == 0
      # made it all the way to the end. return the grid we were passed.
      [target_grid]
    else
      # compute prior generations
      # this will include some solutions that go outside the boundaries of the target grid
      # in the case that there are no solutions that do keep the target boundaries, 
      # we'll have to select the narrowest one that actually works.

      # search for the target grid. the ataviser will look one extra cell in each direction.
      prior_generations = @ataviser.prior_generations(target_grid)
      
      # no priors, we've reached a dead end.
      # i don't really think this can happen.
      if prior_generations.empty?
        puts "hey, that's weird. this target grid has no priors even with an extra border!"
        puts target_grid
        return nil
      end
      
      # first, find all the solutions that have an empty border
      constrained_solutions = prior_generations.select{|prior| empty_border?(prior)}
      
      if constrained_solutions.any?
        # excellent! let's use the first constrained solution and recurse
        return [prior] + find(prior, num_priors-1)
      end
      
      # hm, looks like we didn't find any constrained solutions.
      # let's move on to solutions that just work.
      return [priors.first] + find(priors.first, num_priors-1)
    end
  end

  def empty_border?(grid)
    empty_row?(grid, 0) && empty_row?(grid, grid.rows-1) && empty_column?(grid, 0) && empty_column?(grid, grid.cols-1)
  end

  def empty_row?(grid, y)
    (0...grid.cols).each do |x|
      return false if grid.get(x,y)
    end
    return true
  end

  def empty_column?(grid, x)
    (0...grid.rows).each do |y|
      return false if grid.get(x,y)
    end
    return true
  end

  def load_target_pattern(filename)
    str = File.read(filename)

    living_cells = []

    rows = str.split("\n")
    rownum = 0
    rows.each do |row|
      colnum = 0
      row.split("").each do |char|
        if char != " "
          living_cells << Pt.new(colnum, rownum)
        end
        colnum += 1
      end
      rownum += 1
    end

    Grid.from_cells(rows.size, rows.map { |row| row.size }.max, living_cells)
  end
end


if $0 == __FILE__
  Search.new.find_predecessor_sequence(ARGV.shift, ARGV.shift)
end