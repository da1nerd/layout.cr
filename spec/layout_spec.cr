require "./spec_helper"
describe Layout do
  it "creates a layout block" do
    b = Layout::Block.new("my block")
    b.label.should eq("my block")
  end

  it "solves an unconstrained block" do
    b = Layout::Block.new
    system = Kiwi::Solver.new
    Layout.solve(b, system)
    b.width.value.should eq(0)
    b.height.value.should eq(0)
    b.left.value.should eq(0)
    b.top.value.should eq(0)
  end

  it "constraints a primitive to another" do
    a = Layout::Block.new
    b = Layout::Block.new
    a.left.eq b.left + 5
    a.left.constraints.size.should eq(1)
    b.left.constraints.size.should eq(0)
  end

  it "constrain a drawer layout" do
    page = Layout::Block.new
    drawer = Layout::Block.new
    content = Layout::Block.new

    drawer.height.eq page.height
    drawer.width.eq 300
    drawer.left.eq 0, Kiwi::Strength::WEAK

    content.height.eq page.height
    content.width.gte 300
    content.left.eq drawer.right
    # constrain content.x == drawer.width, :WEAK .. this would be nice

    page.left.eq 0
    page.top.eq 0
    page.width.eq 600, Kiwi::Strength::STRONG
    page.height.eq 600, Kiwi::Strength::STRONG

    page.children = [
      drawer,
      content,
    ]

    Layout.solve(page)
    content.left.value.should eq(300)
    content.height.value.should eq(600)
    content.width.value.should eq(300)
    drawer.height.value.should eq(600)
    drawer.width.value.should eq(300)
    drawer.left.value.should eq(0)
  end
end
