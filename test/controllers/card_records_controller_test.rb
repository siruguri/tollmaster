require 'test_helper'

class CardRecordsControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  
  test 'routing' do
    assert_routing({path: '/card_records', method: :post}, {controller: 'card_records', action: 'create'})
  end

  test 'catch errors in request' do
    post :create, {primary_key: '212111333', payment_token_record: {token_processor: 'stripe'} }
    assert_equal 400, response.status
  end

  describe 'card record creation' do
    it "creates a secret link for a new user" do
      sl = 'has_secret_not_active_secret'
      test_email = 'emailme@me.com'
      test_username = 'thats my name'
      
      queue_size = enqueued_jobs.size
      assert_difference('PaymentTokenRecord.count', 1) do
        post :create, {link_secret: sl,
                       email_address: test_email,
                       username: test_username,
                       payment_token_record: {token_processor: 'stripe',
                                              token_value: 'not_existing_token'}
                      }
      end

      assert PaymentTokenRecord.last.disabled?
      assert_equal 2 + queue_size, enqueued_jobs.size
      assert_equal StripeCustomerIdJob, enqueued_jobs[0][:job]
      assert_equal ActionMailer::DeliveryJob, enqueued_jobs[1][:job]
      
      u = users(:has_secret_not_active)
      assert_redirected_to dash_path(link_secret: sl)
      assert_equal u, PaymentTokenRecord.last.user

      u.reload
      assert_equal test_email, u.email
      assert_equal test_username, u.username
    end

    it "does not work for previously known token records for a new user" do
      test_email = 'emailme@me.com'
      test_username = 'thats my name'
      
      post :create, {username: test_username, email_address: test_email,
                     link_secret: 'user_ptr_phonenumber_secret', payment_token_record: {token_processor: 'stripe', token_value: 'user_ptr_token_2'} }
      assert_redirected_to dash_path(link_secret: 'user_ptr_phonenumber_secret')
      assert_match /already/, flash[:alert]
    end      
  end
end
