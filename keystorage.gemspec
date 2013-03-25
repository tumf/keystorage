# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "keystorage"
  s.version = "0.4.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yoshihiro TAKAHARA"]
  s.date = "2013-03-25"
  s.description = "This is a command to store and manage your passwords."
  s.email = "y.takahara@gmail.com"
  s.executables = ["keystorage"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/keystorage",
    "keystorage.gemspec",
    "lib/keystorage.rb",
    "lib/keystorage/cli.rb",
    "lib/keystorage/command/base.rb",
    "lib/keystorage/command/get.rb",
    "lib/keystorage/command/help.rb",
    "lib/keystorage/command/list.rb",
    "lib/keystorage/command/set.rb",
    "lib/keystorage/commands.rb",
    "lib/keystorage/manager.rb",
    "test/helper.rb",
    "test/test_keystorage.rb"
  ]
  s.homepage = "http://github.com/tumf/keystorage"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Simple password storage command"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

