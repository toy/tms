class Tms::Table
  attr_accessor :cols, :rows

  def initialize(&block)
    @cols, @rows = [], []
    yield self if block_given?
  end

  ADJUST = {:left => :ljust, :right => :rjust, :center => :center}
  def col(name, color = nil, adjust = nil)
    @cols << {:name => name, :color => color, :adjust => ADJUST[adjust]}
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
        width, color, adjust = col.values_at(:width, :color, :adjust)
        adjust ||= val.is_a?(Integer) ? :rjust : :ljust
        val_s = val.to_s.send(adjust, width)
        val_s = Colored.colorize(val_s, :foreground => color) if color
        val_s
      end.join(' ')
    end
  end

  def print
    puts lines
  end
end
