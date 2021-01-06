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
    b.x.value.should eq(0)
    b.y.value.should eq(0)
  end

  it "constraints a primitive to another" do
    a = Layout::Block.new
    b = Layout::Block.new
    a.x.eq b.x + 5
    a.x.constraints.size.should eq(1)
    b.x.constraints.size.should eq(0)
  end

  it "constrain a drawer layout" do
    page = Layout::Block.new
    drawer = Layout::Block.new
    content = Layout::Block.new

    drawer.height.eq page.height
    drawer.width.eq 300
    drawer.x.eq 0, Kiwi::Strength::WEAK

    content.height.eq page.height
    content.width.gte 300
    content.x.eq drawer.width + drawer.x
    # constrain content.x == drawer.width, :WEAK .. this would be nice

    page.x.eq 0
    page.y.eq 0
    page.width.eq 600, Kiwi::Strength::STRONG
    page.height.eq 600, Kiwi::Strength::STRONG

    page.children = [
      drawer,
      content,
    ]

    Layout.solve(page)
    content.x.value.should eq(300)
    content.height.value.should eq(600)
    content.width.value.should eq(300)
    drawer.height.value.should eq(600)
    drawer.width.value.should eq(300)
    drawer.x.value.should eq(0)
  end
  # it "constrains a simple block hierarchy" do
  #   screen = Layout::Block.new
  #   screen.width = 300f64
  #   screen.height = 300f64
  #   screen.x = 0f64
  #   screen.y = 0f64

  #   top_block = Layout::Block.new
  #   top_block.height = 100f64

  #   bottom_block = Layout::Block.new

  #   screen.children = [top_block, bottom_block]

  #   Layout.solve(screen)

  #   top_block.width.value.should eq(300f64)
  #   top_block.x.value.should eq(0f64)
  #   top_block.y.value.should eq(0f64)

  #   bottom_block.width.value.should eq(300f64)
  #   bottom_block.height.value.should eq(200f64)
  #   bottom_block.x.value.should eq(0f64)
  #   bottom_block.y.value.should eq(100f64)
  # end

  # it "constrains a complex block hierarchy" do
  #   page = Layout::Block.new
  #   page.width = 200f64
  #   page.height = 300f64
  #   page.x = 0f64
  #   page.y = 0f64
  #   header = Layout::Block.new
  #   header.height = 10f64
  #   body = Layout::Block.new
  #   ancestors = Layout::Block.new
  #   ancestors.height = 10f64
  #   body_content = Layout::Block.new
  #   leader_groups = Layout::Block.new
  #   leader_groups.width = 30f64
  #   generations = Layout::Block.new
  #   generations.width = 10f64
  #   graph = Layout::Block.new
  #   body_content.children = [
  #     leader_groups,
  #     generations,
  #     graph,
  #   ]
  #   body.children = [
  #     ancestors,
  #     body_content,
  #   ]
  #   metrics = Layout::Block.new
  #   metrics.height = 50f64
  #   page.children = [
  #     header,
  #     body,
  #     metrics,
  #   ]

  #   solver = Kiwi::Solver.new
  #   Layout.solve(page, solver)

  #   # page
  #   header.height.value.should eq(10)
  #   header.width.value.should eq(page.width.value)
  #   # -> box
  #   ancestors.height.value.should eq(10)
  #   ancestors.width.value.should eq(page.width.value)
  #   # -> box (row)
  #   leader_groups.height.value.should eq(230)
  #   leader_groups.width.value.should eq(30)

  #   generations.height.value.should eq(230)
  #   generations.width.value.should eq(10)

  #   graph.height.value.should eq(230)
  #   graph.width.value.should eq(160)
  #   # <- page
  #   metrics.height.value.should eq(50)
  #   metrics.width.value.should eq(page.width.value)
  # end
end
