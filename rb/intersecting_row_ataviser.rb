require "./grid.rb"

class IntersectingRowAtaviser
  def initialize
    @cache = {}
    
    neighbors = (0..2).to_a.product((0..2).to_a)# - [[1,1]]

    # prior generations where the center cell ends up alive
    @ends_up_living = []
    @ends_up_dead = []
    for_each_combination(neighbors) do |combo|
      pts = combo.map{|xy| Pt.new(xy.first, xy.last)}
      prior = Grid.from_cells(3, 3, pts)
      if prior.next_generation.get(1,1)
        @ends_up_living << by_col(pts, 3)
      else
        @ends_up_dead << by_col(pts, 3)
      end
    end

    @ends_up_living.uniq!
    @ends_up_dead.uniq!

    # puts "number of priors for living cell: #{@ends_up_living.size}"
    # puts "number of priors for dead cell: #{@ends_up_dead.size}"
  end

  def atavise(row_width, extra_row_width, living_cols)
    ret = @cache[[row_width, extra_row_width, living_cols]]

    unless ret
      seeds = living_cols.include?(extra_row_width) ? @ends_up_living.dup : @ends_up_dead.dup

      # puts "number of seeds: #{seeds.size}"
      # puts "number of unique seeds: #{seeds.uniq.size}"

      ((extra_row_width + 1)...(row_width+extra_row_width)).each do |idx|
        # puts "working on col #{idx}"
        grouped_seeds = seeds.group_by{|seed| seed[-2..-1]}
        # puts grouped_seeds.keys.sort.inspect
        cur_priors = living_cols.include?(idx) ? @ends_up_living.dup : @ends_up_dead.dup
        # puts "cur priors size:#{cur_priors.size}"
        # puts "cur priors unique size: #{cur_priors.uniq.size}"
        new_seeds = []

        cur_priors.each do |prior|
          prior_left_two_columns = prior[0..1]
          # puts "left two columns:"
          # puts prior_left_two_columns.inspect
          (grouped_seeds[prior_left_two_columns] || []).each do |matched_seed|
            # puts matched_seed.join("\n")
            new_seed = (matched_seed.dup << prior[2])
            # puts
            # puts new_seed.join("\n")
            # puts
            # puts Grid.from_cells(3, row_width + extra_row_width*2, new_seed)

            new_seeds << new_seed
          end
        end

        # puts "new seeds size: #{new_seeds.size}"
        # puts "new seeds unique size: #{new_seeds.uniq.size}"

        seeds = new_seeds
      end

      if extra_row_width==0
        # #the uniq is necessary because 
        # seeds = seeds.map{|seed| seed[1..-2]}.uniq
        seeds = seeds.select{|seed| seed.first == 0 && seed.last == 0}.map{|seed| seed[1..-2]}
      end

      # puts "seeds size: #{seeds.size}"
      # puts "seeds unique size: #{seeds.uniq.size}"


      ret = seeds.map { |seed| Pt.pts_to_bv_rows(from_cols(seed), 3) }
      @cache[[row_width, extra_row_width, living_cols]] = ret
    end
    ret
  end

  private

  def by_col(pts, numcols)
    Pt.pts_to_bv_rows(pts.map { |pt| pt.flip }, numcols)
  end

  def from_cols(cols)
    Pt.bv_rows_to_pts(cols).map(&:flip)
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
  a = IntersectingRowAtaviser.new
  
  srand(1)
  width = 5
  100.times do
    living_cols = []
    until living_cols.size == 3
      col = rand(width)
      living_cols << col unless living_cols.include?(col)
    end
    puts living_cols.inspect
    a.atavise(5, 1, living_cols)
  end
  
end