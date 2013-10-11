class HierarchicalDuparcAtaviser
  def initialize(row_ataviser)
    @row_ataviser = row_ataviser
    @cache = {}
  end
  
  def prior_generations(grid, selector=:any)
    by_rows = grid.by_row.map { |row| row.map { |pt| pt.translate(1, 0).x } }

    prior_bvs = atavise(by_rows, grid.cols, selector, 0)
    # puts "done atavising, just wrapping things up now"
    
    # if extras == 0
    #   prior_bvs.select! {|prior| prior.first == 0 && prior.last == 0}
    #   prior_bvs.map! { |prior| prior[1..-1] }
    # end
    
    # puts "ended up with #{prior_bvs.size} final solutions"
    
    @cache = {}
    ret = prior_bvs.map { |bv| Pt.bv_rows_to_pts(bv) }
    ret
  end
  
  def atavise(rows, numcols, selector, depth=nil)
    if @cache[rows]
      # puts "cache hit at depth #{depth}!"
      return @cache[rows]
    end
    # puts "input rows #{rows.inspect}"
    if rows.size == 1
      @row_ataviser.atavise(numcols+2, rows.first)
    else
      top_rows = rows[0...rows.size/2]
      # puts "top rows: #{top_rows.inspect}"
      bottom_rows = rows[rows.size/2..-1]
      # puts "bottom rows #{bottom_rows.inspect}"
      top_priors = atavise(top_rows, numcols, selector, depth+1)
      bottom_priors = atavise(bottom_rows, numcols, selector, depth+1)

      # puts "top priors: #{top_priors.size} bottom_priors: #{bottom_priors.size}"
      # puts "top uniq priors: #{top_priors.uniq.size} bottom_priors: #{bottom_priors.uniq.size}"

      co_matches = []
      # puts "parts for depth #{depth}:"
      grouped_tops = top_priors.group_by{|prior| prior[-2..-1]}
      # puts "#{"\t" * depth}top: #{top_priors.size} / #{grouped_tops.keys.size}"
      grouped_bottoms = bottom_priors.group_by{|prior| prior[0..1]}
      # puts "#{"\t" * depth}bottom: #{bottom_priors.size} / #{grouped_bottoms.keys.size}"
      overlapping_keys = (grouped_tops.keys & grouped_bottoms.keys)
      # puts "#{"\t" * depth}#{overlapping_keys.size}"

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
            break if co_matches.size == 100000
          end
          break if co_matches.size == 100000
        end
        if co_matches.size == 100000
          # print "!"
          break
        end
      end
      if co_matches.size > 1000000
        puts "Trimming intermediate results from #{co_matches.size} to 1000000!"
        co_matches = co_matches[0...1000000]
      end

      @cache[rows] = co_matches

      co_matches
    end
  end
end