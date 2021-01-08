require "./primitive.cr"

# Tools for defining primitives
module Layout
  # Tools for using primitives
  module PrimitiveTools
    # Defines a new primitive.
    # This will generate several helper methods so you can properly initialize your primitives.
    #
    # ### Example
    # Here we create a sample Point class that has an `x` and `y` primitive.
    # Now, after setting some contraints we can load the constraints into `Kiwi::Solver` and find the final values.
    #
    # ```
    # require "layout/primitive_tools"
    # require "kiwi"
    #
    # class Point
    #   include PrimitiveTools
    #   primitive :x
    #   primitive :y
    # end
    #
    # a = Point.new
    # b = Point.new
    # b.x.eq a.x + 10
    # b.y.eq a.y / 2
    # a.x.eq 10
    # a.y.eq 10
    # # go on to solve the block
    # ```
    #
    # For a full example take a look at the implementation of `Block`.
    macro primitive(name)
      @{{ name.id }} = Primitive.new("{{name}}")

      getter {{ name.id }}

      # Returns all of the defined primitives
      private def primitives
        {% if @type.methods.map(&.name).includes?(:primitives.id) %}
          ([@{{ name.id }}] + previous_def).uniq
        {% else %}
          [@{{ name.id }}]
        {% end %}
      end

      # Changes the *label* prefix on all of the primitives.
      # This can help to provide context when debugging.
      private def label_primitives(label)
        {% if @type.methods.map(&.name).includes?(:label_primitives.id) %}
          previous_def
        {% end %}
        @{{name.id}}.variable.name = "#{label}.{{name.id}}"
      end
    end
  end
end
