unless ENV['COVERAGE_STARTED']
  require 'simplecov'
  SimpleCov.start 'rails'
  ENV['COVERAGE_STARTED'] = 'true'
end

require_relative '../app/models/concerns/duplicable'
