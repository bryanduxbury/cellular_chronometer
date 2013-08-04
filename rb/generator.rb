require "./grid.rb"

class Generator
  def initialize(font_dir)
    @glyphs = {"" => []}
    ("0".."9").each do |glyph|
      pattern = File.read(font_dir + glyph.to_s + ".txt")

      living_cells = []

      rows = pattern.split("\n")
      rownum = 0
      rows.each do |row|
        colnum = 0
        row.split("").each do |char|
          if char != " "
            living_cells << Pt.new(colnum, rownum)
          end
          colnum += 1
        end
        rownum += 1
      end
      @glyphs[glyph] = living_cells
    end
    puts @glyphs.inspect
    @gh = @glyphs.values.map { |pts| pts.map { |pt| pt.y }.max }.compact.max + 1
    @gw = @glyphs.values.map { |pts| pts.map { |pt| pt.x }.max }.compact.max + 1
  end
  
  def generate(glyph_spacing, output_dir)
    total_width = 1 + @gw + glyph_spacing + @gw + 3 + @gw + glyph_spacing + @gw + 1
    puts total_width
    puts @gh
    (("01".."09").to_a+("10".."12").to_a).each do |hours|
      ("00".."59").each do |minutes|
        puts "#{hours} : #{minutes}"
        
        cells = []
        cells = cells + (@glyphs[minutes[1..-1]].map { |cell| cell.translate(total_width - 1 - @gw, 0) })
        cells = cells + (@glyphs[minutes[0...1]].map { |cell| cell.translate(total_width - 1 - @gw - glyph_spacing - @gw, 0) })
        cells = cells + [Pt.new(total_width - 1 - @gw - glyph_spacing - @gw - 2, @gh/2-1)]
        cells = cells + [Pt.new(total_width - 1 - @gw - glyph_spacing - @gw - 2, @gh/2-1 + 2)]
        cells = cells + (@glyphs[hours.to_s[1..2]].map { |cell| cell.translate(total_width - 1 - @gw - glyph_spacing - @gw - 3 - @gw, 0) })
        cells = cells + (@glyphs[hours.to_s[0...1] == "1" ? "1" : ""].map { |cell| cell.translate(1, 0) })
        output_grid = Grid.from_cells(@gh, total_width, cells)
        puts output_grid.to_s(false)
        
        File.open(output_dir + "/" + "#{hours}_#{minutes}.txt", "w") do |file|
          file.print(output_grid.to_s(false))
        end
      end
    end
  end
end

if $0 == __FILE__
  Generator.new(ARGV.shift).generate(ARGV.shift.to_i, ARGV.shift)
end