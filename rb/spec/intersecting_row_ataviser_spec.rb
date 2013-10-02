require "rspec"
require File.expand_path(File.dirname(__FILE__) + "/../intersecting_row_ataviser")
require File.expand_path(File.dirname(__FILE__) + "/../exhaustive_row_ataviser")

describe IntersectingRowAtaviser do
  it "should calculate row priors with extra cells" do
    results = IntersectingRowAtaviser.new.atavise(1, [1])
    results.size.should == 140
  end

  it "should behave exactly like the exhaustive version on a few examples" do
    ia = IntersectingRowAtaviser.new
    ea = ExhaustiveRowAtaviser.new

    i = ia.atavise(1,[1]).map(&:sort).sort
    e = ea.atavise(1,[1]).map(&:sort).sort
    i.should == e

    i = ia.atavise(2, [1,2]).map(&:sort).sort
    e = ea.atavise(2, [1,2]).map(&:sort).sort
    i.should == e
  end

  it "should filter solutions using provided block" do
    filter = proc do |solution|
      # dead top and dead bottom
      solution.first == 0 && solution.last == 0
    end
    results = IntersectingRowAtaviser.new(filter).atavise(1, [1])
    results.size.should == 1
  end
end