# frozen_string_literal: true

if %w[development test].include? Rails.env
  require 'slim_lint/rake_task'
  SlimLint::RakeTask.new

  task(lint: :environment).prerequisites.unshift :slim_lint
end
