require 'test_helper'

class SmsJobTest < ActiveSupport::TestCase
  def setup
    stub_request(:post, "https://#{ENV['TWILIO_TEST_ACCOUNT_SID']}:#{ENV['TWILIO_TEST_AUTH_TOKEN']}@api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_TEST_ACCOUNT_SID']}/Messages.json").
      with(:body => hash_including({"From"=>"15005550006", "To"=>/[0-4,6-9][0-9]{9,10}/, "Body" => /\/dash\//}),
           :headers => {'Accept'=>'application/json', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'twilio-ruby/4.1.0 (ruby/x86_64-darwin12.0 2.2.2-p95)'}).
      to_return(:status => 200, :body => valid_twilio_sms, :headers => {})

    stub_request(:post, "https://#{ENV['TWILIO_TEST_ACCOUNT_SID']}:#{ENV['TWILIO_TEST_AUTH_TOKEN']}@api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_TEST_ACCOUNT_SID']}/Messages.json").
      with(:body => hash_including({"From"=>"15005550006", "To"=>/5005550001/}),
           :headers => {'Accept'=>'application/json', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'twilio-ruby/4.1.0 (ruby/x86_64-darwin12.0 2.2.2-p95)'}).
      to_return(:status => 400, :body => invalid_twilio_sms, :headers => {})
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

    private
  def valid_twilio_sms
    {"sid": "SMe1877de9e3564fd8b613ca13d6744134", "date_created": "Mon, 18 May 2015 22:08:09 +0000", "date_updated": "Mon, 18 May 2015 22:08:09 +0000", "date_sent": nil, "account_sid": "AC0065a49c8252bcf0dafc76e027390a0a", "to": "+16509960998", "from": "+15005550006", "body": "hello", "status": "queued", "num_segments": "1", "num_media": "0", "direction": "outbound-api", "api_version": "2010-04-01", "price": nil, "price_unit": "USD", "uri": "/2010-04-01/Accounts/AC0065a49c8252bcf0dafc76e027390a0a/Messages/SMe1877de9e3564fd8b613ca13d6744134.json", "subresource_uris": {"media": "/2010-04-01/Accounts/AC0065a49c8252bcf0dafc76e027390a0a/Messages/SMe1877de9e3564fd8b613ca13d6744134/Media.json"}}.to_json
  end

  def invalid_twilio_sms
    {"code": 21211, "message": "The 'To' number +1asd is not a valid phone number.", "more_info": "https://www.twilio.com/docs/errors/21211", "status": 400}.to_json
  end
end
