# encoding: UTF-8

require 'ffi-xattr'
require 'tms/helpers'
require 'tms/comparison'
require 'tms/better_attr_accessor'

module Tms
  class Backup
    class << self
      extend BetterAttrAccessor

      def backup_volume
        Tms.backup_volume or abort('backup volume not available')
      end

      def computer_name
        Tms.computer_name or abort('can\'t get computer name')
      end

      def backups_dir
        unless @backups_dir
          if system('which -s tmutil')
            $stderr.puts "Using tmutil to detect and mount Time Machine volume"
            self.backups_dir = `tmutil machinedirectory`.strip
          else
            self.backups_dir = Path.new(backup_volume) / 'Backups.backupdb' / computer_name
          end
          $stderr.puts "Detected: #{self.backups_dir}"
        end
        @backups_dir
      end
      def backups_dir=(backups_dir)
        backups_dir = Path.new(backups_dir)
        abort %{backups dir «#{backups_dir}» is not a dir} unless backups_dir.directory?
        @backups_dir = backups_dir
      end

      VOLUMES_PATH = '/Volumes/'
      def tm_path(path)
        unless path[0, VOLUMES_PATH.length].downcase == VOLUMES_PATH.downcase
          path = File.join(root_volume_path, path)
        end
        path[VOLUMES_PATH.length - 1..-1]
      end

      def real_path(path)
        path = File.join(VOLUMES_PATH, path)
        path == root_volume_path ? '/' : path
      end

      def root_volume_path
        @root_volume_path ||= Dir["#{VOLUMES_PATH}*"].find do |volume_path|
          File.symlink?(volume_path) && File.readlink(volume_path) == '/'
        end or abort('can\'t find /Volumes path for root')
      end

      def filter_dirs
        @filter_dirs ||= []
      end
      def filter_dirs?
        !filter_dirs.empty?
      end
      def add_filter_dir(filter_dir)
        filter_dirs << File.expand_path(filter_dir)
      end

      better_attr_accessor :show_in_progress
      better_attr_accessor :show_all_columns
      better_attr_accessor :colorize
      better_attr_accessor :show_progress
      better_attr_accessor :show_both_sizes

      def colorize?
        !colorize.nil? ? colorize : $stdout.tty?
      end

      def show_progress?
        !show_progress.nil? ? show_progress : $stderr.tty?
      end

      def list
        @list ||= begin
          backups_dir.children.map do |path|
            case path.basename.to_s
            when /^\d{4}-\d{2}-\d{2}-\d{6}$/
              new(path)
            when /^\d{4}-\d{2}-\d{2}-\d{6}\.inProgress$/
              if show_in_progress?
                path.children.select(&:directory?).map do |path_in_progress|
                  new(path_in_progress, true)
                end
              end
            end
          end.flatten.compact.sort
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
      state: 'com.apple.backupd.SnapshotState',
      type: 'com.apple.backupd.SnapshotType',
      version: 'com.apple.backup.SnapshotVersion',
      number: 'com.apple.backup.SnapshotNumber',
    }.each do |name, attr|
      class_eval <<-RUBY
        def #{name}
          @#{name} ||= xattr.get('#{attr}').to_i rescue '-'
        end
      RUBY
    end

    def <=>(other)
      name <=> other.name
    end

  private

    def xattr
      @xattr ||= Xattr.new(path.to_s)
    end
  end
end
