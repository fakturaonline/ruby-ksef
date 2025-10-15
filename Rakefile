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
  require_relative "lib/ksef"

  # Manually load all files for IRB (Zeitwerk doesn't work well in REPL)
  Dir[File.join(__dir__, 'lib', 'ksef', '**', '*.rb')].sort.each do |file|
    require file
  end

  ARGV.clear
  IRB.start
end
