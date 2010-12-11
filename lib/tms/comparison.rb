require 'tms/space'

module Tms
  class Comparison
    attr_reader :a, :b, :total
    def initialize(a, b)
      @a, @b = a, b
    end

    def run
      @total = 0
      begin
        root_dirs = (a.path.children(false) | b.path.children(false)).sort
        root_dirs.reject!{ |c| c.path[0, 1] == '.' }
        root_dirs.each do |root_dir|
          dirs = Backup.filter_dirs? ? Backup.filter_dirs.map{ |fd| root_dir / fd } : [root_dir]
          dirs.each do |dir|
            compare(a.path / dir, b.path / dir, Path.new('/', dir))
          end
        end
      rescue Interrupt
        puts
        puts 'Interrupted'
      end
      line "#{colorize 'Total:', :total} #{space(total)}"
    end

  private

    def compare(a, b, path)
      case
      when !a.exist?
        line "#{colorize '  █', :right    } #{count_space b} #{path}#{b.postfix}"
        # line "#{colorize '  █', :right    } #{space b.count_size(:recursive => true)} #{path}#{b.postfix}"
        # @total += b.count_size(:recursive => true) || 0
      when !b.exist?
        line "#{colorize '█  ', :left     } #{count_space a} #{path}#{a.postfix}"
        # line "#{colorize '█  ', :left     } #{space a.count_size(:recursive => true)} #{path}#{a.postfix}"
      when a.ftype != b.ftype
        line "#{colorize '█≠█', :diff_type} #{count_space b} #{path}#{b.postfix} (#{a.ftype}=>#{b.ftype})"
        # line "#{colorize '█≠█', :diff_type} #{space b.count_size(:recursive => true)} #{path}#{b.postfix} (#{a.ftype}=>#{b.ftype})"
        @total += b.count_size(:recursive => true) || 0
      when a.lstat.ino != b.lstat.ino
        if a.readable_real? && b.readable_real?
          line "#{'█≠█'.yellow} #{count_space b} #{path}#{a.postfix}" if !a.symlink? || a.readlink != b.readlink
          if a.directory? && !a.symlink?
            (a.children(false) | b.children(false)).sort.each do |child|
              compare(a / child, b / child, path / child)
            end
          else
            @total += b.size
          end
        else
          line "??? #{path}#{a.postfix}".red.bold
        end
      else
        # $stderr << "#{CLEAR_LINE}#{path}\r"
        # $stderr.flush
      end
    end

    COLORS = {
      :total => {:extra => :bold},
      :right => {:foreground => :green},
      :left => {:foreground => :blue},
      :diff_type => {:foreground => :red, :extra => :bold},
    }
    CLEAR_LINE = "\e[K"

    def line(s)
      puts "#{CLEAR_LINE}#{s}"
    end

    def space(size)
      Tms::Space.space(size, :color => Tms::Backup.colorize?)
    end

    def colorize(s, type)
      if Tms::Backup.colorize?
        Colored.colorize(s, COLORS[type])
      else
        s
      end
    end

    def count_space(backup)
      Tms::Space.space(backup.path.size, :color => Tms::Backup.colorize?)
    end
  end

  #   def recursive_size
  #     total = 0
  #     find do |path|
  #       $stderr << "#{path}\e[K\r"
  #       $stderr.flush
  #       begin
  #         if path.file?
  #           total += path.size
  #         end
  #       rescue
  #       end
  #     end
  #     total
  #   end
  #
  #   def count_size(options = {})
  #     if @count_size.nil?
  #       @counted_size = if exist?
  #         if directory?
  #           options[:recursive] ? recursive_size : 0
  #         else
  #           size
  #         end
  #       else
  #         false
  #       end
  #     end
  #     @counted_size
  #   end
end
