# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tms}
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Boba Fat"]
  s.date = %q{2010-12-05}
  s.default_executable = %q{tms}
  s.description = %q{View avaliable Time Machine backups and show diff}
  s.executables = ["tms"]
  s.extensions = ["ext/tms/extconf.rb"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown"
  ]
  s.files = [
    "LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "bin/tms",
    "ext/tms/extconf.rb",
    "ext/tms/tms.c",
    "lib/tms.rb",
    "lib/tms/backup.rb",
    "lib/tms/space.rb",
    "tms.gemspec"
  ]
  s.homepage = %q{http://github.com/toy/tms}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Time Machine Status}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<colored>, [">= 0"])
      s.add_runtime_dependency(%q<xattr>, [">= 0"])
      s.add_runtime_dependency(%q<mutter>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0"])
      s.add_development_dependency(%q<rake-gem-ghost>, [">= 0"])
    else
      s.add_dependency(%q<colored>, [">= 0"])
      s.add_dependency(%q<xattr>, [">= 0"])
      s.add_dependency(%q<mutter>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rake-compiler>, [">= 0"])
      s.add_dependency(%q<rake-gem-ghost>, [">= 0"])
    end
  else
    s.add_dependency(%q<colored>, [">= 0"])
    s.add_dependency(%q<xattr>, [">= 0"])
    s.add_dependency(%q<mutter>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rake-compiler>, [">= 0"])
    s.add_dependency(%q<rake-gem-ghost>, [">= 0"])
  end
end

