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
    puts g.cells.inspect
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
  
  it "should place complete patterns where specified" do
    g = Grid.new(4, 4)
    g.place(0, 0, "XX  \n  XX\n")
    g.get(0,0).should == true
    g.get(1,0).should == true
    g.get(2,1).should == true
    g.get(3,1).should == true
    
    g = Grid.new(6, 6)
    g.place(2, 2, "XX  \n  XX")
    g.get(2,2).should == true
    g.get(3,2).should == true
    g.get(4,3).should == true
    g.get(5,3).should == true
  end
  
  it "should compute combinations" do
    combos = []
    Grid.for_each_combination([1,2,3], [], 2) do |combo|
      combos << combo
    end
    combos.should == [[2,3],[1,3],[1,2]]

    combos = []
    Grid.for_each_combination([1,2,3], [], 1) do |combo|
      combos << combo
    end
    combos.should == [[3],[2],[1]]
    
    combos = []
    Grid.for_each_combination([1,2,3], [], 3) do |combo|
      combos << combo
    end
    combos.should == [[1,2,3]]
  end
end
