require 'rubygems'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new
rescue LoadError
  task(:spec) { abort '`gem install rspec` to run specs' }
end

desc 'Run tests'
task default: :spec
task test: :spec
