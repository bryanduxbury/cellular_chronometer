require "./grid.rb"
require "./patterns.rb"

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

      da = target.cells.keys - g.cells.keys
      db = g.cells.keys - target.cells.keys
      @fitness = [- 1 * (da.size + db.size), -1 * @cells.size]
    end
  end
  
  def ==(other)
    other.cells.sort == cells.sort
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
    ex, ey = determine_extents(target_pattern)
    target_grid = Grid.new(ey, ex)
    target_grid.place(0, 0, target_pattern)
    puts target_pattern
    puts target_grid.to_s

    # generate init pop
    pop = []
    @pop_size.times do
      phenotype = []
      for x in 0..ex
        for y in 0..ey
          # 1/10 chance of each cell being alive. (trying to start from sparse options)
          phenotype << [x,y] if rand(10) == 1
        end
      end
      pop << Phenotype.new(phenotype)
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
        phenotype = []
        for x in 0..ex
          for y in 0..ey
            # coin flip to see if this cell will be alive
            phenotype << [x,y] if rand(2) == 1
          end
        end
        new_population << Phenotype.new(phenotype)
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

      # @num_life_generations.times do
      #   g = g.next_generation
      # end
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
    puts hist.map { |fit, count| [fit, "#" * count] }.sort_by{|pair| pair[0]}.map{ |pair| pair.first.to_s + "=>" + pair.last }.join("\n")
  end

  def mutate(pheno, ex, ey)
    new_cells = pheno.cells.dup
    if rand() < @chance_of_mutation
      mx, my = rand(ex), rand(ey)
      if new_cells.include?([mx,my])
        new_cells.delete([mx,my])
      else
        new_cells << [mx,my]
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

  def fitness(individual, target)
    g = Grid.new(target.rows, target.cols, individual.inject({}) {|hsh, cell| hsh[cell] = true; hsh})
    @num_life_generations.times do
      g = g.next_generation
    end

    da = target.cells.keys - g.cells.keys
    db = g.cells.keys - target.cells.keys
    return - 1 * (da.size + db.size)
  end
end

if $0 == __FILE__
  Trainer.new(*ARGV[0..4]).train(File.read(ARGV[5]))
end