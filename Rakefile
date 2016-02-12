# frozen_string_literal: true
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require File.join(Rails.root.to_s, 'config', 'configuration.rb')

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  desc 'Run RuboCop'
  task :rubocop do
    $stderr.puts 'Rubocop is disabled'
  end
end

begin
  require 'slim_lint/rake_task'
  SlimLint::RakeTask.new
rescue LoadError
  desc 'Run Slim-Lint'
  task :rubocop do
    $stderr.puts 'Slim-Lint is disabled'
  end
end

task test: :spec

task default: [:rubocop, :slim_lint, :spec]

Rails.application.load_tasks
