# frozen_string_literal: true
if %w(development test).include? Rails.env
  require 'scss_lint/rake_task'

  SCSSLint::RakeTask.new do |t|
    # SCSSLint does not respect config file
    # Workaround for https://github.com/brigade/scss-lint/issues/726
    t.files = []
  end

  task(:default).prerequisites.unshift task(:scss_lint)
end
