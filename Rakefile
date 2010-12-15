require 'rake'
require 'jeweler'
require 'rake/gem_ghost_task'
require 'rake/extensiontask'

name = 'tms'

Jeweler::Tasks.new do |gem|
  gem.name = name
  gem.summary = %Q{Time Machine Status}
  gem.description = %Q{View avaliable Time Machine backups and show their diff}
  gem.homepage = "http://github.com/toy/#{name}"
  gem.license = 'MIT'
  gem.authors = ['Ivan Kuchin']
  gem.add_runtime_dependency 'colored'
  gem.add_runtime_dependency 'xattr'
  gem.add_development_dependency 'jeweler', '~> 1.5.1'
  gem.add_development_dependency 'rake-compiler'
  gem.add_development_dependency 'rake-gem-ghost'
end
Jeweler::RubygemsDotOrgTasks.new
Rake::GemGhostTask.new
Rake::ExtensionTask.new name
