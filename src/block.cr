require "uuid"
require "./primitive.cr"

module Layout
  # A 2-dimensional region within the layout.
  # You can manually set it's `Primitive` values or allow them to be calculated automatically.
  class Block
    @children : Array(Block)
    @label : String
    getter children, label
    property children

    {% for p in [:width, :height, :x, :y] %}
      @{{p.id}} : Primitive

      getter {{p.id}}
    {% end %}

    def initialize
      initialize(UUID.random.to_s)
    end

    def initialize(@label : String)
      @children = [] of Block
      @width = Primitive.new("#{@label}.width")
      @height = Primitive.new("#{@label}.height")
      @x = Primitive.new("#{@label}.x")
      @y = Primitive.new("#{@label}.y")
    end

    # Enumerate over the block and all of it's children.
    def each(&block : ::Layout::Block ->)
      yield self
      if @children.size > 0
        @children.each do |child|
          child.each(&block)
        end
      end
    end

    # Re-assign the label of this block.
    # The *label* is useful when debugging
    def label=(@label)
      {% for p in [:width, :height, :x, :y] %}
        @{{p.id}}.variable.name = "#{@label}.{{p.id}}"
      {% end %}
    end
  end
end
