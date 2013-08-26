row = 0
col = 0
for i in 1..12
  for j in (i+1)..12
    puts "l#{i}_#{j}"
    col+= 1
    if col == 25
      col = 0
      row += 1
    end
    puts "l#{j}_#{i}"
    col+= 1
    if col == 25
      col = 0
      row += 1
    end
  end
end