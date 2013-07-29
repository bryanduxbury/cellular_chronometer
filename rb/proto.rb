require "./grid.rb"
require "./duparc_predecessor.rb"

def find_prior_gen(g, desired_depth, p)
  if (desired_depth == 0)
    puts g
    return true
  else
    priors = p.prior_generations(g)
    priors.each do |prior|
      if find_prior_gen(Grid.from_cells(g.rows, g.cols, prior), desired_depth - 1, p)
        puts g
        return true
      end
    end
    return false
  end
end

p = DuparcPredecessor.new()

g = Grid.new(7, 4)

goe =<<EOF
  X  
X X X
X X  
X  XX
  X  
 X  X
XXX X
EOF

# g.place(0,0, goe)
# puts g
# p.prior_generations(g)
# exit

# num2 =<<EOF
# XXX
#   X
# XXX
# X  
# XXX
# EOF

num2 =<<EOF
XX
 X
XX
X 
XX
EOF

g.place(1,1, num2)

# find_prior_gen(g, 10, p)

puts "starting with:"
puts g.to_s

lineage = [g]



10.times do
  puts "-------"
  priors = p.prior_generations(lineage.first)
  
  for prior in priors
    x = Grid.from_cells(7, 4, prior)
    ng = x.next_generation
    if ng != lineage.first
      puts "Uh oh, found a prior that doesn't round-trip."
      puts x
      puts "yields"
      puts ng
    end
  end
  
  if priors.empty?
    puts "OMG! Found a garden of eden!"
    puts lineage.first
    exit
  end
  lineage.unshift(Grid.from_cells(7, 4, priors.sort_by{|pg| pg.size}.first))
end

lineage.each do |grid|
  puts grid
end

# a = g.find_first_ancestor(2)
# until a == g
#   puts a.to_s
#   a = a.next_generation
# end
