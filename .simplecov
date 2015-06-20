require 'simplecov'

unless defined?(Spring)
  SimpleCov.start 'rails' do
    add_filter 'vendor'
    add_filter 'config'
    add_filter 'bundle'
    add_filter 'bin'
    add_filter 'Rakefile'
    add_filter 'lib/tasks'

    add_group 'API', 'app/api_engine'

    coverage_dir 'simplecov_coverage'
    minimum_coverage 95
  end

  if ENV['CIRCLE_ARTIFACTS']
    dir = File.join('..', '..', '..', ENV['CIRCLE_ARTIFACTS'], 'coverage')
    SimpleCov.coverage_dir(dir)
  end
end
