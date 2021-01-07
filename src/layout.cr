require "kiwi"
require "./block.cr"

# A constraint based layout framework so you can draw stuff with ease.
module Layout
  VERSION = "0.1.0"
  extend self

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
      # TODO: 
    {% elsif exp.includes?("<=") %}
      {% parts = exp.split("<=") %}
      # TODO: 
    {% elsif exp.includes?("==") %}
      {% parts = exp.split("==") %}
      # TODO: 
    {% else %}
      {% raise "Invalid constraint expression #{exp}" %}
    {% end %}
    
    # old code
    {{ exp.gsub(/\b(x|y|width|height)(?!\.)/, "\\0.variable").id }}
  end

  # Loads a *block*'s constraints into the *solver*.
  private def load_block_constraints(block : Block, solver : Kiwi::Solver)
    load_primitive_constraints(block.x, solver)
    load_primitive_constraints(block.y, solver)
    load_primitive_constraints(block.width, solver)
    load_primitive_constraints(block.height, solver)

    0.upto(block.children.size - 1) do |i|
      load_block_constraints(block.children[i], solver)
    end
  end

  # Loads all of the constraints of the *primitive* into the *solver*.
  private def load_primitive_constraints(primitive : Layout::Primitive, solver : Kiwi::Solver)
    primitive.constraints.each { |c| solver.add_constraint(c) }
  end
end
