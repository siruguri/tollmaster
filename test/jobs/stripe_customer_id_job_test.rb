require 'test_helper'

class StripeCustomerIdJobTest < ActiveSupport::TestCase
  def setup
    set_net_stubs
  end
  
  test 'performed job sets up a customer id' do
    p = payment_token_records(:ptr_1)
    StripeCustomerIdJob.perform_now p 
    
    assert_equal 'cus_5l777Zn4es9U4C', PaymentTokenRecord.find(p.id).customer_id
    assert_equal 'cus_5l777Zn4es9U4C', PaymentTokenRecord.find(p.id).user.stripe_customer_id
  end
end
