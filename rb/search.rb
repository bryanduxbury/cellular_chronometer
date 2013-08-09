require "./grid.rb"
require "./duparc_ataviser.rb"
require "./hierarchical_duparc_ataviser.rb"
require "./exhaustive_row_ataviser.rb"
require "./intersecting_row_ataviser.rb"

class Search
  def initialize
    # @ataviser = DuparcAtaviser.new(IntersectingRowAtaviser.new)
    @ataviser = HierarchicalDuparcAtaviser.new(IntersectingRowAtaviser.new)
  end
  
  def find_predecessor_sequence(num_priors, target_pattern_file)
    target_grid = load_target_pattern(target_pattern_file)
    transposed = false
    if target_grid.cols > target_grid.rows
      transposed = true
      target_grid = Grid.from_cells(target_grid.cols, target_grid.rows, target_grid.by_row.flatten.map(&:flip))
    end

    # result = find_dfs(target_grid, num_priors, 0)
    # 
    # if result.nil?
    #   raise "Couldn't find any constrained solutions. Expanding by 1 cell."
    #   # result = find_dfs(target_grid, num_priors, 1)
    #   # if result.nil?
    #   #   raise "Couldn't find anything expanded by one, either. Quitting."
    #   # end
    # end
    # 
    
    # puts result
    
    result = find(target_grid, num_priors)

    if result.nil?
      # puts "No priors found!"
    else
      File.open(target_pattern_file + "__back_#{num_priors}", "w+") do |file|
        if transposed
          result = Grid.from_cells(result.cols, result.rows, result.by_row.flatten.map(&:flip))
        end

        file.puts result.to_bitvector.inspect
        file.puts target_grid.to_bitvector.inspect
        file.puts result

        # g = result
        # puts g
        # (num_priors + 2).times do
        #   n = g.next_generation
        #   puts n
        #   g = n
        # end

      end
    end
  end

  private

  def find_dfs(target_grid, num_priors, extras)
    # puts "starting step #{num_priors}"
    if num_priors == 0
      return target_grid
      # puts "step 0:"
      #       puts target_grid
      #       return true
    end
    @ataviser.prior_generations_dfs_first_row(target_grid, extras) do |solution|
      # puts "Step #{num_priors} potential match:"
      prior = Grid.from_cells(target_grid.rows+extras*2, target_grid.cols+extras*2, solution)
      # puts prior
      result = find_dfs(prior, num_priors - 1, extras)
      unless result.nil?
        return result
        # puts "step #{num_priors}:"
        # puts prior
        # return true
      # else
        # puts "Popped back up to step #{num_priors}, continuing at that level"
      end
    end
    nil
    # puts "didn't find any priors!"
  end

  def find(target_grid, num_priors)
    if num_priors == 0
      # made it all the way to the end. return the grid we were passed.
      target_grid
    else
      # compute prior generations
      # this will include some solutions that go outside the boundaries of the target grid
      # in the case that there are no solutions that do keep the target boundaries, 
      # we'll have to select the narrowest one that actually works.

      expanded = false

      # search for the target grid. the ataviser will look one extra cell in each direction.
      prior_generations = @ataviser.prior_generations(target_grid, 0)
      
      # no priors means there were no solutions that fit within the bounds of the original target grid.
      # i don't really think this can happen.
      if prior_generations.empty?
        # puts "Couldn't find a prior generation. Going back up a level."
        return nil
        
        # puts "Found no prior generations within the bounds of original target grid. Expanding."
        # expanded = true
        # 
        # # expand search to include and extra border of 1. this will take a lot 
        # # longer, and we really prefer not to do it.
        # prior_generations = @ataviser.prior_generations(target_grid, 1)
        # 
        # if prior_generations.empty?
        #   raise "Crap, even with an additional border of 1, couldn't find a prior generation!"
        # end
      end
      
            # 
            # 
            # # first, find all the solutions that have an empty border
            # constrained_solutions = prior_generations.select{|prior| empty_border?(prior)}
            # 
            # if constrained_solutions.any?
        # excellent! let's use the first constrained solution and recurse
        # return [prior] + find(prior, num_priors-1)
      # end
      
      # hm, looks like we didn't find any constrained solutions.
      # let's move on to solutions that just work.
      prior_generations.each do |prior_generation|
        g = Grid.from_cells(target_grid.rows + (expanded ? 2 : 0), target_grid.cols + (expanded ? 2 : 0), prior_generation)
        result = find(g, num_priors-1)
        unless result.nil?
          return result
        end
      end
      return nil
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
  num_priors = ARGV.shift.to_i
  s = Search.new
  until ARGV.empty?
    s.find_predecessor_sequence(num_priors, ARGV.shift)
    print "."
  end
end