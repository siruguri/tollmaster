require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  def setup
    @u = users(:user_only_number)
  end
  
  test 'routing works' do
    assert_routing({method: :post, path: '/profiles'}, {controller: 'users', action: 'update'})
    assert_routing('/profiles/show_invoices', {controller: 'users', action: 'show_invoices'})
  end
  
  test 'update with email and first/last name' do
    post :update, {email_address: 'test@test.com', username: 'first last', link_secret: 'only_number_secret'}
    assert assigns(:user)

    v = User.find(@u.id)
    assert_equal 'first', v.first_name
    assert_equal 'test@test.com', v.email

    assert_equal 2, response_json['update_ids'].size
  end
  
  test 'update with email and only one name' do
    post :update, {email_address: 'test@test.com', username: 'first', link_secret: 'only_number_secret'}
    assert assigns(:user)

    v = User.find(@u.id)
    assert_equal 'first', v.last_name
    assert_equal 'test@test.com', v.email
    
    assert_equal 2, response_json['update_ids'].size
  end

  test 'update with email and only one name' do
    post :update, {email_address: 'test@test.com', link_secret: 'only_number_secret'}
    assert_equal 1, response_json['update_ids'].size
  end

  describe 'invoice listing' do
    it 'needs admin to sign in' do
      devise_sign_out :admin
      get :show_invoices
      assert_redirected_to controller: 'devise/sessions', action: 'new'
    end

    it 'shows template correctly' do
      devise_sign_in(admins(:admin_1))
      get :show_invoices
      assert_template :show_invoices
      assert_match /135.24/, response.body

      assert_select 'tr', 4
    end
  end

  test 'charging invoices works' do
    devise_sign_in(admins(:admin_1))
    assert_enqueued_with(job: ChargeInvoicesJob, args: ['all']) do
      post :charge_invoices
    end    
    assert_redirected_to show_invoices_users_path
  end

  private
  def response_json
    JSON.parse response.body
  end
end
