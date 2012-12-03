# encoding: UTF-8

require 'tms/space'

module Tms
  class Comparison
    attr_reader :backup_a, :backup_b
    def initialize(backup_a, backup_b)
      @backup_a, @backup_b = backup_a, backup_b
    end

    def run
      @a_total, @b_total = 0, 0
      begin
        if Backup.filter_dirs?
          Backup.filter_dirs.each do |real_dir|
            real_dir = File.expand_path(real_dir)
            dir = Tms::Backup.tm_path(real_dir)
            compare(backup_a.path / dir, backup_b.path / dir, Path.new(real_dir))
          end
        else
          root_dirs = (backup_a.path.children(false) | backup_b.path.children(false)).sort
          root_dirs.reject!{ |root_dir| root_dir.path[0, 1] == '.' }
          root_dirs.each do |dir|
            real_dir = Tms::Backup.real_path(dir)
            compare(backup_a.path / dir, backup_b.path / dir, Path.new('/', real_dir))
          end
        end
      rescue Interrupt
        puts
        puts 'Interrupted'
      end
      if Tms::Backup.show_both_sizes?
        line [colorize('Total:', :total), space(@a_total), space(@b_total)].join(' ')
      else
        line [colorize('Total:', :total), space(@b_total)].join(' ')
      end
    end

  private

    def compare(a, b, path)
      a_exist, b_exist = a.exist?, b.exist?
      case
      when !a_exist && !b_exist
        diff_line nil, nil, path, colorize('×××', :unreadable), "#{path}#{b.postfix}", true
      when !b_exist
        diff_line a, nil, path, colorize('█  ', :left), "#{path}#{a.postfix}", true
      when !a_exist
        diff_line nil, b, path, colorize('  █', :right), "#{path}#{b.postfix}", true
      when a.ftype != b.ftype
        diff_line a, b, path, colorize('█≠█', :diff_type), "#{path}#{b.postfix} (#{a.ftype}=>#{b.ftype})", true
      when a.lstat.ino != b.lstat.ino
        if a.readable_real? && b.readable_real?
          diff_line a, b, path, colorize('█≠█', :diff), "#{path}#{b.postfix}", false unless b.symlink? && a.readlink == b.readlink
          if b.directory? && !b.symlink?
            (a.children(false) | b.children(false)).sort.each do |child|
              compare(a / child, b / child, path / child)
            end
          end
        else
          parts = if Tms::Backup.show_both_sizes?
            ['???', Space::NOT_COUNTED_SPACE, Space::NOT_COUNTED_SPACE, "#{path}#{a.postfix}"]
          else
            ['???', Space::NOT_COUNTED_SPACE, "#{path}#{a.postfix}"]
          end
          line colorize(parts.join(' '), :unreadable)
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

    def trim_right_colored(s, length)
      length = 0 if length < 0
      colorizers = []
      s.gsub(/\e\[\d+(;\d+)*m/) do
        if $`.length < length
          length += $&.length
        else
          colorizers << $&
        end
      end
      s[0, length] << colorizers.join('')
    end

    def trim_left_colored(s, length)
      length = 0 if length < 0
      colorizers = []
      s.reverse.gsub(/m(\d+;)*\d+\[\e/) do
        if $`.length < length
          length += $&.length
        else
          colorizers << $&.reverse
        end
      end
      length = s.length if length > s.length
      colorizers.reverse.join('') << s[-length, length]
    end

    def progress
      if Tms::Backup.show_progress?
        @last_progress ||= Time.now
        if (now = Time.now) > @last_progress + 0.1
          l = yield.to_s
          if width = terminal_width
            l = trim_left_colored(l, terminal_width - 1)
          end
          $stderr.print "#{l}#{CLEAR_LINE}\r"
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

    def diff_line(a_path, b_path, path, prefix, postfix, recursive)
      a_sub_total = a_path ? count_space(a_path, path, prefix, recursive) : nil
      b_sub_total = b_path ? count_space(b_path, path, prefix, recursive) : nil
      if Tms::Backup.show_both_sizes?
        line [prefix, space(a_sub_total), space(b_sub_total), postfix].join(' ')
      else
        line [prefix, b_sub_total ? space(b_sub_total) : space(a_sub_total), postfix].join(' ')
      end
      @a_total += a_sub_total if a_sub_total
      @b_total += b_sub_total if b_sub_total
    end

    def count_space(backup_path, path, prefix, recursive)
      sub_total = 0
      if recursive
        backup_path.find do |sub_path|
          sub_total += sub_path.size_if_real_file
          progress do
            "#{prefix} #{space sub_total} #{path / sub_path.to_s[backup_path.to_s.length..-1].to_s}"
          end
        end
      else
        sub_total = backup_path.size_if_real_file
      end
      sub_total
    end

    def command_exists?(command)
      `which #{command}`
      $?.success?
    end

    # method from hirb: https://github.com/cldwalker/hirb
    # Returns [width, height] of terminal when detected, nil if not detected.
    # Think of this as a simpler version of Highline's Highline::SystemExtensions.terminal_size()
    def terminal_size
      if (ENV['COLUMNS'] =~ /^\d+$/) && (ENV['LINES'] =~ /^\d+$/)
        [ENV['COLUMNS'].to_i, ENV['LINES'].to_i]
      elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM'])) && command_exists?('tput')
        [`tput cols`.to_i, `tput lines`.to_i]
      elsif STDIN.tty? && command_exists?('stty')
        `stty size`.scan(/\d+/).map{ |s| s.to_i }.reverse
      else
        nil
      end
    rescue
      nil
    end

    def terminal_width
      if size = terminal_size
        size[0]
      end
    end
  end
end
