delta = (4000 - 200) / 24.0
bottom_gutter = (1000 - (4 * delta)) / 2

row = 0
col = 0
for i in 1..12
  for j in (i+1)..12
    for pair in [[i,j],[j,i]]
      puts "move l#{pair.first}_#{pair.last} (#{100 + col * delta} #{(4 * delta + bottom_gutter) - row * delta});"
      col+= 1
      if col == 25
        col = 0
        row += 1
      end
    end
  end
end