require "rspec"
require File.expand_path(File.dirname(__FILE__) + "/../grid")

describe Grid do 
  it "should build properly from rows and cols spec" do
    g = Grid.new(4, 4)
    g.rows.should == 4
    g.cols.should == 4
  end
  
  it "should get and set correctly" do
    g = Grid.new(4,4)
    g.set(0,0)
    g.get(0,0).should == true
  end
  
  it "should advance to the correct next generation" do
    # lone cell will die
    g = Grid.new(4, 4)
    g.set(0,0)
    g = g.next_generation
    g.get(0,0).should == false

    # block is immortal
    g = Grid.new(4, 4)
    g.set(0,0)
    g.set(0,1)
    g.set(1,0)
    g.set(1,1)
    g = g.next_generation
    g.get(0,0).should == true
    g.get(0,1).should == true
    g.get(1,0).should == true
    g.get(1,1).should == true
  end
  
  it "should to_s" do
    g = Grid.new(2, 2)
    g.set(0,0)
    g.set(1,1)
    g.to_s.should == "+--+\n|X |\n| X|\n+--+"
  end
end
