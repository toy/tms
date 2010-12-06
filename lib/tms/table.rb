class Tms::Table
  attr_accessor :cols, :rows

  def initialize(&block)
    @cols, @rows = [], []
    yield self if block_given?
  end

  def col(name, color = nil)
    @cols << {:name => name, :color => color}
  end

  def <<(row)
    @rows << row
  end

  def lines
    @cols.each_with_index do |col, i|
      col[:width] = ([col[:name]] + @rows.map{ |row| row[i] }).map(&:to_s).map(&:length).max
    end

    ([@cols.map{ |col| col[:name] }] + @rows).each_with_index.map do |line, i|
      line.zip(@cols).map do |val, col|
        width, color = col[:width], col[:color]
        val_s = val.to_s.send(val.is_a?(Integer) ? :rjust : :ljust, width)
        color ? Colored.colorize(val_s, :foreground => color) : val_s
      end.join(' ')
    end
  end

  def print
    puts lines
  end
end
