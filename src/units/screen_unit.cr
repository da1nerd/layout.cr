module Layout
  abstract struct ScreenUnit(T)
    getter value

    def initialize(@value : T)
    end
  end
end
