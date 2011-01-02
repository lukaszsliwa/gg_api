# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gg_api/version"

Gem::Specification.new do |s|
  s.name        = "gg_api"
  s.version     = GGApi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Łukasz Śliwa"]
  s.email       = ["lukasz.sliwa@gmail.com"]
  s.homepage    = "https://github.com/mrplum/gg_api"
  s.summary     = %q{GG API dla Ruby}
  s.description = %q{Gem umożliwia tworzenie aplikacjia na platformę gg.pl w języku Ruby.}

  s.rubyforge_project = "gg_api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('oauth2')
  s.add_dependency('json')
  s.add_dependency('rspec')
end
