# frozen_string_literal: true

namespace :yarn do
  # rubocop:disable Rails/RakeEnvironment
  task :run, %i[command] do |_, args|
    # Install only production deps when for not usual envs.
    valid_node_envs = %w[test development production]
    node_env = ENV.fetch('NODE_ENV') do
      valid_node_envs.include?(Rails.env) ? Rails.env : 'production'
    end

    system({ 'NODE_ENV' => node_env }, Rails.root.join("bin/yarn #{args[:command]}").to_s)
    abort if $CHILD_STATUS.exitstatus.nonzero?
  rescue Errno::ENOENT
    warn 'bin/yarn was not found.'
    exit 1
  end

  desc 'Run `bin/yarn stylelint app/**/*.scss`'
  task :stylelint do
    Rake::Task['yarn:run'].execute(command: 'stylelint app/**/*.scss')
  end

  desc 'Run `bin/yarn standard`'
  task :standard do
    Rake::Task['yarn:run'].execute(command: 'standard')
  end
  # rubocop:enable Rails/RakeEnvironment
end

task(:lint).sources.push 'yarn:stylelint'
task(:lint).sources.push 'yarn:standard'
