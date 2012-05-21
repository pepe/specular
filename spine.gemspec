# -*- encoding: utf-8 -*-
require File.expand_path '../lib/spine/version', __FILE__

Gem::Specification.new do |s|

  s.name = 'spine'
  s.version = Spine::VERSION
  s.authors = ['Silviu Rusu']
  s.email = ['slivuz@gmail.com']
  s.homepage = 'https://github.com/slivu/spine'
  s.summary = 'spine-%s' % Spine::VERSION
  s.description = 'Inline specs for your unit tests'

  s.required_ruby_version = '>= 1.8.7'

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
end
