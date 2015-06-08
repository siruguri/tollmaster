require 'test_helper'

class UserEntryFormValidationsTest < Capybara::Rails::TestCase
  include Rack::Test::Methods

  
  before do
    stub_request(:post, "https://#{ENV['TWILIO_TEST_ACCOUNT_SID']}:#{ENV['TWILIO_TEST_AUTH_TOKEN']}@api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_TEST_ACCOUNT_SID']}/Messages.json").
      with(:body => hash_including({"From"=>"15005550006", "To"=>/[0-4,6-9][0-9]{9,10}/, "Body" => /\/dash\//}),
           :headers => {'Accept'=>'application/json', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'twilio-ruby/4.1.0 (ruby/x86_64-darwin12.0 2.2.2-p95)'}).
      to_return(:status => 200, :body => valid_twilio_sms, :headers => {})

    Capybara.default_driver = :selenium
    visit root_path
  end

  describe "First step" do
    it "doesn't allow no phone number" do
      page.find('#pk-submit').click
      assert page.has_content?('enter a phone')
    end
  end

  describe "Second steps: unknown user" do
    before do
      start_entry
    end
    
    it "Performs numeric validations" do
      valid_credit_card
      ['cc_number', 'cvc', 'exp_month', 'exp_year'].each do |id|
        old_value = page.find("input##{id}").value()
        page.fill_in "#{id}", with: 'aa'
        page.find("input#form-submit").click

        assert page.has_content?('inputs is incorrect')
        page.fill_in "#{id}", with: old_value
      end
    end

    it 'shows stripe_error messages' do
      invalid_credit_card
      page.find('input#form-submit').click
      page.find('#primary-key')
      
      assert_operator page.find('#payment-errors').text.strip.size, :>, 0
    end
    
    it 'asks for cc for new user' do
      valid_credit_card

      page.find('input#form-submit').click
      page.find('#primary-key')

      assert_equal '/', page.current_path
      assert_match /sms/i, page.find('.notice').text
    end
  end

  describe "Known user" do
    it 'shows SMS message' do
      page.fill_in 'primary-key', with: users(:user_2).phone_number
      page.find('#pk-submit').click
      q = page.find('#primary-key')
      assert_match /sms/i, page.body
    end
  end

  after do
    Capybara.default_driver = :rack_test
  end

  private
  def start_entry
    page.fill_in 'primary-key', with: '9999999999'
    page.find('#pk-submit').click

    page.assert_selector '#cc_number'
    page.assert_selector '#payments-form input[name=primary_key]', visible: false
  end

  def valid_credit_card
    fields.each do |pair|
      page.fill_in "#{pair[0]}", with: pair[1]
    end 
  end

  def invalid_credit_card
    bad_fields.each do |pair|
      page.fill_in "#{pair[0]}", with: pair[1]
    end 
  end

  def fields
    [['cc_number', '5555555555554444'], ['cvc', '123'], ['exp_month', '10'], ['exp_year', '25']]
  end
  def bad_fields
    [['cc_number', '1555555555555444'], ['cvc', '123'], ['exp_month', '10'], ['exp_year', '25']]
  end

  def valid_twilio_sms
    {"sid": "SMe1877de9e3564fd8b613ca13d6744134", "date_created": "Mon, 18 May 2015 22:08:09 +0000", "date_updated": "Mon, 18 May 2015 22:08:09 +0000", "date_sent": nil, "account_sid": "AC0065a49c8252bcf0dafc76e027390a0a", "to": "+16509960998", "from": "+15005550006", "body": "hello", "status": "queued", "num_segments": "1", "num_media": "0", "direction": "outbound-api", "api_version": "2010-04-01", "price": nil, "price_unit": "USD", "uri": "/2010-04-01/Accounts/AC0065a49c8252bcf0dafc76e027390a0a/Messages/SMe1877de9e3564fd8b613ca13d6744134.json", "subresource_uris": {"media": "/2010-04-01/Accounts/AC0065a49c8252bcf0dafc76e027390a0a/Messages/SMe1877de9e3564fd8b613ca13d6744134/Media.json"}}.to_json
  end
end
