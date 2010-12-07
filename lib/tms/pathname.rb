require 'pathname'

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

  def recursive_size
    total = 0
    find do |path|
      begin
        if path.file?
          total += path.size
        end
      rescue
      end
    end
    total
  end

  def count_size(options = {})
    if @count_size.nil?
      @counted_size = if exist?
        if directory?
          options[:recursive] ? recursive_size : 0
        else
          size
        end
      else
        false
      end
    end
    @counted_size
  end

  def colored_size(options = {})
    Tms::Space.space(count_size(options), :color => true)
  end
end
