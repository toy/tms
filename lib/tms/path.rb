module Tms
  # cleaned up Pathname
  class Path
    attr_reader :path
    def initialize(*parts)
      @path = File.join(*parts)
    end

    def /(other)
      self.class.new(@path, other)
    end

    def hash
      @path.hash
    end

    def ==(other)
      return false unless Path === other
      other.to_s == @path
    end
    alias_method :===, :==
    alias_method :eql?, :==

    def <=>(other)
      return nil unless Path === other
      @path <=> other.to_s
    end

    def basename(*args)
      self.class.new(File.basename(@path, *args))
    end

    def dirname(*args)
      self.class.new(File.dirname(@path))
    end

    def readlink
      self.class.new(File.readlink(@path))
    end

    def ftype
      File.ftype(@path)
    end

    def lstat
      File.lstat(@path)
    end

    def size
      File.size(@path)
    end

    def exist?
      File.exist?(@path)
    end

    def directory?
      File.directory?(@path)
    end

    def symlink?
      File.symlink?(@path)
    end

    def readable_real?
      File.readable_real?(@path)
    end

    def children(with_directory = true)
      with_directory = false if @path == '.'
      result = []
      Dir.foreach(@path) do |e|
        next if e == '.' || e == '..'
        if with_directory
          result << self.class.new(File.join(@path, e))
        else
          result << self.class.new(e)
        end
      end
      result
    end

    def to_s
      @path.dup
    end
    alias_method :to_str, :to_s
    alias_method :to_path, :to_s

    def postfix
      case
      when symlink?
        '@'
      when directory?
        '/'
      else
        ''
      end
    end
  end
end
