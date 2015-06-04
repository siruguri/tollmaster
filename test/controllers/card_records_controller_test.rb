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
      initial_count = SecretLink.count + User.count

      assert_enqueued_with(job: SmsJob) do
        post :create, {primary_key: '9999999999', payment_token_record: {token_processor: 'stripe',
                                                                         token_value: 'not_existing_token'}
                      }
      end

      assert_equal initial_count+2, SecretLink.count+User.count
      assert_equal '9999999999', SecretLink.last.user.phone_number
    end

    it "does not work for previously known token records for a new user" do
      post :create, {primary_key: '9999999999', payment_token_record: {token_processor: 'stripe', token_value: 'user_ptr_token'} }
      assert_redirected_to root_path
      assert_match /already/, flash[:alert]
    end      
  end

end
