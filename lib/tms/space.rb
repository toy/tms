require 'colored'

module Tms::Space
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
  NOT_COUNTED_SPACE = ('!' * LENGTH).bold.red

  def self.space(size, options = {})
    case size
    when false
      NOT_COUNTED_SPACE
    when 0
      EMPTY_SPACE
    else
      number, degree = size, 0
      while number.abs >= 1000 && degree < SIZE_SYMBOLS.length - 1
        number /= 1024.0
        degree += 1
      end

      space = "#{degree == 0 ? number.to_s : "%.#{PRECISION}f" % number}#{SIZE_SYMBOLS[degree]}".rjust(LENGTH)
      color = [[Math.log(size) * COEF, 1].max.to_i, COLORS.length].min - 1
      Colored.colorize(space, COLORS[color])
    end
  end
end
