require 'tms/path'
require 'tms/backup'
require 'tms/table'

module Tms
  class << self
    def version
      File.read(File.join(File.dirname(__FILE__), '../VERSION')).strip
    end

    def list
      backups = Backup.list
      Table.new do |t|
        t.col '', Backup.colorize? && :red
        t.col '', Backup.colorize? && :blue
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
        if Backup.list.length == 1
          abort("Only one backup exist")
        elsif a_id == 0 || (Backup.list[a_id] && !Backup.list[a_id - 1])
          abort("No backup before oldest one")
        else
          a_id, b_id = a_id - 1, a_id
        end
      end
      backup_a = Backup.list[a_id] or abort("No backup #{a}")
      backup_b = Backup.list[b_id] or abort("No backup #{b}")
      Comparison.new(backup_a, backup_b).run
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
