# frozen_string_literal: true

desc 'Run all available code linters'
task :lint

task(:default).prerequisites.unshift task(:lint)
