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

  it "constrains a simple block hierarchy" do
    b1 = Layout::Block.new
    b1.width.value = 100f64
    b1.height.value = 300f64
    b1.x.value = 0f64
    b1.y.value = 0f64

    b2 = Layout::Block.new
    b2.height.value = 50f64

    b3 = Layout::Block.new

    b1.children = [b2, b3]

    system = Kiwi::Solver.new
    Layout.solve(b1, system)

    b2.width.value.should eq(100f64)
    b2.x.value.should eq(0f64)
    b2.y.value.should eq(0f64)

    b3.width.value.should eq(100f64)
    b3.x.value.should eq(0f64)
    b3.y.value.should eq(50f64)
  end
end
