require "rspec"
require File.expand_path(File.dirname(__FILE__) + "/../duparc_predecessor")

describe DuparcPredecessor do
  it "should correctly determine edge priors" do
    results = DuparcPredecessor.new.send(:edge_priors, Grid.new(3,3), [1])
    results.should include([Pt.new(0,0), Pt.new(1,0), Pt.new(2,0)])
    results.should include([Pt.new(0,1), Pt.new(1,0), Pt.new(2,0)])
    results.should include([Pt.new(0,1), Pt.new(1,0), Pt.new(2,1)])
    results.should include([Pt.new(0,1), Pt.new(1,1), Pt.new(2,1)])
  end

  # it "should convert pointlists to "

  it "should find at least one known prior generation" do
    g = Grid.new(3,3)
    g.set(1, 0)
    g.set(1, 1)
    g.set(1, 2)
    
    priors = DuparcPredecessor.new.prior_generations(g)
    puts priors.inspect
    priors.should include([Pt.new(0, 1), Pt.new(1, 1), Pt.new(2, 1)])
  end

  it "should convert bit vectors into pointlists" do
    expected_points = [
      Pt.new(1, 0), 
      Pt.new(0, 1),
      Pt.new(1, 1),
      Pt.new(2, 1),
      Pt.new(0, 2),
      Pt.new(2, 2)
    ]
    DuparcPredecessor.new().send(:to_pt_list, ["010", "111", "101"]).should == expected_points
  end
end