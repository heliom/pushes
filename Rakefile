# Rubygems
require 'bundler'
Bundler::GemHelper.install_tasks

# RSpec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :test => :spec
task :default => :spec
