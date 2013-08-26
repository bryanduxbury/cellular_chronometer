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
    # puts g.cells.inspect
    g.get(0,0).should == true
  end

  it "should advance to the correct next generation" do
    # lone cell will die
    g = Grid.new(4, 4)
    g.set(0,0)
    g = g.next_generation
    g.get(0,0).should == false

    # all initial cells live and birth a new one in the corner
    g = Grid.new(4, 4)
    g.set(0,0)
    g.set(1,0)
    g.set(0,1)
    ng = g.next_generation
    ng.get(0,0).should == true
    ng.get(1,0).should == true
    ng.get(0,1).should == true
    ng.get(1,1).should == true

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

  it "shouldn't spontaneously generate cells" do
pattern = <<-EOF
###
   
###
   
   
EOF
    g = Grid.new(5,3)
    g.place(0, 0, pattern)
    
    # puts g
    
    n = g.next_generation
    
    # puts n
    
    t = Grid.new(5,3)

target = <<-EOF
 # 
   
 # 
 # 
   
EOF
    t.place(0,0, target)
    n.should == t
  end

  it "should behave correctly at the edges of the board" do
    g = Grid.new(5,3)
    g.set(2,3)
    g.set(1,4)
    g.set(2,4)
    # puts g
    target = Grid.from_cells(5, 3, [Pt.new(1,4), Pt.new(2,4), Pt.new(1,3), Pt.new(2,3)])
    # puts target
    # puts g.next_generation.inspect
    g.next_generation.should == target
  end
  

  it "should to_s" do
    g = Grid.new(2, 2)
    g.set(0,0)
    g.set(1,1)
    g.to_s.should == "+--+\n|# |\n| #|\n+--+"
  end

  it "should place complete patterns where specified" do
    g = Grid.new(4, 4)
    g.place(0, 0, "##  \n  ##\n")
    g.get(0,0).should == true
    g.get(1,0).should == true
    g.get(2,1).should == true
    g.get(3,1).should == true
    
    g = Grid.new(6, 6)
    g.place(2, 2, "##  \n  ##")
    g.get(2,2).should == true
    g.get(3,2).should == true
    g.get(4,3).should == true
    g.get(5,3).should == true
  end

  it "should convert to a row table" do
    Grid.new(3, 3).by_row.should == [[],[],[]]
    g = Grid.new(3,3)
    g.set(1,1)
    g.by_row.should == [[],[Pt.new(1,1)],[]]
  end
end
