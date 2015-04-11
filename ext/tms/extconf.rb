require 'mkmf'

if RUBY_PLATFORM.downcase.include?("darwin")
  with_ldflags($LDFLAGS + ' -framework Foundation'){ true }
else
  with_ldflags($LIBS + ' -lCoreFoundation'){ true }
end

create_makefile('tms/helpers')
