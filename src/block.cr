require "uuid"
require "./primitive_tools.cr"

module Layout
  # A 2-dimensional region within the layout.
  # You can constrain the different `Primitive`s on a block
  # in order to properly position it.
  #
  # ### Example
  #
  # The follow will create a 100x100 square that is offset
  # from the top left corner of the screen by half it's width.
  # ```
  # region = Block.new
  # region.height.eq 100
  # region.width.eq 100
  # region.top.eq region.width / 2
  # region.left.eq region.width / 2
  # ```
  class Block
    include PrimitiveTools
    @children : Array(Block)
    @label : String
    primitive :height
    primitive :width
    primitive :left
    primitive :right
    primitive :top
    primitive :bottom
    primitive :center_x
    primitive :center_y

    # This is a unique or manually set identifier to help in debugging
    getter label

    # You can encapsulate blocks inside of each other as children.
    # This makes it easier to compose complex layout blocks.
    property children

    def initialize
      initialize(UUID.random.to_s)
    end

    # An alias to the `#left` primitive
    def x
      @left
    end

    # An alias to the `#top` primitive
    def y
      @top
    end

    # Initialize with a *label* for easier debugging.
    def initialize(@label : String)
      @children = [] of Block
      label_primitives @label

      # set up some pre-constraints
      @right.eq @left + @width
      @bottom.eq @top + @height
      @center_x.eq @left + (@width / 2)
      @center_y.eq @top + (@height / 2)
    end

    # Enumerate over all blocks in this block's hierarchy.
    def each(&block : Block ->)
      yield self
      @children.each do |child|
        child.each(&block)
      end
    end

    # Enumerate over all constraints in this block's hierarchy
    def each_constraint(&block : Kiwi::Constraint ->)
      self.primitives.each do |p|
        p.constraints.each { |c| yield c }
      end

      @children.each do |child|
        child.each_constraint(&block)
      end
    end

    # Re-assign the label of this block.
    # Providing a label helps to provide context when debugging.
    # You can also add a label in `#initialize`
    def label=(@label)
      label_primitives(@label)
    end
  end
end
