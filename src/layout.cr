require "kiwi"
require "./block.cr"

# A constraint based layout framework so you can draw stuff with ease.
module Layout
  VERSION = "0.2.0"
  extend self

  def solve(block : Block)
    solver = Kiwi::Solver.new
    solve(block, solver)
  end

  # Solves all of the `Primitive` values of a *block* and all of it's children.
  #
  # ### Example
  #
  # ```
  # solver = Kiwi::Solver.new # cache this somewhere
  # Layout.solve(my_block, solver)
  # ```
  #
  # If you only need to solve once you can skip passing in the solver
  # without losing any performance.
  def solve(block : Block, solver : Kiwi::Solver)
    block.each_constraint { |c| solver.add_constraint(c) }
    solver.update_variables
  end
end
