require "./grid.rb"
require "./duparc_ataviser.rb"
require "./hierarchical_duparc_ataviser.rb"
require "./exhaustive_row_ataviser.rb"
require "./intersecting_row_ataviser.rb"

class Search
  def initialize
    # @ataviser = DuparcAtaviser.new(IntersectingRowAtaviser.new)
    dead_edge_filter = proc {|solution| solution.select{|row| (row & 0x41) != 0}.empty? }
    tubular_edge_filter = proc do |solution|
      ret = true
      solution.each do |row|
        if (row & 0x01) != ((row >> 5) & 0x01) || ((row >> 1) & 0x01) != ((row >> 6) & 0x01)
          ret = false
          break
        end
      end
      ret
    end
    # filter = nil
    @ataviser = HierarchicalDuparcAtaviser.new(IntersectingRowAtaviser.new(tubular_edge_filter))
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
      # $stderr.puts "No priors found!"
      false
    else
      File.open(target_pattern_file + "__back_#{num_priors}", "w+") do |file|
        if transposed
          result = Grid.from_cells(result.cols, result.rows, result.by_row.flatten.map(&:flip))
        end

        file.puts result.to_bitvector.inspect
        file.puts target_grid.to_bitvector.inspect
        file.puts result

        puts "------------"

        g = result
        puts g
        (num_priors + 2).times do
          n = g.make_toroidal
          puts "toroided --------"
          puts n
          n = n.next_generation
          puts "next ------------"
          puts n
          n = n.subgrid(1,1,result.cols,result.rows)
          puts "trimmed ---------"
          puts n
          g = n
        end

      end
      true
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
      # search for the target grid. the ataviser will look one extra cell in each direction.
      prior_generations = @ataviser.prior_generations(target_grid)

      puts "#{num_priors} -> #{prior_generations.size}"
      
      # no priors means there were no solutions that fit within the bounds of the original target grid.
      # i don't really think this can happen.
      if prior_generations.empty?
        # puts "Couldn't find a prior generation. Going back up a level."
        return nil
      end

      # f = File.new("priors_dump_rb.txt", "w")
      # prior_generations.each do |prior_generation|
      #   g = Grid.from_cells(target_grid.rows + 2, target_grid.cols + 2, prior_generation)
      #   f.puts g.to_row_vectors.inspect
      # end
      # f.close

      # puts "found #{prior_generations.size} prior generations"
      # non_toroidal_count = 0
      prior_generations.each do |prior_generation|
        g = Grid.from_cells(target_grid.rows + 2, target_grid.cols + 2, prior_generation)
        toroidal = true
        for lr in [[0, g.rows-2], [1, g.rows-1]]
          (0...target_grid.cols).each do |col_idx|
            unless g.get(col_idx, lr.first) == g.get(col_idx, lr.last)
              toroidal = false
            end
          end
        end
        unless toroidal
          # non_toroidal_count += 1
          # print "\rskipping non-toroidal (count: #{non_toroidal_count}/#{prior_generations.size})"
          next
        end
        g = g.subgrid(1, 1, g.cols-2, g.rows-2)
        # next unless empty_border?(g)
        result = find(g, num_priors-1)
        if result.nil?
          # puts "\ncouldn't find a prior for this solution at depth #{num_priors}"
        else
          # puts g
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


# if $0 == __FILE__

require "rubygems"
require "ruby-prof"
# RubyProf.start

  num_priors = ARGV.shift.to_i
  s = Search.new
  until ARGV.empty?
    if s.find_predecessor_sequence(num_priors, ARGV.shift)
      print "+"
    else
      print "-"
    end
  end
# result = RubyProf.stop
# printer = RubyProf::GraphHtmlPrinter.new(result)
# out = File.new("profile2.html", "w")
# printer.print(out)
# end