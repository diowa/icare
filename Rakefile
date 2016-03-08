# frozen_string_literal: true
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require File.join(Rails.root.to_s, 'config', 'configuration.rb')

task test: :spec

task default: [:rubocop, :slim_lint, :scss_lint, :spec]

Rails.application.load_tasks
