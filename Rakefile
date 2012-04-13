require 'rake'
require 'rake/testtask'

task :default => :test

test_ruby_opts = '-r "%s"' % ::File.expand_path('../test/setup', __FILE__)

desc 'Run all tests'
Rake::TestTask.new do |t|
  t.ruby_opts << test_ruby_opts
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end
