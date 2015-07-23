require 'test_helper'

class UserEntryControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  self.use_transactional_fixtures = true
  
  test 'routing works' do
    assert_routing "/", {controller: 'user_entry', action: 'show'}
    assert_routing({path: "/user_entry/authenticate", method: :post}, {controller: 'user_entry', action: 'authenticate'})
    assert_routing({path: "/user_entry/send_first_sms", method: :post}, {controller: 'user_entry', action: 'send_first_sms'})
    assert_routing('/user_entry/resend_sms', {controller: 'user_entry', action: 'resend_sms'})
  end

  test "Bad params goes to root" do
    post :authenticate
    assert_redirected_to root_path

    get :resend_sms
    assert_redirected_to root_path

    post :send_first_sms
    assert_redirected_to root_path
  end

  test "show screen works" do
    get :show
    assert_template :show
    assert_select '#entry-form', 1

    assert_match /will.be.charged/i, response.body

    assert_select('a') do |elts|
      found_link = false
      elts.each do |elt|
        found_link ||= /legal/.match(elt.attr('href'))
      end
      assert found_link
    end
  end
  
  describe "number with no known user" do
    it "welcomes to company" do
      post :authenticate, {primary_key: '9991239999'}
      assert_template :entry_bottom
      assert_match /welcome.to/i, response.body
    end
  end

  describe "number with known user" do
    it "shows resend SMS screen" do
      post :authenticate, {primary_key: '8888888888'}
      assert_template :entry_bottom
      #      assert_match /\san.*sms/i, response.body
      assert_equal 'known_user', assigns(:partial_name)

      assert_select('a') do |elt|
        assert_match '/user_entry/resend_sms', elt.attr('href')
      end
    end

    it "recognizes the user when the number has leading 1 or 0 or nonnumeric characters" do
      post :authenticate, {primary_key: '08888888888'}
      assert_match /\san.*sms/i, response.body

      post :authenticate, {primary_key: '18888888888'}
      assert_equal 'known_user', assigns(:partial_name)

      post :authenticate, {primary_key: '888-888-8888'}
      assert_equal 'known_user', assigns(:partial_name)
    end
  end

  describe "resend sms causes job to be created" do
    it 'enqueues jobs' do
      assert_enqueued_with(job: SmsJob) do
        get :resend_sms, {primary_key: '8888888888'}
      end
    end
  end

  test "User with duplicate number cannot get first sms" do
    assert_no_difference 'User.count' do
      post :send_first_sms, {primary_key: "+1-#{users(:user_2).phone_number}"}
    end
    
    assert_match /our.*system/i, flash[:notice]
    assert_enqueued_jobs 0
  end  
end
