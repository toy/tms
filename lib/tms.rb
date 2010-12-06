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
    case
    when symlink?
      '@'
    when directory?
      '/'
    else
      ''
    end
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
          t.col 'state'
          t.col 'type'
          t.col 'version'
          t.col 'completed in', nil, :right
          t.col 'started at'
          t.col 'finished at'
        end

        backups.each_with_index do |b, i|
          values = [
            i,
            i - backups.length,
            b.number,
            b.name
          ]
          if Backup.show_all_columns
            values += [
              b.state,
              b.type,
              b.version,
              format(b.completed_in, :time),
              format(b.started_at, :date),
              format(b.finished_at, :date)
            ]
          end
          t << values
        end
      end.print
    end

    def diff(a, b = nil)
      a_id = backup_id(a)
      if b
        b_id = backup_id(b)
      else
        if a_id == 0
          abort("No backup before oldest one")
        end
        a_id, b_id = a_id - 1, a_id
      end
      backup_a = Backup.list[a_id] or abort("No backup #{a}")
      backup_b = Backup.list[b_id] or abort("No backup #{b}")
      Backup.diff(backup_a, backup_b)
    end

  private

    def backup_id(arg)
      if arg[0, 1] == 'n'
        number = arg[/\d+/].to_i
        Backup.list.index{ |backup| backup.number == number }
      else
        arg.to_i
      end
    end

    def format(value, type)
      case type
      when :time
        case value
        when 0...60
          "#{value.round} sec"
        when 60...3600
          '%.1f min' % (value / 60)
        when 3600...86400
          '%.1f hou' % (value / 3600)
        else
          '%.1f day' % (value / 86400)
        end
      when :date
        value.strftime('%Y-%m-%d %H:%M:%S')
      else
        value
      end
    end
  end
end

require 'tms.so'
require 'tms/backup'
require 'tms/space'
require 'tms/table'
