require "./grid.rb"
# require "./duparc_ataviser.rb"


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
        @ends_up_living << pts
      else
        @ends_up_dead << pts
      end
    end

    # puts "number of priors for living cell: #{@ends_up_living.size}"
    # puts "number of priors for dead cell: #{@ends_up_dead.size}"
  end

  def atavise(row_width, extra_row_width, living_cols)
    ret = @cache[[row_width, extra_row_width, living_cols]]

    unless ret
      seeds = (living_cols.include?(extra_row_width) ? @ends_up_living.dup : @ends_up_dead.dup).map { |seed| by_col(3, 3, seed)}

      puts "number of seeds: #{seeds.size}"

      ((extra_row_width + 1)...(row_width+extra_row_width)).each do |idx|
        # puts "working on col #{idx}"
        grouped_seeds = seeds.group_by{|seed| seed[-2..-1]}
        # puts grouped_seeds.keys.sort.inspect
        cur_priors = (living_cols.include?(idx) ? @ends_up_living.dup : @ends_up_dead.dup).map { |seed| by_col(3, 3, seed)}

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

        seeds = new_seeds
        puts "new seeds size: #{seeds.size}"
      end

      if extra_row_width==0
        seeds = seeds.map{|seed| seed[1..-2]}
      end

      ret = seeds.map { |seed| to_pt_list(seed) }
      @cache[[row_width, extra_row_width, living_cols]] = ret
    end
    ret
  end

  private

  def by_col(numcols, numrows, pts)
    cols = []
    (0...numcols).each do |col|
      colstr = ""
      (0...numrows).each do |row|
        if pts.select{|pt| pt == Pt.new(col, row)}.size == 0
          colstr << "0"
        else
          colstr << "1"
        end
      end
      cols << colstr
    end
    cols
  end

  def to_pt_list(cols)
    # puts cols.join("\n")
    # puts
    pts = []
    (0...cols.size).each do |x|
      col = cols[x]
      (0...col.size).each do |y|
        if col[y] == "1"
          pts << Pt.new(x, y)
        end
      end
    end
    pts
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