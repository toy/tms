require 'pathname'
require 'colored'
require 'xattr'
require 'mutter'

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

  def colored_size(options = {})
    if exist?
      if directory?
        if options[:recursive]
          total = 0
          find do |path|
            total += path.size rescue nil
          end
          Tms::Space.space(total, :color => true)
        else
          '      '
        end
      else
        Tms::Space.space(size, :color => true)
      end
    else
      '!!!!!!'
    end
  end
end

module Tms
  class << self
    def list
      backups = Backup.list
      Mutter::Table.new do
        column :align => :right, :style => :red
        column :align => :right, :style => :blue
        column :align => :right
        column
      end.tap do |table|
        table << ['', '', 'num', 'name']
        backups.each_with_index do |backup, i|
          table << [i, i - backups.length, backup.number, backup.name]
        end
      end.print
    end

    def diff(a, b)
      backup_a = Backup.list[a] || abort("No backup with id #{a}")
      backup_b = Backup.list[b] || abort("No backup with id #{b}")
      Backup.diff(backup_a, backup_b)
    end
  end
end

require 'tms.so'
require 'tms/backup'
require 'tms/space'
