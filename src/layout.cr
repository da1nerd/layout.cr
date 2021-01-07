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
    block.each_constraint { |c| solver.add_constraint(c) }
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
end
