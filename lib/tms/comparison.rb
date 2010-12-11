require 'tms/space'

module Tms
  class Comparison
    attr_reader :backup_a, :backup_b, :total
    def initialize(backup_a, backup_b)
      @backup_a, @backup_b = backup_a, backup_b
    end

    def run
      @total = 0
      begin
        root_dirs = (backup_a.path.children(false) | backup_b.path.children(false)).sort
        root_dirs.reject!{ |root_dir| root_dir.path[0, 1] == '.' }
        root_dirs.each do |root_dir|
          dirs = Backup.filter_dirs? ? Backup.filter_dirs.map{ |filter_dir| root_dir / filter_dir } : [root_dir]
          dirs.each do |dir|
            compare(backup_a.path / dir, backup_b.path / dir, Path.new('/', dir))
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
        count_space b, path, colorize('  █', :right), "#{path}#{b.postfix}", :recursive => true
      when !b.exist?
        count_space a, path, colorize('█  ', :left), "#{path}#{a.postfix}", :recursive => true, :no_total => true
      when a.ftype != b.ftype
        count_space b, path, colorize('█≠█', :diff_type), "#{path}#{b.postfix} (#{a.ftype}=>#{b.ftype})", :recursive => true
      when a.lstat.ino != b.lstat.ino
        if a.readable_real? && b.readable_real?
          count_space b, path, colorize('█≠█', :diff), "#{path}#{b.postfix}" unless b.symlink? && a.readlink == b.readlink
          if b.directory? && !b.symlink?
            (a.children(false) | b.children(false)).sort.each do |child|
              compare(a / child, b / child, path / child)
            end
          end
        else
          line colorize("??? #{Space::NOT_COUNTED_SPACE} #{path}#{a.postfix}", :unreadable)
        end
      else
        progress do
          path
        end
      end
    end

    COLORS = {
      :total => {:extra => :bold},
      :right => {:foreground => :green},
      :left => {:foreground => :blue},
      :diff_type => {:foreground => :red, :extra => :bold},
      :diff => {:foreground => :yellow},
      :unreadable => {:foreground => :red, :extra => :bold},
    }
    CLEAR_LINE = "\e[K"

    def line(s)
      $stdout.puts "#{s}#{CLEAR_LINE}"
    end

    def progress
      if Tms::Backup.show_progress?
        @last_progress ||= Time.now
        if (now = Time.now) > @last_progress + 0.1
          $stderr.print "#{yield}#{CLEAR_LINE}\r"
          @last_progress = now
        end
      end
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

    def count_space(backup_path, path, prefix, postfix, options = {})
      sub_total = 0
      if options[:recursive]
        backup_path.find do |sub_path|
          sub_total += sub_path.size_if_real_file
          progress do
            "#{prefix} #{space sub_total} #{path / sub_path.to_s[backup_path.to_s.length..-1].to_s}"
          end
        end
      else
        sub_total = backup_path.size_if_real_file
      end
      line "#{prefix} #{space sub_total} #{postfix}"
      unless options[:no_total]
        @total += sub_total
      end
    end
  end
end
