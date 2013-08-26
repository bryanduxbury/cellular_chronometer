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

# g = Grid.new(5, 3)
# 
# pat =<<EOF
#  XX
# X  
#    
# X X
#  X 
# EOF
# 
# g.place(0,0, pat)
# puts pat
# puts g.next_generation
# exit

g = Grid.new(7, 3)

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

# num2 =<<EOF
# X
#  
# X
# X
# X
# EOF

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



g.place(1, 1, num2)

# puts g

# duparc_priors = p.prior_generations(g)

# exhaustive_priors = []
# count = 0
# for_each_combination((0..2).to_a.product((0..6).to_a)) do |combo|
#   count += 1
#   puts count if count % 10000 == 0
# 
#   # puts combo.inspect
#   pred = Grid.from_cells(7, 3, combo.map{|xy| Pt.new(xy.first, xy.last)})
# 
#   if pred.next_generation == g
#     puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
#     puts combo.inspect
#     puts pred
#     puts pred.next_generation
#     puts g
#     exhaustive_priors << pred.next_generation
#   end
# end
# puts exhaustive_priors.size
# 
# puts exhaustive_priors.group_by{|prior| prior.to_s}.size

# exhaustive_priors.each do |pred|
#   puts pred
# end


# puts duparc_priors.size
# exit
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
  ng = Grid.from_cells(7, 4, priors.sort_by{|pg| pg.size}.first)
  puts "Selected"
  puts ng
  lineage.unshift(ng)
end

lineage.each do |grid|
  puts grid
end

# a = g.find_first_ancestor(2)
# until a == g
#   puts a.to_s
#   a = a.next_generation
# end
