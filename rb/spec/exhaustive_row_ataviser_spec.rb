require "rspec"
require File.expand_path(File.dirname(__FILE__) + "/../exhaustive_row_ataviser")

describe ExhaustiveRowAtaviser do
  it "should calculate row priors without extra cells" do
    results = ExhaustiveRowAtaviser.new.atavise(1, 0, [0,1,2])
    puts results.inspect
  end

  it "should calculate row priors with extra cells" do
    results = ExhaustiveRowAtaviser.new.atavise(1, 1, [1])
    results.size.should == 140
    
    results = ExhaustiveRowAtaviser.new.atavise(2, 1, [1,2])
    results.size.should == 417
  end
end