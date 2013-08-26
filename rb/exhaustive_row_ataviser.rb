require "./grid.rb"

class ExhaustiveRowAtaviser
  def initialize
    @cache = {}
  end
  
  def atavise(row_width, extra_row_width, living_cols)
    ret = @cache[living_cols]

    unless ret
      row_neighbors = (0...(row_width+extra_row_width*2)).to_a.product((0..2).to_a).map{|xy| Pt.new(xy.first, xy.last)}

      puts "need to calculate priors for row archetype #{living_cols.inspect}"
      total = 2**row_neighbors.size
      count = 0

      ret = []

      extra_cells = (0...extra_row_width).to_a + (0...extra_row_width).map { |x| row_width+extra_row_width*2 - 1 - x }

      for_each_combination(row_neighbors) do |live_neighbors|
        count += 1
        print "\r#{(count.to_f / total * 100).to_i}% complete"

        tg = Grid.new(3, row_width + extra_row_width*2)
        live_neighbors.each do |xy|
          tg.set(xy.x, xy.y)
        end

        ng = tg.next_generation

        # puts tg
        # puts ng
        # puts (ng.by_row[1].map(&:x) - extra_cells).inspect
        # puts living_cols.inspect
        if (ng.by_row[1].map(&:x) - extra_cells).sort == living_cols
          # puts "matches"
          ret << live_neighbors
        end
        
      end
      puts
      
      ret = ret.map { |pts| Pt.pts_to_bv_rows(pts, 3) }
      @cache[living_cols] = ret
    end

    ret
  end
  
  private
  
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
  a = ExhaustiveRowAtaviser.new
  
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