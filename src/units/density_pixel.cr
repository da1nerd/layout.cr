require "./screen_unit.cr"

module Layout
  # A density independant pixel
  struct DensityPixel(T) < ScreenUnit(T)
  end
end
