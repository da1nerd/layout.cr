require "kiwi"

module Layout
  # A constrainable value of measurement.
  #
  class Primitive
    @variable : Kiwi::Variable
    @constraints : Array(Kiwi::Constraint)

    # The constraints on this primitive.
    # This is used internally to load the constraints into the constraint solver.
    getter constraints

    def initialize
      @variable = Kiwi::Variable.new(0)
      @constraints = [] of Kiwi::Constraint
    end

    def initialize(name)
      @variable = Kiwi::Variable.new(name)
      @constraints = [] of Kiwi::Constraint
    end

    # The final calculated value of the primitive.
    # This is the value you'll use after solving the constraints.
    def value
      @variable.state.value
    end

    # Returns the internal constraint variable.
    # This is used by the constraint solver to calculate the final value.
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
        {{op.id}}(primitive.variable, read_strength(strength))
      end
    {% end %}

    def eq(expression) : Kiwi::Constraint
      eq(expression, :REQUIRED)
    end

    def eq(expression, strength) : Kiwi::Constraint
      c = @variable == expression
      c.strength = read_strength(strength)
      @constraints << c
      c
    end

    def gte(expression) : Kiwi::Constraint
      gte(expression, :REQUIRED)
    end

    def gte(expression, strength) : Kiwi::Constraint
      c = @variable >= expression
      c.strength = read_strength(strength)
      @constraints << c
      c
    end

    def lte(expression) : Kiwi::Constraint
      lte(expression, :REQUIRED)
    end

    def lte(expression, strength) : Kiwi::Constraint
      c = @variable <= expression
      c.strength = read_strength(strength)
      @constraints << c
      c
    end

    # translates a symbol to a `Kiwi::Strength`
    private def read_strength(strength : Symbol)
      case strength
      when :REQUIRED
        Kiwi::Strength::REQUIRED
      when :STRONG
        Kiwi::Strength::STRONG
      when :MEDIUM
        Kiwi::Strength::MEDIUM
      when :WEAK
        Kiwi::Strength::WEAK
      else
        raise "#{strength} is not a supported strength."
      end
    end

    private def read_strength(strength : Float64)
      strength
    end

    delegate :+, :/, :*, :-, to: @variable
  end
end
