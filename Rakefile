begin
  # Try to require the preresolved locked set of gems.
  require ::File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require(:default, :test)

require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'

Rspec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "./spec/**/*_spec.rb"
end

Rspec::Core::RakeTask.new(:rcov) do |t|
  t.pattern = "./spec/**/*_spec.rb"
  t.rcov = true
end

task :default => :spec


namespace :ci do 
  task :go do
    system("git submodule update --init")
    Rake::Task["default"].invoke
  end 
end

require 'yard/rake/yardoc_task'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end