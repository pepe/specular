# -*- encoding: utf-8 -*-

version = "0.0.8"

Gem::Specification.new do |s|

  s.name = 'specular'
  s.version = version
  s.authors = ['Silviu Rusu']
  s.email = ['slivuz@gmail.com']
  s.homepage = 'https://github.com/slivu/specular'
  s.summary = 'specular-%s' % version
  s.description = 'Natural Unit Testing using Inline and/or Regular Specs'

  s.required_ruby_version = '>= 1.8.7'

  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'minitest', '~> 3.0'

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
end
