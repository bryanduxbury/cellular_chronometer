require "rspec"
require File.expand_path(File.dirname(__FILE__) + "/../duparc_ataviser")

describe DuparcAtaviser do
  it "should explore within a 1-bigger border" do
    g = Grid.new(1,1)
    g.set(0,0)
    
    da = DuparcAtaviser.new
    
    priors = da.prior_generations(g)
    priors.size.should == 140
  end
  
  it "should determine row priors" do
    g = Grid.new(1,1)
    g.set(0,0)
    results = DuparcAtaviser.new.send(:row_priors, 3, [1])
    results.size.should == 140
  end
  
  # it "should correctly determine edge priors" do
  #   results = DuparcAtaviser.new.send(:edge_priors, Grid.new(3,3), [1])
  #   results.should include([Pt.new(0,0), Pt.new(1,0), Pt.new(2,0)])
  #   results.should include([Pt.new(0,1), Pt.new(1,0), Pt.new(2,0)])
  #   results.should include([Pt.new(0,1), Pt.new(1,0), Pt.new(2,1)])
  #   results.should include([Pt.new(0,1), Pt.new(1,1), Pt.new(2,1)])
  # end

  # it "should convert pointlists to "

  it "should find at least one known prior generation" do
    g = Grid.new(3,3)
    g.set(1, 0)
    g.set(1, 1)
    g.set(1, 2)
    
    priors = DuparcAtaviser.new.prior_generations(g)
    # priors.each do |prior|
    #   puts Grid.from_cells(5,5, prior)
    #   puts Grid.from_cells(5,5, prior).next_generation
    #   exit
    # end
    # puts priors.inspect
    priors.map { |prior| prior.sort }.include?([Pt.new(0, 1), Pt.new(1, 1), Pt.new(2, 1)].map { |pt| pt.translate(1,1) }.sort).should == true
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
    DuparcAtaviser.new().send(:to_pt_list, ["010", "111", "101"]).should == expected_points
  end
end