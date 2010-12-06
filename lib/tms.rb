require 'pathname'
require 'colored'
require 'xattr'

class Pathname
  def real_directory?
    directory? && !symlink?
  end

  def lino
    @ino ||= lstat.ino
  end

  def postfix
    return '@' if symlink?
    return '/' if directory?
    ''
  end

  def count_size(options = {})
    if defined?(@counted_size)
      @counted_size
    else
      @counted_size = if exist?
        if directory?
          if options[:recursive]
            total = 0
            find do |path|
              total += path.size rescue nil
            end
            total
          else
            0
          end
        else
          size
        end
      else
        nil
      end
    end
  end

  def colored_size(options = {})
    case size = count_size(options)
    when nil
      '!!!!!!'
    when 0
      '      '
    else
      Tms::Space.space(size, :color => true)
    end
  end
end

module Tms
  class << self
    def list
      backups = Backup.list
      Table.new do |t|
        t.col '', :red
        t.col '', :blue
        t.col 'num'
        t.col 'name'
        if Backup.show_all_columns
          %w[state type version started\ at finished\ at completed\ in].each do |name|
            t.col name
          end
        end

        backups.each_with_index do |b, i|
          values = [i, i - backups.length, b.number, b.name]
          if Backup.show_all_columns
            values += [b.state, b.type, b.version, b.started_at, b.finished_at, b.completed_in]
          end
          t << values
        end
      end.print
    end

    def diff(a, b)
      backup_b = Backup.list[b] or abort("No backup with id #{b}")
      backup_a = Backup.list[a] or abort("No backup with id #{a}")
      Backup.diff(backup_a, backup_b)
    end
  end
end

require 'tms.so'
require 'tms/backup'
require 'tms/space'
require 'tms/table'
