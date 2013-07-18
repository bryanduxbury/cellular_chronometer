require "./grid.rb"

g = Grid.new(10, 10)


# the "toad"
# g.set(4, 4, true)
# g.set(5, 4, true)
# g.set(6, 4, true)
# g.set(5, 5, true)
# g.set(6, 5, true)
# g.set(7, 5, true)

# the "glider"
# g.set(1, 0)
# g.set(2, 1)
# g.set(0, 2)
# g.set(1, 2)
# g.set(2, 2)
# g = g.next_generation

num2 =<<EOF
XXX
  X
XXX
X  
XXX
EOF

g.place(3,3, num2)
g.prior_generations_3


puts "starting with:"
puts g.to_s

a = g.find_first_ancestor(2)
until a == g
  puts a.to_s
  a = a.next_generation
end

# lwss =<<-EOF
#  xxxx
# x   x
#     x
# x  x
# EOF
# puts lwss

# 10.times do |x|
#   puts "Starting generation -#{x+1}"
#   puts "Starting state:"
#   puts g.to_s
#   p = g.prior_generations
#   puts "Found #{p.size} prior generations:"
#   puts p.map(&:to_s).join("\n")
#   
#   g = Grid.new(10, 10, p.sort_by(&:size).first)
# end

# # puts Grid.live_neighbors(g, 5, 5)
# 
# while gets
#   g = g.next_generation
#   puts g.to_s
# end