# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'tms'
  s.version     = '1.5.0'
  s.summary     = %q{Time Machine Status}
  s.description = %Q{View avaliable Time Machine backups and show their diff}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'MIT'

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extensions    = `git ls-files -- ext/**/extconf.rb`.split("\n")
  s.require_paths = %w[lib]

  s.add_runtime_dependency 'colored'
  s.add_runtime_dependency 'ffi-xattr', '~> 0.0.4'
end
