# frozen_string_literal: true
begin
  require 'slim_lint/rake_task'
  SlimLint::RakeTask.new
rescue LoadError
  desc 'Run Slim-Lint'
  task :slim_lint do
    $stderr.puts 'Slim-Lint is disabled'
  end
end
