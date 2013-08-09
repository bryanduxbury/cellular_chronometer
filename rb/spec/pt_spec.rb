require "rspec"
require File.expand_path(File.dirname(__FILE__) + "/../pt")

describe Pt do
  it "should translate as expected"
  it "should compare by X then Y"
  it "should flip coordinates"

  it "should convert from point lists to bitvector rows" do
    pts = [
      Pt.new(0,1),
      Pt.new(1,2),
      Pt.new(2,3)
    ]

    Pt.pts_to_bv_rows(pts, 4).should == [0, 1, 2, 4]

    pts = [
      Pt.new(0,1),
      Pt.new(1,2),
      Pt.new(2,3)
    ]

    Pt.pts_to_bv_rows(pts, 6).should == [0, 1, 2, 4, 0, 0]

    pts = [
      Pt.new(0,1),
      Pt.new(1,1),
      Pt.new(2,1)
    ]

    Pt.pts_to_bv_rows(pts, 2).should == [0, 1 | 2 | 4]
  end

  it "should convert from bitvector rows to point lists" do
    pts = [
      Pt.new(0,1),
      Pt.new(1,2),
      Pt.new(2,3)
    ]

    Pt.bv_rows_to_pts([0, 1, 2, 4]).should == pts

    pts = [
      Pt.new(0,1),
      Pt.new(1,2),
      Pt.new(2,3)
    ]

    Pt.bv_rows_to_pts([0, 1, 2, 4, 0, 0]).should == pts

    pts = [
      Pt.new(0,1),
      Pt.new(1,1),
      Pt.new(2,1)
    ]

    Pt.bv_rows_to_pts([0, 1 | 2 | 4]).should == pts
  end
  
  it "should automatically cache when using get" do
    p1 = Pt.get(1,1)
    p2 = Pt.get(1,1)
    p1.object_id.should == p2.object_id
  end
end