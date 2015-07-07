def valid_twilio_sms
  {"sid": "SMe1877de9e3564fd8b613ca13d6744134", "date_created": "Mon, 18 May 2015 22:08:09 +0000", "date_updated": "Mon, 18 May 2015 22:08:09 +0000", "date_sent": nil, "account_sid": "AC0065a49c8252bcf0dafc76e027390a0a", "to": "+16509960998", "from": "+15005550006", "body": "hello", "status": "queued", "num_segments": "1", "num_media": "0", "direction": "outbound-api", "api_version": "2010-04-01", "price": nil, "price_unit": "USD", "uri": "/2010-04-01/Accounts/AC0065a49c8252bcf0dafc76e027390a0a/Messages/SMe1877de9e3564fd8b613ca13d6744134.json", "subresource_uris": {"media": "/2010-04-01/Accounts/AC0065a49c8252bcf0dafc76e027390a0a/Messages/SMe1877de9e3564fd8b613ca13d6744134/Media.json"}}.to_json
end

def invalid_twilio_sms
  {"code": 21211, "message": "The 'To' number +1asd is not a valid phone number.", "more_info": "https://www.twilio.com/docs/errors/21211", "status": 400}.to_json
end

def valid_stripe_charge_object
  {
    "id": "ch_16HMo32eZvKYlo2CN0EYDD5k",
   "object": "charge",
   "created": 1435186643,
   "livemode": false,
   "paid": true,
   "status": "succeeded",
   "amount": 5000,
   "currency": "usd",
   "refunded": false,
   "source": {
               "id": "card_16HMo02eZvKYlo2CfsizBfho",
              "object": "card",
              "last4": "4242",
              "brand": "Visa",
              "funding": "credit",
              "exp_month": 12,
              "exp_year": 2016,
              "country": "US",
              "name": "gbr_brad@hotmail.com",
              "address_line1": nil,
              "address_line2": nil,
              "address_city": nil,
              "address_state": nil,
              "address_zip": nil,
              "address_country": nil,
              "cvc_check": "pass",
              "address_line1_check": nil,
              "address_zip_check": nil,
              "dynamic_last4": nil,
              "metadata": {
                          },
              "customer": "cus_6ULVKZxppyINJm"
             },
   "captured": true,
   "balance_transaction": "txn_16Esmv2eZvKYlo2CXxibx5gw",
   "failure_message": nil,
   "failure_code": nil,
   "amount_refunded": 0,
   "customer": "cus_6ULVKZxppyINJm",
   "invoice": nil,
   "description": nil,
   "dispute": nil,
   "metadata": {
               },
   "statement_descriptor": nil,
   "fraud_details": {
                    },
   "receipt_email": nil,
   "receipt_number": nil,
   "shipping": nil,
   "destination": nil,
   "application_fee": nil,
   "refunds": {
                "object": "list",
               "total_count": 0,
               "has_more": false,
               "url": "/v1/charges/ch_16HMo32eZvKYlo2CN0EYDD5k/refunds",
               "data": [

                       ]
              }
  }.to_json
end

def stripe_headers
  {'Accept'=>'*/*; q=0.5, application/xml'}
end

def customer_stub_response
  {"object": "customer",
   "created": 1424754360,
   "id": "cus_5l777Zn4es9U4C",
   "livemode": false,
   "description": "Customer for test@test.com Subscription ($20.00)",
   "email": "test@test.com",
   "default_source": "card_5l77gnbTFkucVP"}.to_json
end

def set_net_stubs
  stub_request(:post, "https://api.stripe.com/v1/customers").
    with(:body => {"description"=>"Customer record for ", "source"=>"tok_uu_tok"},
         headers: stripe_headers).
    to_return(:status => 200, :body => customer_stub_response, :headers => {})

  stub_request(:post, "https://api.stripe.com/v1/charges").
    with(:body => hash_including({"amount"=>/^[\.\d]+$/, "currency"=>"usd", "description"=>/IDs\# \d+/, "customer"=>/valid/}),
         headers: stripe_headers).
    to_return(:status => 200, :body => valid_stripe_charge_object)
  
  stub_request(:get, /reddit/).to_return(status: 200, body: 'stubbers stubbers stubbers stubbers stubbers')
  
  stub_request(:post, "https://#{ENV['TWILIO_TEST_ACCOUNT_SID']}:#{ENV['TWILIO_TEST_AUTH_TOKEN']}@api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_TEST_ACCOUNT_SID']}/Messages.json").
    with(:body => hash_including({"From"=>"15005550006", "To"=>/[0-4,6-9][0-9]{9,10}/, "Body" => /\/dash\//}),
         :headers => {'Accept'=>'application/json', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'twilio-ruby/4.2.0 (ruby/x86_64-darwin12.0 2.2.2-p95)'}).
    to_return(:status => 200, :body => valid_twilio_sms, :headers => {})

  stub_request(:post, "https://#{ENV['TWILIO_TEST_ACCOUNT_SID']}:#{ENV['TWILIO_TEST_AUTH_TOKEN']}@api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_TEST_ACCOUNT_SID']}/Messages.json").
    with(:body => hash_including({"From"=>"15005550006", "To"=>/5005550001/}),
         :headers => {'Accept'=>'application/json', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'twilio-ruby/4.2.0 (ruby/x86_64-darwin12.0 2.2.2-p95)'}).
    to_return(:status => 400, :body => invalid_twilio_sms, :headers => {})
end

