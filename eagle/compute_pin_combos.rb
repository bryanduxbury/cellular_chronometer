# a + b <= 20
# 
# a * (a - 1) + b * (b - 1) >= 125

for a in 0..23
  for b in 0..23
    for c in 0..23
      # puts "#{a} #{b} #{c} #{a + b + c}"
      # puts [a,b,c].inspect
      # raise "found it" if [a,b,c] == [7,7,7]
      if (a + b + c) <= 23
        # puts "passable"
        d = (a * (a - 1) + b * (b - 1) + c * (c - 1))
        # puts d
        if d >= 125 && d <= 150
          # a, b, c = *([a, b, c].sort)
          # puts "#{d} #{a} #{b} #{c}"
          puts "#{d} #{[a,b,c].sort.join(",")}"
        end
      end
    end
  end
end