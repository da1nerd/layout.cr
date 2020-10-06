require "./spec_helper"

describe Layout do
  # TODO: Write tests

  it "switches primitives to constant after changing the value" do
    p = Layout::Primitive.new
    p.constant.should eq(false)
    p.value.should eq(0)
    p.value = 2.0
    p.value.should eq(2)
    p.constant.should eq(true)
  end

  it "creates a layout block" do
    b = Layout::Block.new(Layout::Direction::COLUMN, "my block")
    b.label.should eq("my block")
  end

  it "solves a single block's constraints" do
    b = Layout::Block.new
    system = Kiwi::Solver.new
    Layout.solve(b, system)
    b.width.value.should eq(0)
    b.height.value.should eq(0)
    b.x.value.should eq(0)
    b.y.value.should eq(0)
  end
end
