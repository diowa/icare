# frozen_string_literal: true

desc 'Run all available code linters'
task lint: :environment

task(:default).prerequisites.unshift :lint
