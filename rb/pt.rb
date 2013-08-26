class Pt
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def to_s
    "(#{x},#{y})"
  end

  def eql?(other)
    self == other
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def <=>(other)
    if x == other.x
      y <=> other.y
    else
      x <=> other.x
    end
  end

  def hash
    [x, y].hash
  end

  def translate(dx,dy)
    Pt.new(x+dx,y+dy)
  end
  
  def flip
    Pt.new(y, x)
  end

  def self.pts_to_bv_rows(pts, num_rows)
    bvs = [0] * num_rows
    pts.each do |pt|
      bvs[pt.y] |= (1 << pt.x)
    end
    bvs
  end
  
  def self.bv_rows_to_pts(bv_rows)
    pts = []
    rownum = 0
    bv_rows.each do |bv|
      colnum = 0
      until bv == 0
        if bv & 1 == 1
          pts << Pt.get(colnum, rownum)
        end
        bv = bv >> 1
        colnum += 1
      end
      rownum += 1
    end

    pts
  end

  def self.get(x,y)
    @cache = (0..500).map {[]} unless @cache

    pt = nil
    col = @cache[x]
    # unless col.nil?
      pt = col[y]
      if pt.nil?
        pt = Pt.new(x,y)
        @cache[x][y] = pt
      end
    # else
    #   pt = Pt.new(x,y)
    #   @cache[x] = []
    #   @cache[x][y] = pt
    # end
    pt
  end
end
