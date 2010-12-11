module BetterAttrAccessor
  def better_attr_reader(*names)
    names.each do |name|
      attr_reader name
      # leaves nil and false as is, returns true for everything else
      class_eval <<-RUBY
        def #{name}?
          @#{name} && true
        end
      RUBY
    end
  end

  def better_attr_accessor(*names)
    better_attr_reader *names
    names.each do |name|
      attr_writer name
    end
  end
end
