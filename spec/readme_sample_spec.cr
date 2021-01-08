require "./spec_helper"
describe Layout do
  it "runs the readme example" do
    screen = Layout::Block.new
    screen.width.eq 300
    screen.height.eq 300

    top_block = Layout::Block.new
    top_block.height.eq 100
    top_block.width.eq screen.width

    bottom_block = Layout::Block.new
    bottom_block.top.eq top_block.bottom
    bottom_block.width.eq screen.width
    bottom_block.bottom.eq screen.bottom

    screen.children = [top_block, bottom_block]

    Layout.solve(screen)

    top_block.left.value.should eq(0)
    top_block.top.value.should eq(0)
    top_block.width.value.should eq(300)
    top_block.height.value.should eq(100)

    bottom_block.left.value.should eq(0)
    bottom_block.top.value.should eq(100)
    bottom_block.width.value.should eq(300)
    bottom_block.height.value.should eq(200)
  end
end