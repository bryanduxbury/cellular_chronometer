require "./grid.rb"
require "./patterns.rb"

class TargetGrid
  attr_accessor :cols, :rows, :living_cells, :dead_cells

  def initialize(cols, rows, living_cells, dead_cells)
    @cols = cols
    @rows = rows
    @living_cells = living_cells
    @dead_cells = dead_cells
  end

  def to_s
    "living: #{@living_cells} dead: #{@dead_cells}"
  end

  class << self
    def parse(str)
      living_cells = []
      dead_cells = []

      rows = str.split("\n")
      rownum = 0
      rows.each do |row|
        colnum = 0
        row.split("").each do |char|
          case char
            when "X"
              living_cells << Pt.new(colnum, rownum)

            when " "
              dead_cells << Pt.new(colnum, rownum)
          end
          colnum += 1
        end
        rownum += 1
      end

      TargetGrid.new(rows.map { |row| row.size }.max, rows.size, living_cells, dead_cells)
    end
  end
end

class Phenotype
  attr_accessor :cells
  attr_accessor :fitness

  def initialize(cells)
    @cells = cells.sort
  end

  def score(target, num_life_generations)
    if fitness == nil
      g = Grid.new(target.rows, target.cols, @cells.inject({}) {|hsh, cell| hsh[cell] = true; hsh})
      num_life_generations.times do
        g = g.next_generation
      end

      missing_living_cells = target.living_cells - g.cells.keys
      cells_that_should_be_dead = target.dead_cells & g.cells.keys
      # extraneous_cells = target.dead_cells.keys g.cells.keys - 
      @fitness = [-1 * missing_living_cells.size, -1 * cells_that_should_be_dead.size, -1 * @cells.size]
    end
  end
  
  def ==(other)
    other.cells.sort == cells.sort
  end
  
  class << self
    def random(ex, ey, num_init_cells)
      cells = {}
      until cells.size == num_init_cells
        pt = Pt.new(rand(ex), rand(ey))
        cells[pt] = true unless cells[pt]
      end

      Phenotype.new(cells.keys)
    end
  end
end

class Trainer
  def initialize(pop_size, chance_of_mutation, num_generations, rand_seed, num_life_generations)
    @pop_size = pop_size.to_i
    @chance_of_mutation = chance_of_mutation.to_f
    @num_generations = num_generations.to_i
    srand(rand_seed.to_i)
    @num_life_generations = num_life_generations.to_i
  end

  def train(target_pattern)
    
    # target_grid = Grid.new(ey, ex)
    # target_grid.place(0, 0, target_pattern)
    puts target_pattern
    target_grid = TargetGrid.parse(target_pattern)
    puts target_grid.to_s

    ex, ey = target_grid.cols, target_grid.rows

    # generate init pop
    pop = []
    @pop_size.times do
      # pop << Phenotype.random(ex, ey, ex * ey / 10 )
      pop << Phenotype.random(ex, ey, target_grid.living_cells.size/2)
    end

    # puts "init pop:"
    # puts pop.inspect

    @num_generations.times do |gen_num|
      puts "Starting generation #{gen_num}"

      # evalutate fitness of all pop members
      threads = []
      pop.each do |pheno|
        threads << Thread.new do
          pheno.score(target_grid, @num_life_generations)
        end
      end

      threads.each do |thread|
        thread.join
      end
      
      ranked_pop = pop.sort_by{|pheno| pheno.fitness}
      # puts ranked_pop.map { |pair| pair[0] }.inspect
      print_histogram(ranked_pop)

      new_population = []

      # bottom quarter dies

      # top half lives on and also mates
      top_half = ranked_pop[pop.size/2..-1]
      until top_half.empty?
        mom = top_half.delete_at(rand(top_half.size))
        dad = top_half.delete_at(rand(top_half.size))
        new_population << mom << dad << mate(mom, dad)
      end

      # second quarter carries on with some chance of mutation
      second_quarter = ranked_pop[0...pop.size/2][pop.size/4..-1]
      for pheno in second_quarter
        new_population << mutate(pheno, ex, ey)
      end

      uniq_pop = new_population.inject({}) {|hsh, pheno| hsh[pheno.cells] = pheno; hsh}.values
      puts "uniq_pop_size: #{uniq_pop.size}"
      if uniq_pop.size != new_population.size
        puts "deleted #{new_population.size - uniq_pop.size} non-unique solutions"
      end
      new_population = uniq_pop
      while new_population.size < @pop_size
        # new_population << Phenotype.random(ex, ey, ex * ey / 10 )
        new_population << Phenotype.random(ex, ey, target_grid.living_cells.size/2)
      end

      pop = new_population
    end
    
    ranked_pop = pop.sort_by{|pheno| pheno.score(target_grid, @num_life_generations); pheno.fitness}
    print_histogram(ranked_pop)
    
    best_rank = ranked_pop.map { |pheno| pheno.fitness }.max
    best_ranked = ranked_pop.select { |pheno| pheno.fitness == best_rank }.uniq
    best_ranked.each do |pheno|
      puts pheno.cells.inspect
      g = Grid.new(ey, ex, pheno.cells.inject({}) {|hsh, cell| hsh[cell] = true; hsh})
      puts g.to_s
    end
  end

  private

  def print_histogram(ranked_pop)
    hist = {}
    for ranked_pheno in ranked_pop
      c = hist[ranked_pheno.fitness]
      c ||= 0
      c += 1
      hist[ranked_pheno.fitness] = c
    end
    puts hist.map { |fit, count| [fit, "#" * count] }.sort_by{|pair| pair[0]}.map{ |pair| pair.first.inspect + " => " + pair.last }.join("\n")
  end

  def mutate(pheno, ex, ey)
    new_cells = pheno.cells.dup
    if rand() < @chance_of_mutation
      pt = Pt.new(rand(ex), rand(ey))
      if new_cells.include?(pt)
        new_cells.delete(pt)
      else
        new_cells << pt
      end
    end
    Phenotype.new(new_cells)
  end

  def mate(m, d)
    # kid gets the full intersection of mom and dad's cells
    kid = m.cells & d.cells

    mom_only = m.cells - d.cells
    dad_only = d.cells - m.cells

    # trade off between mom and dad's unique cells
    until mom_only.empty? || dad_only.empty?
      a = mom_only.pop
      b = dad_only.pop
      kid << (rand(2) == 1 ? a : b)
    end
    
    # mom or dad will probably have cells left. give the kid a 50% shot at each one.
    for cell in (mom_only + dad_only)
      kid << cell if rand(2) == 1
    end
    Phenotype.new(kid)
  end

  def determine_extents(pattern)
    rows = pattern.split("\n")
    [rows.map { |row| row.size }.max, rows.size]
  end
end

if $0 == __FILE__
  Trainer.new(*ARGV[0..4]).train(File.read(ARGV[5]))
end