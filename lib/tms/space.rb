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

  def space(size, options = {})
    precision = [options[:precision].to_i, 1].max || 2
    length = 4 + precision + (options[:can_be_negative] ? 1 : 0)

    number = size.to_i
    degree = 0
    while number.abs >= 1000 && degree < SIZE_SYMBOLS.length - 1
      degree += 1
      number /= 1024.0
    end

    space = "#{(degree == 0 ? number.to_s : "%.#{precision}f" % number).rjust(length)}#{number == 0 ? ' ' : SIZE_SYMBOLS[degree]}"
    if options[:color]
      unless ''.respond_to?(:red)
        require 'toy/fast_gem'
        fast_gem 'colored'
      end
      step = options[:color].is_a?(Hash) && options[:color][:step] || 10
      start = options[:color].is_a?(Hash) && options[:color][:start] || 1
      coef = 10.0 / (step * Math.log(10))
      color = [[Math.log(size) * coef - start, 0].max.to_i, COLORS.length - 1].min rescue 0
      Colored.colorize(space, COLORS[color])
    else
      space
    end
  end
  self.extend self
end
