require "rspec"
require File.expand_path(File.dirname(__FILE__) + "/../intersecting_row_ataviser")
require File.expand_path(File.dirname(__FILE__) + "/../exhaustive_row_ataviser")

describe IntersectingRowAtaviser do
  # it "should calculate row priors without extra cells" do
  #   results = IntersectingRowAtaviser.new.atavise(1, 0, [0,1,2])
  #   # puts results.inspect
  # end

  it "should calculate row priors with extra cells" do
    results = IntersectingRowAtaviser.new.atavise(1, 1, [1])
    results.size.should == 140
  end

  it "should behave exactly like the exhaustive version on a few examples" do
    ia = IntersectingRowAtaviser.new
    ea = ExhaustiveRowAtaviser.new

    i = ia.atavise(1,1,[1]).map(&:sort).sort
    e = ea.atavise(1,1,[1]).map(&:sort).sort
    i.should == e

    i = ia.atavise(2, 1, [1,2]).map(&:sort).sort
    e = ea.atavise(2, 1, [1,2]).map(&:sort).sort
    i.should == e
  end

  it "should convert to pt list" do
    pts = [
      Pt.new(0,1),
      Pt.new(1,0),
      Pt.new(1,2),
      Pt.new(2,0),
      Pt.new(2,1),
      Pt.new(2,2)
    ]
    IntersectingRowAtaviser.new.send(:to_pt_list, ["010", "101", "111"]).sort.should == pts.sort
  end
end