require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @u = users(:user_only_number)
  end
  
  test 'routing works' do
    assert_routing({method: :post, path: '/profiles/update'}, {controller: 'users', action: 'update'})
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
  
  private
  def response_json
    JSON.parse response.body
  end
end
