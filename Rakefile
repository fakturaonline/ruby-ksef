# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop]

desc "Open an irb session preloaded with this library"
task :console do
  require "irb"
  require "ksef"
  ARGV.clear
  IRB.start
end
