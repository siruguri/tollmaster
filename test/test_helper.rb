ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'simplecov'
require 'rails/test_help'
require 'mocha/mini_test'
require 'webmock/minitest'

require 'minitest/rails/capybara'

Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }
WebMock.disable_net_connect!(:allow_localhost => true)

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  include FixtureFiles
  fixtures :all
end

class ActionController::TestCase
  # Let controller test cases open files
  include FixtureFiles
end
