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

  def count_size(options = {})
    if @count_size.nil?
      if exist?
        if directory?
          @counted_size = 0
          find{ |path| @counted_size += path.size rescue nil } if options[:recursive]
        else
          @counted_size = size
        end
      else
        @counted_size = false
      end
    end
    @counted_size
  end

  def colored_size(options = {})
    Tms::Space.space(count_size(options), :color => true)
  end
end
