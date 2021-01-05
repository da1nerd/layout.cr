require "./spec_helper"

describe Layout do
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
