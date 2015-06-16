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
      sl = users(:has_secret_not_active).secret_link.secret

      assert_difference('PaymentTokenRecord.count', 1) do
        post :create, {link_secret: sl,
                       payment_token_record: {token_processor: 'stripe',
                                              token_value: 'not_existing_token'}
                      }
      end

      assert_redirected_to dash_path(link_secret: sl)
      assert_equal users(:has_secret_not_active), PaymentTokenRecord.last.user
    end

    it "does not work for previously known token records for a new user" do
      post :create, {link_secret: users(:user_ptr_phonenumber).secret_link.secret, payment_token_record: {token_processor: 'stripe', token_value: 'user_ptr_token_2'} }
      assert_redirected_to dash_path(link_secret: users(:user_ptr_phonenumber).secret_link.secret)
      assert_match /already/, flash[:alert]
    end      
  end
end
