require 'test_helper'

class SmsJobTest < ActiveSupport::TestCase
  def setup
    set_net_stubs
  end
  
  test 'valid number does not raise exceptions' do
    assert_nothing_raised do
      SmsJob.new(users(:user_with_valid_twilio_number)).perform_now
    end
  end

  test 'invalid number invalidates user\'s phone number' do
    u = users(:user_with_invalid_twilio_number)
    u.invalid_phone_number = false
    u.save
    SmsJob.new(users(:user_with_invalid_twilio_number)).perform_now

    u = users(:user_with_invalid_twilio_number)
    assert u.invalid_phone_number
  end
end
