# frozen_string_literal: true

if %w[development test].include? Rails.env
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  task(:lint).sources.unshift :rubocop
end
