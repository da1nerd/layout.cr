require "kiwi"
require "uuid"

module Layout
  VERSION = "0.1.0"
  extend self

  enum Direction
    COLUMN
    ROW
  end

  struct Primitive
    @constant : Bool
    @variable : Kiwi::Variable
    getter constant, variable

    def initialize
      @constant = false
      @variable = Kiwi::Variable.new(0)
    end

    def value=(value : Number)
      @variable.state.value = value
      @constant = true
    end

    def value : Number
      @variable.state.value
    end
  end

  module Primitives
    @width : Primitive
    @height : Primitive
    @x : Primitive
    @y : Primitive
    getter height, width, x, y
  end

  struct Block
    include Primitives
    @id : String
    @layout_direction : Direction
    @children : Array(Block)
    @label : String
    getter label, children, layout_direction, id

    def initialize
      initialize(Layout::Direction::COLUMN, "block")
    end

    def initialize(@layout_direction : Direction, @label : String)
      @id = UUID.random.to_s
      @children = [] of Block
      @width = Primitive.new
      @height = Primitive.new
      @x = Primitive.new
      @y = Primitive.new
    end
  end

  def solve(block : Block, solver : Kiwi::Solver)
    load_block_constraints block, solver
    solver.update_variables
  end

  macro constrain(constraint)
    {% data = constraint.stringify.split %}
    {{ data[0].id }}.variable {{ data[1].id }} {{ data[2].id }}.variable
  end

  # Loads a block's constraints into the solver
  private def load_block_constraints(block : Block, solver : Kiwi::Solver)
    load_primitive(block.width, solver)
    load_primitive(block.height, solver)
    load_primitive(block.x, solver)
    load_primitive(block.y, solver)

    0.upto(block.children.size - 1) do |i|
      sibling : Block? = block.children[i - 1] if i > 0
      child : Block = block.children[i]
      is_last : Bool = i == block.children.size - 1

      load_block_constraints(child, solver)

      # constrain child

      # baseline constraints
      solver.add_constraint constrain(child.x >= block.x)
      # solver.add_constraint
    end
  end

  # ILoads a single primitive value into the the system as either a constant
  # or a variable constrainted to be greater than or equal to 0.
  private def load_primitive(primitive : Primitive, solver : Kiwi::Solver)
    if primitive.constant
      solver.add_constraint primitive.variable == primitive.value
    else
      solver.add_constraint primitive.variable >= 0
    end
  end
end
