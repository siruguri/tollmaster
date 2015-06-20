require 'test_helper'

class UserEntryFormValidationsTest < Capybara::Rails::TestCase
  self.use_transactional_fixtures = false
  include ActiveJob::TestHelper
  
  def setup
    Capybara.default_driver = :selenium
    visit root_path
  end

  test "First step" do
    find('#pk-submit').click
    assert has_content?('enter a phone')
  end

  test "Second steps: unknown user" do
    fill_in 'primary-key', with: '9999999999'
    find('#pk-submit').click
    q = find('#entry-form-paragraph')
    assert_match /welcome.*number/i, body

    find('#first-sms-submit').click
    find('#pk-submit')

    assert_match /received.an.sms/i, body
    assert_enqueued_jobs 1
  end

  test "Known user shows SMS message" do
    fill_in 'primary-key', with: users(:user_2).phone_number
    find('#pk-submit').click
    q = find('#primary-key')
    assert_match /sms/i, body
  end

  def teardown
    Capybara.default_driver = :rack_test
  end
end
  
