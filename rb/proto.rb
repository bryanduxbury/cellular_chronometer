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
g.set(1, 0)
g.set(2, 1)
g.set(0, 2)
g.set(1, 2)
g.set(2, 2)
g = g.next_generation

# lwss =<<-EOF
#  xxxx
# x   x
#     x
# x  x
# EOF
# puts lwss

puts g.to_s
puts g.prior_generations

# # puts Grid.live_neighbors(g, 5, 5)
# 
# while gets
#   g = g.next_generation
#   puts g.to_s
# end