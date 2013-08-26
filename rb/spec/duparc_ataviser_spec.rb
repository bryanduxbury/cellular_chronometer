require "rspec"
require File.expand_path(File.dirname(__FILE__) + "/../duparc_ataviser")
require File.expand_path(File.dirname(__FILE__) + "/../intersecting_row_ataviser")

describe DuparcAtaviser do
  ataviser = IntersectingRowAtaviser.new

  it "should explore within the specified region only" do
    g = Grid.new(1,1)
    g.set(0,0)
  
    da = DuparcAtaviser.new(ataviser)
  
    priors = da.prior_generations(g, 0)
    priors.size.should == 0
  end

  it "should explore within a 1-bigger border" do
    g = Grid.new(1,1)
    g.set(0,0)
    
    da = DuparcAtaviser.new(ataviser)
    
    priors = da.prior_generations(g, 1)
    priors.size.should == 140
  end

  it "should find at least one known prior generation" do
    g = Grid.new(3,3)
    g.set(1, 0)
    g.set(1, 1)
    g.set(1, 2)

    # puts g

    priors = DuparcAtaviser.new(ataviser).prior_generations(g)
    # puts priors.size
    # puts priors.uniq.inspect
    # puts priors.map { |cells| Grid.from_cells(3,3,cells) }.join("\n")
    priors.map { |prior| prior.sort }.include?([Pt.new(0, 1), Pt.new(1, 1), Pt.new(2, 1)].sort).should == true
  end
end