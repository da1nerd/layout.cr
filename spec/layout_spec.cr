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
    screen = Layout::Block.new
    screen.width = 100f64
    screen.height = 300f64
    screen.x = 0f64
    screen.y = 0f64

    top_block = Layout::Block.new
    top_block.height = 50f64

    bottom_block = Layout::Block.new

    screen.children = [top_block, bottom_block]

    Layout.solve(screen)

    top_block.width.value.should eq(100f64)
    top_block.x.value.should eq(0f64)
    top_block.y.value.should eq(0f64)

    bottom_block.width.value.should eq(100f64)
    bottom_block.height.value.should eq(250f64)
    bottom_block.x.value.should eq(0f64)
    bottom_block.y.value.should eq(50f64)
  end

  it "constrains a complex block hierarchy" do
    page = Layout::Block.new
    page.width = 200f64
    page.height = 300f64
    page.x = 0f64
    page.y = 0f64
    header = Layout::Block.new
    header.height = 10f64
    body = Layout::Block.new
    ancestors = Layout::Block.new
    ancestors.height = 10f64
    body_content = Layout::Block.new(Layout::Direction::ROW)
    leader_groups = Layout::Block.new
    leader_groups.width = 30f64
    generations = Layout::Block.new
    generations.width = 10f64
    graph = Layout::Block.new
    body_content.children = [
      leader_groups,
      generations,
      graph,
    ]
    body.children = [
      ancestors,
      body_content,
    ]
    metrics = Layout::Block.new
    metrics.height = 50f64
    page.children = [
      header,
      body,
      metrics,
    ]

    solver = Kiwi::Solver.new
    Layout.solve(page, solver)

    # page
    header.height.value.should eq(10)
    header.width.value.should eq(page.width.value)
    # -> box
    ancestors.height.value.should eq(10)
    ancestors.width.value.should eq(page.width.value)
    # -> box (row)
    leader_groups.height.value.should eq(230)
    leader_groups.width.value.should eq(30)

    generations.height.value.should eq(230)
    generations.width.value.should eq(10)

    graph.height.value.should eq(230)
    graph.width.value.should eq(160)
    # <- page
    metrics.height.value.should eq(50)
    metrics.width.value.should eq(page.width.value)
  end
end
