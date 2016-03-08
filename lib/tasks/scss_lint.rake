# frozen_string_literal: true
begin
  require 'scss_lint/rake_task'
  SCSSLint::RakeTask.new do |t|
    # SCSSLint does not respect config file
    # See https://github.com/brigade/scss-lint/issues/726
    t.files = []
  end
rescue LoadError
  desc 'Run SCSS-Lint'
  task :scss_lint do
    $stderr.puts 'SCSS-Lint is disabled'
  end
end
