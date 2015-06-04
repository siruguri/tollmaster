require 'test_helper'

class UserEntryControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  test 'routing works' do
    assert_routing "/", {controller: 'user_entry', action: 'show'}
    assert_routing({path: "/user_entry", method: :post}, {controller: 'user_entry', action: 'authenticate'})
    assert_routing('/user_entry/resend_sms', {controller: 'user_entry', action: 'resend_sms'})
  end

  test "Bad params goes to root" do
    post :authenticate
    assert_redirected_to root_path

    get :resend_sms
    assert_redirected_to root_path
  end

  test "show screen works" do
    get :show
    assert assigns :publishable_stripe_key
    assert_template :show
  end
  
  describe "number with no known user" do
    it "shows CC deets screen" do
      post :authenticate, {primary_key: '9999999999'}
      assert_template :entry_bottom
      assert_match /enter credit card/i, response.body
    end
  end

  describe "number with known user" do
    it "shows resend SMS screen" do
      post :authenticate, {primary_key: '8888888888'}
      assert_template :entry_bottom
      assert_match /resend sms/i, response.body

      assert_select('a') do |elt|
        assert_match '/user_entry/resend_sms', elt.attr('href')
      end
    end
  end

  describe "resend sms causes job to be created" do
    it 'enqueues jobs' do
      assert_enqueued_with(job: SmsJob) do
        get :resend_sms, {primary_key: '8888888888'}
      end
    end
  end
end
