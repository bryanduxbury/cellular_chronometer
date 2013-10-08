require "./grid.rb"

class IntersectingRowAtaviser
  def initialize(solution_filter = nil)
    @solution_filter = solution_filter || proc {true}
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

  def atavise(row_width, living_cols)
    # RubyProf.pause
    ret = @cache[[row_width, living_cols]]

    unless ret
      seeds = living_cols.include?(1) ? @ends_up_living.dup : @ends_up_dead.dup
      # puts "number of seeds: #{seeds.size}"
      # puts "number of unique seeds: #{seeds.uniq.size}"
      
      if row_width > 3
        (2...(row_width-1)).each do |idx|
          # puts "working on col #{idx}"
          grouped_seeds = seeds.uniq.group_by{|seed| seed[-2..-1]}
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
              new_seed = (matched_seed + [prior[2]])
              # puts
              # puts new_seed.join("\n")
              # puts
              # puts Grid.from_cells(3, row_width + 2, new_seed)

              new_seeds << new_seed
            end
          end
          # puts "new seeds size: #{new_seeds.size}"
          # puts "new seeds unique size: #{new_seeds.uniq.size}"

          seeds = new_seeds
        end
      end

      # puts "seeds size: #{seeds.size}"

      ret = seeds.map { |seed| IntersectingRowAtaviser.cols_to_rows(seed, row_width) }.select{|result| @solution_filter.call(result)}
      # puts "after filter: #{ret.size}"
      # puts "uniq: #{ret.uniq.size}"
      @cache[[row_width, living_cols]] = ret
    end
    # RubyProf.resume
    ret
  end

  private

  def self.cols_to_rows(bvs_by_col, num_cols)
    # always 3 rows, since we're row atavising
    # puts "input: " + bvs_by_col.inspect
    bvs_by_row = [0,0,0]
    (0...num_cols).each do |col_idx|
      bvs_by_row[0] = (bvs_by_row[0] | (((bvs_by_col[col_idx] & 1)) << col_idx))
      bvs_by_row[1] = (bvs_by_row[1] | (((bvs_by_col[col_idx] & 2)) << (col_idx - 1)))
      bvs_by_row[2] = (bvs_by_row[2] | (((bvs_by_col[col_idx] & 4)) << (col_idx - 2)))
    end
    # puts "output: " + bvs_by_row.inspect
    bvs_by_row
  end

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