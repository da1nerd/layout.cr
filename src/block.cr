require "uuid"
require "./primitive.cr"

module Layout
  # A 2-dimensional region within the layout.
  # You can manually set it's `Primitive` values or allow them to be calculated automatically.
  # TODO: the code here could probably be simplified with macros
  class Block
    @children : Array(Block)
    @label : String
    @width : Primitive
    @height : Primitive
    @right : Primitive
    @left : Primitive
    @top : Primitive
    @bottom : Primitive
    @center_x : Primitive
    @center_y : Primitive

    getter children, label, width, height, right, left, top, bottom, center_x, center_y
    property children

    def initialize
      initialize(UUID.random.to_s)
    end

    def x
      @left
    end

    def y
      @top
    end

    def initialize(@label : String)
      @children = [] of Block
      @width = Primitive.new("#{@label}.width")
      @height = Primitive.new("#{@label}.height")

      @center_x = Primitive.new("#{@label}.center_x")
      @center_y = Primitive.new("#{@label}.center_y")

      @right = Primitive.new("#{@label}.right")
      @left = Primitive.new("#{@label}.left")
      @top = Primitive.new("#{@label}.top")
      @bottom = Primitive.new("#{@label}.bottom")

      # set up some pre-constraints
      @right.eq @left + @width
      @bottom.eq @top + @height
      @center_x.eq @left + (@width / 2)
      @center_y.eq @top + (@height / 2)
    end

    # Enumerate over the block and all of it's children.
    def each(&block : Block ->)
      yield self
      @children.each do |child|
        child.each(&block)
      end
    end

    # Enumerate over all of the constraints in this block hierarchy
    def each_constraint(&block : Kiwi::Constraint ->)
      @width.constraints.each { |c| yield c }
      @height.constraints.each { |c| yield c }
      @center_x.constraints.each { |c| yield c }
      @center_y.constraints.each { |c| yield c }
      @right.constraints.each { |c| yield c }
      @left.constraints.each { |c| yield c }
      @top.constraints.each { |c| yield c }
      @bottom.constraints.each { |c| yield c }

      @children.each do |child|
        child.each_constraint(&block)
      end
    end

    # Re-assign the label of this block.
    # The *label* is useful when debugging
    def label=(@label)
      @width.variable.name = "#{@label}.width"
      @height.variable.name = "#{@label}.height"
      @center_x.variable.name = "#{@label}.center_x"
      @center_y.variable.name = "#{@label}.center_y"
      @right.variable.name = "#{@label}.right"
      @left.variable.name = "#{@label}.left"
      @top.variable.name = "#{@label}.top"
      @bottom.variable.name = "#{@label}.bottom"
    end
  end
end
