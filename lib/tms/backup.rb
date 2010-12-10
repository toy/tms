require 'colored'
require 'xattr'
require 'tms/better_attr_accessor'

class Tms::Backup
  class << self
    extend BetterAttrAccessor

    def backup_volume
      Tms.backup_volume or abort('backup volume not avaliable')
    end

    def computer_name
      Tms.computer_name or abort('can\'t get computer name')
    end

    def backups_dir
      unless @backups_dir
        self.backups_dir = Pathname(backup_volume) + 'Backups.backupdb' + computer_name
      end
      @backups_dir
    end
    def backups_dir=(backups_dir)
      backups_dir = Pathname(backups_dir)
      abort %{backups dir "#{backups_dir}" is not a dir} unless backups_dir.directory?
      @backups_dir = backups_dir
    end

    better_attr_accessor :filter_dir
    better_attr_accessor :show_in_progress
    better_attr_accessor :show_all_columns

    def list
      @list ||= begin
        backups_dir.children.map do |path|
          case path.basename.to_s
          when /^\d{4}-\d{2}-\d{2}-\d{6}$/
            new(path)
          when /^\d{4}-\d{2}-\d{2}-\d{6}\.inProgress$/
              path.children.select(&:directory?).each do |path_in_progress|
            if show_in_progress?
                new(path_in_progress, true)
              end
            end
          end
        end.flatten.compact.sort
      end
    end

    def diff(a, b)
      total = 0
      if filter_dir?
        root_dir = (a.path.children + b.path.children).select(&:directory?).select{ |child| Pathname(File.join(child, filter_dir)).exist? }.map(&:basename).uniq
        root_dir = File.join(root_dir, filter_dir)
        total += compare(a.path + root_dir, b.path + root_dir, Pathname('/') + root_dir)
      else
        (a.path.children(false) | b.path.children(false)).reject{ |child| child.to_s[0, 1] == '.' }.sort.each do |path|
          total += compare(a.path + path, b.path + path, Pathname('/') + path)
        end
      end
      puts "#{'Total:'.bold} #{Tms::Space.space(total, :color => true)}"
    end

  private

    def compare(a, b, path)
      case
      when !a.exist?
        puts "#{'  █'.green} #{b.colored_size(:recursive => true)} #{path}#{b.postfix}"
        b.count_size || 0
      when !b.exist?
        puts "#{'█  '.blue} #{a.colored_size(:recursive => true)} #{path}#{a.postfix}"
        0
      when a.ftype != b.ftype
        puts "#{'!!!'.red.bold} #{b.colored_size(:recursive => true)} #{path} (#{a.ftype}=>#{b.ftype})"
        b.count_size || 0
      when a.lstat.ino != b.lstat.ino
        if a.readable? && b.readable?
          puts "#{'█≠█'.yellow} #{a.colored_size} #{path}#{a.postfix}" unless a.symlink? && a.readlink == b.readlink
          if a.directory? && !a.symlink?
            total = 0
            (a.children(false) | b.children(false)).sort.each do |child|
              total += compare(a + child, b + child, path + child)
            end
            total
          else
            b.size
          end
        else
          puts "??? #{path}#{a.postfix}".red.bold
          0
        end
      else
        0
      end
    end
  end

  extend BetterAttrAccessor

  better_attr_reader :path, :in_progress
  def initialize(path, in_progress = false)
    @path = path
    @in_progress = in_progress
  end

  def name
    @name ||= in_progress? ? "#{path.dirname.basename}/#{path.basename}" : path.basename.to_s
  end

  def started_at
    @start_date ||= Time.at(xattr.get('com.apple.backupd.SnapshotStartDate').to_i / 1_000_000.0)
  end
  def finished_at
    @finished_at ||= Time.at(xattr.get('com.apple.backupd.SnapshotCompletionDate').to_i / 1_000_000.0)
  end
  def completed_in
    finished_at - started_at
  end
  {
    :state   => 'com.apple.backupd.SnapshotState',
    :type    => 'com.apple.backupd.SnapshotType',
    :version => 'com.apple.backup.SnapshotVersion',
    :number  => 'com.apple.backup.SnapshotNumber',
  }.each do |name, attr|
    class_eval <<-src
      def #{name}
        @#{name} ||= xattr.get('#{attr}').to_i rescue '-'
      end
    src
  end

  def <=>(other)
    name <=> other.name
  end

private

  def xattr
    @xattr ||= Xattr.new(path)
  end
end
