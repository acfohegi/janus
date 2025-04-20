# frozen_string_literal: true

# Rakefile for janus gem

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# Install project dependencies
desc 'Install dependencies'
task :setup do
  sh 'bundle install'
end

# Run RSpec test suite
desc 'Run tests'
RSpec::Core::RakeTask.new(:test)

# Run RuboCop linting
desc 'Run lint checks with autocorrection'
RuboCop::RakeTask.new(:lint) do |t|
  t.options = ['-A']
end
