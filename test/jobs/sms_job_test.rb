require 'test_helper'

class SmsJobTest < ActiveSupport::TestCase
  def setup
    set_net_stubs
  end
  
  test 'valid number does not raise exceptions' do
    stub_request(:post, "https://#{ENV['TWILIO_TEST_ACCOUNT_SID']}:#{ENV['TWILIO_TEST_AUTH_TOKEN']}@api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_TEST_ACCOUNT_SID']}/Messages.json").
      with(:body => hash_including({"From"=>"15005550006", "To"=>/[0-4,6-9][0-9]{9,10}/, "Body" => /\/dash\//}),
           :headers => {'Accept'=>'application/json'}).
      to_return(:status => 200, :body => valid_twilio_sms, :headers => {})

    assert_nothing_raised do
      SmsJob.new(users(:user_with_valid_twilio_number).valid_secret_link, 'dummy').perform_now
    end
  end

  test 'invalid number invalidates user\'s phone number' do
    u = users(:user_with_invalid_twilio_number)
    u.invalid_phone_number = false
    u.save
    SmsJob.new(users(:user_with_invalid_twilio_number).valid_secret_link, 'dummy').perform_now

    u = users(:user_with_invalid_twilio_number)
    assert u.invalid_phone_number
  end

  test 'international user gets international sms' do
    stub_request(:post, "https://#{ENV['TWILIO_TEST_ACCOUNT_SID']}:#{ENV['TWILIO_TEST_AUTH_TOKEN']}@api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_TEST_ACCOUNT_SID']}/Messages.json").
      with(:body => hash_including({"From"=>"15005550006", To: '+14056788111', "Body" => /\/dash\//}),
           :headers => {'Accept'=>'application/json'}).
      to_return(:status => 200, :body => valid_twilio_sms, :headers => {})

    u = users(:user_international)
    SmsJob.perform_now(u.valid_secret_link, 'dummy')
  end
end
