require "./grid.rb"

g = Grid.new(10, 10)

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
