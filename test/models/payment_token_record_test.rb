require 'test_helper'

class PaymentTokenRecordTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  
  test 'job is enqueued' do
    assert_enqueued_with job: StripeCustomerIdJob do 
      p = PaymentTokenRecord.create(token_processor: 'dummy', token_value: 'dummy', user: users(:user_1))
    end
  end
end
