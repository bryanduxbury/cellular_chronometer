class HierarchicalDuparcAtaviser
  def initialize(row_ataviser)
    @row_ataviser = row_ataviser
    @cache = {}
  end
  
  def prior_generations(grid, selector=:any)
    by_rows = grid.by_row.map { |row| row.map { |pt| pt.translate(1, 0).x } }

    prior_bvs = atavise(by_rows, grid.cols, selector)
    # puts "done atavising, just wrapping things up now"
    
    # if extras == 0
    #   prior_bvs.select! {|prior| prior.first == 0 && prior.last == 0}
    #   prior_bvs.map! { |prior| prior[1..-1] }
    # end
    
    # puts "ended up with #{prior_bvs.size} final solutions"
    
    prior_bvs.map { |bv| Pt.bv_rows_to_pts(bv) }
  end
  
  def atavise(rows, numcols, selector)
    if @cache[rows]
      return @cache[rows]
    end
    # puts "input rows #{rows.inspect}"
    if rows.size == 1
      @row_ataviser.atavise(numcols, rows.first)
    else
      top_rows = rows[0...rows.size/2]
      # puts "top rows: #{top_rows.inspect}"
      bottom_rows = rows[rows.size/2..-1]
      # puts "bottom rows #{bottom_rows.inspect}"
      top_priors = atavise(top_rows, numcols, selector)
      bottom_priors = atavise(bottom_rows, numcols, selector)

      # puts "top priors: #{top_priors.size} bottom_priors: #{bottom_priors.size}"
      # puts "top uniq priors: #{top_priors.uniq.size} bottom_priors: #{bottom_priors.uniq.size}"

      co_matches = []

      grouped_tops = top_priors.group_by{|prior| prior[-2..-1]}
      grouped_bottoms = bottom_priors.group_by{|prior| prior[0..1]}
      
      overlapping_keys = (grouped_tops.keys & grouped_bottoms.keys)
      # puts "#{overlapping_keys.size} unique matching zones"

      overlapping_keys.each do |overlap|
        tops = grouped_tops[overlap]
        bottoms = grouped_bottoms[overlap]
        
        a = tops.group_by{|prior| prior[0..1]}
        b = bottoms.group_by{|prior| prior[-2..-1]}
        
        a.keys.each do |top|
          top_first = a[top].first
          b.keys.each do |bottom|
            bottom_first = b[bottom].first
            co_matches << (top_first + bottom_first[2..-1])
          end
        end
      end
      
      co_matches = co_matches[0...10000000]
      
      # if selector == :any
      #   culled_grouped_tops = {}
      #   grouped_tops.keys.each do |key|
      #     solutions = grouped_tops[key]
      #     culled_grouped_tops[key] = solutions.group_by{|solution| solution[0..1]}.values.map { |group| group.first }
      #   end
      #   num_culled_solutions = culled_grouped_tops.values.map(&:size).inject(0){|cnt, sum| sum + cnt}
      #   puts "In :any mode, top priors culled down to #{num_culled_solutions}/#{top_priors.size}"
      #   grouped_tops = culled_grouped_tops
      #   
      #   culled_grouped_bottoms = {}
      #   bottom_priors.group_by{|prior| prior[0..1]}.each do |key, solutions|
      #     # solutions = grouped_tops[key]
      #     culled_grouped_bottoms[key] = solutions.group_by{|solution| solution[-2..-1]}.values.map { |group| group.first }
      #   end
      #   num_culled_solutions = culled_grouped_bottoms.values.map(&:size).inject(0){|cnt, sum| sum + cnt}
      #   puts "In :any mode, bottom priors culled down to #{num_culled_solutions}/#{bottom_priors.size}"
      #   bottom_priors = culled_grouped_bottoms.values.inject([]) {|list, group| group.each {|x| list << x}; list}
      # end
      
      # puts "unique overlap sections from top half: #{grouped_tops.keys.size}"
      top_priors = nil

      # bottom_priors.each do |bottom_prior|
      #         overlap = bottom_prior[0..1]
      #         matching_tops = grouped_tops[overlap]
      # 
      #         by_top_and_bottom = {}
      # 
      #         if matching_tops
      #           # puts "unique opposite side overlaps: #{matching_tops.group_by{|x| x[0..1]}.keys.size}/#{matching_tops.size}"
      # 
      #           matching_tops.each do |matching_top|
      #             # if selector == :any
      #             #   key = matching_top[0..1] + bottom_prior[-2..-1]
      #             #   if by_top_and_bottom[key].nil?
      #             #     co_matches << (matching_top + bottom_prior[2..-1])
      #             #     by_top_and_bottom[matching_top[0..1] + bottom_prior[-2..-1]] = true
      #             #   end
      #             # else
      #               co_matches << (matching_top + bottom_prior[2..-1])
      #             # end
      #             
      #           end
      #         end
      #         # break if co_matches.size > 7500000
      #       end

      # puts "top+bottom matches: #{co_matches.size}"
      
      # if selector == :any
      #   uniques = {}
      #   co_matches.each do |match|
      #     uniques[match[0..1] + match[-2..-1]] = match
      #   end
      #   co_matches = uniques.values
      #   # co_matches = co_matches.group_by{|match| match[0..1] + match[-2..-1]}.values.map { |group| group.first }
      #   puts "top+bottom culled matches: #{co_matches.size}"
      # end
      
      @cache[rows] = co_matches

      co_matches
    end
  end
end