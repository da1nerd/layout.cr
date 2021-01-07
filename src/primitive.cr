require "kiwi"

module Layout
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
      @constraints << c
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
end
