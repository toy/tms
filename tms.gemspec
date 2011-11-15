# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "tms"
  s.version = "1.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ivan Kuchin"]
  s.date = "2011-11-15"
  s.description = "View avaliable Time Machine backups and show their diff"
  s.executables = ["tms"]
  s.extensions = ["ext/tms/extconf.rb"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    ".tmignore",
    "LICENSE.txt",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "bin/tms",
    "ext/tms/extconf.rb",
    "ext/tms/tms.c",
    "lib/tms.rb",
    "lib/tms/backup.rb",
    "lib/tms/better_attr_accessor.rb",
    "lib/tms/comparison.rb",
    "lib/tms/path.rb",
    "lib/tms/space.rb",
    "lib/tms/table.rb",
    "tms.gemspec"
  ]
  s.homepage = "http://github.com/toy/tms"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Time Machine Status"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<colored>, [">= 0"])
      s.add_runtime_dependency(%q<ffi-xattr>, ["~> 0.0.4"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0"])
      s.add_development_dependency(%q<rake-gem-ghost>, [">= 0"])
    else
      s.add_dependency(%q<colored>, [">= 0"])
      s.add_dependency(%q<ffi-xattr>, ["~> 0.0.4"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rake-compiler>, [">= 0"])
      s.add_dependency(%q<rake-gem-ghost>, [">= 0"])
    end
  else
    s.add_dependency(%q<colored>, [">= 0"])
    s.add_dependency(%q<ffi-xattr>, ["~> 0.0.4"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rake-compiler>, [">= 0"])
    s.add_dependency(%q<rake-gem-ghost>, [">= 0"])
  end
end

