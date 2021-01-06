require "kiwi"
require "uuid"

# A constraint based layout framework so you can draw stuff with ease.
module Layout
  VERSION = "0.1.0"
  extend self

  struct Pixel(T)
    getter value

    def initialize(@value : T)
    end
  end

  struct Point(T)
    getter value

    def initialize(@value : T)
    end
  end

  module NumberMixin
    struct ::Number
      # Screen pixels
      def px : Layout::Pixel
        Layout::Pixel.new(self)
      end

      # Screen point
      def pt : Layout::Point
        Layout::Point.new(self)
      end
    end
  end

  # A value of measurement.
  # These appear within `Block`.
  # TODO: Support different types of primitives: Pixel, Point, Relative (Percent)
  class Primitive
    @constant : Bool
    @variable : Kiwi::Variable
    @constraints : Array(Kiwi::Constraint)

    getter constraints

    def initialize
      @constant = false
      @variable = Kiwi::Variable.new(0)
      @constraints = [] of Kiwi::Constraint
    end

    def initialize(name)
      @constant = false
      @variable = Kiwi::Variable.new(name)
      @constraints = [] of Kiwi::Constraint
    end

    # Forcebly assign a value.
    # This causes the primitive to become a constant.
    def value=(value : Float)
      @variable.state.value = value
      @constant = true
    end

    def value : Number
      @variable.state.value
    end

    # Returns the internal constraint variable.
    # This is used by the constraint solver to calculate the final value.
    # In you regular code you should use `Primitive#value` instead.
    def variable
      @variable
    end

    # convert primitives to Kiwi variables
    {% for op in [:+, :-, :*] %}
      def {{op.id}}(primitive : Layout::Primitive)
        self.{{op.id}} primitive.variable
      end
    {% end %}

    {% for op in [:eq, :gte, :lte] %}
      def {{op.id}}(primitive : Layout::Primitive, strength)
        {{op.id}}(primitive.variable, strength)
      end
    {% end %}

    def eq(expression) : Kiwi::Constraint
      eq(expression, Kiwi::Strength::REQUIRED)
    end

    def eq(expression, strength) : Kiwi::Constraint
      c = @variable == expression
      c.strength = strength
      @constraints << c
      c
    end

    def gte(expression) : Kiwi::Constraint
      gte(expression, Kiwi::Strength::REQUIRED)
    end

    def gte(expression, strength) : Kiwi::Constraint
      c = @variable >= expression
      c.strength = strength
      @constraints << c
      c
    end

    def lte(expression) : Kiwi::Constraint
      lte(expression, Kiwi::Strength::REQUIRED)
    end

    def lte(expression, strength) : Kiwi::Constraint
      c = @variable <= expression
      c.strength = strength
      @constraint << c
      c
    end

    def +(expression)
      @variable + expression
    end

    def *(expression)
      @variable * expression
    end

    def -(expression)
      @variable - expression
    end
  end

  # A light wrapp around some primitive stuff.
  # This may end up being merged into `Block`.
  module Primitives
    {% for p in [:width, :height, :x, :y] %}
      @{{p.id}} : Primitive

      getter {{p.id}}
      
      # Set {{p.id}} to a constant *value*
      # DEPRECATED use the logical operators instead.
      def {{p.id}}=(value : Float)
        @{{p.id}}.value = value
        puts "\#{{p.id}}= is deprecated. You should use a logical operator instead."
      end

      # def {{p.id}}==(expression : Kiwi::Expression)
      #   c = @{{p.id}}.variable == expression
      #   @{{p.id}}.constraints << c
      #   c
      # end
    {% end %}
  end

  # A 2-dimensional region.
  # You can manually set it's `Primitive` values or allow them to be calculated automatically.
  class Block
    include Primitives
    @children : Array(Block)
    @label : String
    getter children, label
    property children

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
      @width.variable.name = "#{@label}.width"
      @height.variable.name = "#{@label}.height"
      @x.variable.name = "#{@label}.x"
      @y.variable.name = "#{@label}.y"
    end
  end

  # Solves all of the `Primitive` values of a *block* and all of it's children.
  def solve(block : Block)
    solver = Kiwi::Solver.new
    solve(block, solver)
  end

  # :ditto:
  def solve(block : Block, solver : Kiwi::Solver)
    load_block_constraints block, solver
    solver.update_variables
  end

  # Provides a convenient DLS that converts a `Primitive` expression into a `Kiwi::Constraint`
  # DEPRECATED use `Primitive` logical operators instead.
  # ## Example
  #
  # ```
  # constrain block1.x >= block2.x
  # ```
  macro constrain(expression)
    {% exp = expression.stringify %}
    {% if exp.includes?(">=") %}
      {% parts = exp.split(">=") %}

    {% elsif exp.includes?("<=") %}
      {% parts = exp.split("<=") %}

    {% elsif exp.includes?("==") %}
      {% parts = exp.split("==") %}

    {% else %}
      {% raise "Invalid constraint expression #{exp}" %}
    {% end %}
    {{ exp.gsub(/\b(x|y|width|height)(?!\.)/, "\\0.variable").id }}
  end

  # Loads a *block*'s constraints into the solver
  private def load_block_constraints(block : Block, solver : Kiwi::Solver)
    load_primitive_constraints(block.x, solver)
    load_primitive_constraints(block.y, solver)
    load_primitive_constraints(block.width, solver)
    load_primitive_constraints(block.height, solver)

    0.upto(block.children.size - 1) do |i|
      load_block_constraints(block.children[i], solver)
    end
  end

  private def load_primitive_constraints(primitive : Layout::Primitive, solver : Kiwi::Solver)
    primitive.constraints.each { |c| solver.add_constraint(c) }
  end
end
