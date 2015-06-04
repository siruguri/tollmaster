require 'test_helper'
require 'webmock/minitest'
require 'JSON'

class PaymentsControllerTest < ActionController::TestCase
  def setup
    stub_request(:post, "https://api.stripe.com/v1/charges").
      with(:body => /amount.*23.45.*currency.*usd.*description.*Charge/).
      to_return(:status => 200, :body => stripe_response, :headers => {})
  end

  private
  def stripe_response
    {
      "id": "ch_6EdTop3HKdD3ec",
     "object": "charge",
     "created": 1431563267,
     "livemode": false,
     "paid": true,
     "status": "succeeded",
     "amount": 3000,
     "currency": "usd",
     "refunded": false,
     "source": {
                 "id": "card_6EdToQ79YRhusF",
                "object": "card",
                "last4": "4444",
                "brand": "MasterCard",
                "funding": "credit",
                "exp_month": 10,
                "exp_year": 2019,
                "country": "US",
                "name": nil,
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
                "customer": nil
               },
     "captured": true,
     "balance_transaction": "txn_6EdTs4uY8L2yem",
     "failure_message": nil,
     "failure_code": nil,
     "amount_refunded": 0,
     "customer": nil,
     "invoice": nil,
     "description": "Charge for test@example.com",
     "dispute": nil,
     "metadata": {
                 },
     "statement_descriptor": nil,
     "fraud_details": {
                      },
     "receipt_email": nil,
     "receipt_number": nil,
     "shipping": nil,
     "application_fee": nil,
     "refunds": {
                  "object": "list",
                 "total_count": 0,
                 "has_more": false,
                 "url": "/v1/charges/ch_6EdTop3HKdD3ec/refunds",
                 "data": [

                         ]
                }
    }.to_json
  end
end

  
