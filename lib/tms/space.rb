require 'colored'

module Tms
  module Space
    SIZE_SYMBOLS = %w[B K M G T P E Z Y].freeze
    COLORS = [].tap do |colors|
      [:white, :black, :yellow, :red].each do |color|
        colors << {:foreground => color}
        colors << {:foreground => color, :extra => :bold}
      end
      colors << {:foreground => :yellow, :extra => :reversed}
      colors << {:foreground => :red, :extra => :reversed}
    end.freeze
    PRECISION = 1
    LENGTH = 4 + PRECISION + 1
    COEF = 1 / Math.log(10)

    EMPTY_SPACE = ' ' * LENGTH
    NOT_COUNTED_SPACE = '!' * LENGTH

    class << self
      attr_writer :base10
      def denominator
        @denominator ||= @base10 ? 1000.0 : 1024.0
      end

      def space(size, options = {})
        case size
        when false
          NOT_COUNTED_SPACE.bold.red
        when 0
          EMPTY_SPACE
        else
          number, degree = size, 0
          while number.abs >= 1000 && degree < SIZE_SYMBOLS.length - 1
            number /= denominator
            degree += 1
          end

          space = "#{degree == 0 ? number.to_s : "%.#{PRECISION}f" % number}#{SIZE_SYMBOLS[degree]}".rjust(LENGTH)
          if options[:color]
            color = [[Math.log(size) * COEF, 1].max.to_i, COLORS.length].min - 1
            space = Colored.colorize(space, COLORS[color])
          end
          space
        end
      end
    end
  end
end
