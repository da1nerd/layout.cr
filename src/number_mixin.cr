require "./units/pixel.cr"
require "./units/density_pixel.cr"

module Layout
  # Adds some methods to numbers that allow you to more easily create a screen unit
  module NumberMixin
    struct ::Number
      # Screen pixels
      def px : Layout::Pixel
        Layout::Pixel.new(self)
      end

      # Density independant pixel
      def dp : Layout::DensityPixel
        Layout::DensityPixel.new(self)
      end
    end
  end
end
