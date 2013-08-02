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
    x.hash + y.hash
  end

  def translate(dx,dy)
    Pt.new(x+dx,y+dy)
  end
end
